//
//  MapSearchService.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/21.
//

import Foundation
import MapKit

final class MapSearchService {
    
    func searchPlaces(for request: DateRequestData) async throws -> [PlaceCandidate] {
        let categories: [String] = buildSearchQueries(for: request.mood)
        
        var allResults: [PlaceCandidate] = []
        
        for query in categories {
            let results = try await performSearch(query: query, request: request)
            allResults.append(contentsOf: results)
        }
        
        let unique = deduplicatePlaces(allResults)
        let balanced = balancePlaces(unique, maxResults: 80, maxPerCategory: 16)
        
        return balanced
    }
    
    private func performSearch(query: String, request: DateRequestData) async throws -> [PlaceCandidate] {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.region = MKCoordinateRegion(
            center: request.coordinate,
            latitudinalMeters: request.radius,
            longitudinalMeters: request.radius
        )
        
        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()
        let centerLocation = CLLocation(
            latitude: request.coordinate.latitude,
            longitude: request.coordinate.longitude
        )
        
        return response.mapItems.compactMap { item in
            guard let name = item.name else { return nil }
            
            let placeLocation = CLLocation(
                latitude: item.location.coordinate.latitude,
                longitude: item.location.coordinate.longitude
            )
            let distance = placeLocation.distance(from: centerLocation)
            
            guard distance <= request.radius else { return nil }
            
            return PlaceCandidate(
                name: name,
                coordinate: item.location.coordinate,
                address: formatAddress(item),
                category: query,
                distanceFromCenter: distance
            )
        }
        
    }
    
    private func buildSearchQueries(for mood: DateMood) -> [String] {
        switch mood {
        case .chill:
            return ["bar", "pub", "ice cream parlor", "ice cream shop", "ice cream stand", "cafe", "park", "bookstore", "cinema", "coffee shop"]
        case .romantic:
            return ["romantic restaurant", "wine bar", "cafe", "aquarium", "cinema"]
        case .fun:
            return ["arcade", "karaoke", "bowling", "casino", "casino room"]
        case .adventure:
            return ["amusement park", "park", "zoo", "aquarium", "casino", "casino room", "hiking", "museum", "activity", "aquarium"]
        }
    }
    
    private func deduplicatePlaces(_ places: [PlaceCandidate]) -> [PlaceCandidate] {
        let grouped = Dictionary(grouping: places) { place in
            "\(normalized(place.name))|\(normalized(place.address))"
        }
        
        return grouped.compactMap { $0.value.first }
    }
    
    private func balancePlaces(
        _ places: [PlaceCandidate],
        maxResults: Int,
        maxPerCategory: Int
    ) -> [PlaceCandidate] {
        let groupedByCategory = Dictionary(grouping: places, by: { $0.category })
        var limitedGroups: [String: [PlaceCandidate]] = [:]
        
        for (category, group) in groupedByCategory {
            let sortedGroup = group
            limitedGroups[category] = Array(sortedGroup.prefix(maxPerCategory))
        }
        
        let orderedCategories = buildSearchQueries(for: places.first.map { _ in
            placesMoodFallback(from: places)
        } ?? .chill)
        
        var results: [PlaceCandidate] = []
        var categoryQueues = limitedGroups
        var didAppend = true
        
        while results.count < maxResults && didAppend {
            didAppend = false
            
            for category in orderedCategories {
                guard var queue = categoryQueues[category], !queue.isEmpty else { continue }
                results.append(queue.removeFirst())
                categoryQueues[category] = queue
                didAppend = true
                
                if results.count >= maxResults {
                    break
                }
            }
            
            if results.count >= maxResults {
                break
            }
            
            for key in categoryQueues.keys.sorted() {
                guard var queue = categoryQueues[key], !queue.isEmpty else { continue }
                results.append(queue.removeFirst())
                categoryQueues[key] = queue
                didAppend = true
                
                if results.count >= maxResults {
                    break
                }
            }
        }
        
        return results
    }
    
    private func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }
    
    private func placesMoodFallback(from places: [PlaceCandidate]) -> DateMood {
        let categories = Set(places.map { $0.category })
        
        if categories.contains("romantic restaurant") || categories.contains("wine bar") {
            return .romantic
        } else if categories.contains("arcade") || categories.contains("karaoke") || categories.contains("bowling") {
            return .fun
        } else if categories.contains("amusement park") || categories.contains("zoo") || categories.contains("aquarium") || categories.contains("museum") {
            return .adventure
        } else {
            return .chill
        }
    }
    
    private func formatAddress(_ item: MKMapItem) -> String {
        let parts = [
            item.addressRepresentations?.cityWithContext,
            item.address?.shortAddress,
            item.address?.fullAddress
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        
        if let first = parts.first {
            return first
        } else {
            return "Unknown address"
        }
    }
}
