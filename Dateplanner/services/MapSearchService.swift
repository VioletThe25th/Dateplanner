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
        let searchPlan = searchPlan(for: request.mood)
        validateSearchPlan(searchPlan, mood: request.mood)
        var allResults = try await executeSearches(searchPlan.queries, request: request)
        var uniquePlaces = deduplicatePlaces(allResults)

        if uniquePlaces.count < searchPlan.minimumDesiredResults {
            let missingQueryCategories = Set(searchPlan.queries.map(\.category))
            let fallbackQueries = searchPlan.fallbackQueries.filter { !missingQueryCategories.contains($0.category) }
            let fallbackResults = try await executeSearches(fallbackQueries, request: request)
            allResults.append(contentsOf: fallbackResults)
            uniquePlaces = deduplicatePlaces(allResults)
        }

        return balancePlaces(
            uniquePlaces,
            orderedGroups: searchPlan.orderedGroups,
            orderedCategories: uniquePreservingOrder((searchPlan.queries + searchPlan.fallbackQueries).map(\.category)),
            maxResults: searchPlan.maxResults,
            maxPerCategory: searchPlan.maxPerCategory,
            maxPerGroup: searchPlan.maxPerGroup
        )
    }

    private func executeSearches(_ specs: [SearchQuerySpec], request: DateRequestData) async throws -> [PlaceCandidate] {
        var allResults: [PlaceCandidate] = []
        var lastError: Error?

        for spec in specs {
            do {
                let results = try await performSearch(spec: spec, request: request)
                allResults.append(contentsOf: results)
            } catch {
                lastError = error
            }
        }

        if allResults.isEmpty, let lastError {
            throw lastError
        }

        return allResults
    }

    private func performSearch(spec: SearchQuerySpec, request: DateRequestData) async throws -> [PlaceCandidate] {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = spec.query
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

        let candidates = response.mapItems.compactMap { item -> PlaceCandidate? in
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
                category: spec.category,
                group: spec.group,
                distanceFromCenter: distance
            )
        }

        return candidates
            .sorted(by: sortByQuality)
            .prefix(spec.maxResults)
            .map { $0 }
    }

    private func searchPlan(for mood: DateMood) -> SearchPlan {
        switch mood {
        case .chill:
            return SearchPlan(
                queries: [
                    SearchQuerySpec(query: "specialty coffee", category: "coffee shop", group: "coffee", maxResults: 10),
                    SearchQuerySpec(query: "cafe", category: "cafe", group: "coffee", maxResults: 10),
                    SearchQuerySpec(query: "tea house", category: "tea house", group: "coffee", maxResults: 8),
                    SearchQuerySpec(query: "matcha cafe", category: "matcha cafe", group: "coffee", maxResults: 6),
                    SearchQuerySpec(query: "dessert cafe", category: "dessert cafe", group: "sweet", maxResults: 8),
                    SearchQuerySpec(query: "ice cream shop", category: "ice cream", group: "sweet", maxResults: 8),
                    SearchQuerySpec(query: "bakery", category: "bakery", group: "sweet", maxResults: 7),
                    SearchQuerySpec(query: "wine bar", category: "wine bar", group: "drinks", maxResults: 8),
                    SearchQuerySpec(query: "jazz bar", category: "jazz bar", group: "drinks", maxResults: 6),
                    SearchQuerySpec(query: "bookstore", category: "bookstore", group: "culture", maxResults: 8),
                    SearchQuerySpec(query: "art gallery", category: "art gallery", group: "culture", maxResults: 7),
                    SearchQuerySpec(query: "record store", category: "record store", group: "culture", maxResults: 6),
                    SearchQuerySpec(query: "park", category: "park", group: "walk", maxResults: 10),
                    SearchQuerySpec(query: "riverside walk", category: "scenic walk", group: "walk", maxResults: 7),
                    SearchQuerySpec(query: "observation deck", category: "observation deck", group: "walk", maxResults: 6),
                    SearchQuerySpec(query: "cinema", category: "cinema", group: "night", maxResults: 6)
                ],
                fallbackQueries: [
                    SearchQuerySpec(query: "coffee shop", category: "coffee lounge", group: "coffee", maxResults: 10),
                    SearchQuerySpec(query: "dessert", category: "dessert spot", group: "sweet", maxResults: 8),
                    SearchQuerySpec(query: "bar", category: "casual bar", group: "drinks", maxResults: 8),
                    SearchQuerySpec(query: "garden", category: "garden", group: "walk", maxResults: 7),
                    SearchQuerySpec(query: "museum", category: "museum", group: "culture", maxResults: 7),
                    SearchQuerySpec(query: "tea room", category: "tea room", group: "coffee", maxResults: 6)
                ],
                orderedGroups: ["coffee", "walk", "culture", "sweet", "drinks", "night"],
                minimumDesiredResults: 34,
                maxResults: 60,
                maxPerCategory: 6,
                maxPerGroup: 14
            )

        case .romantic:
            return SearchPlan(
                queries: [
                    SearchQuerySpec(query: "romantic restaurant", category: "romantic restaurant", group: "dining", maxResults: 10),
                    SearchQuerySpec(query: "fine dining restaurant", category: "fine dining", group: "dining", maxResults: 8),
                    SearchQuerySpec(query: "sushi restaurant", category: "sushi restaurant", group: "dining", maxResults: 8),
                    SearchQuerySpec(query: "wine bar", category: "wine bar", group: "drinks", maxResults: 8),
                    SearchQuerySpec(query: "cocktail bar", category: "cocktail bar", group: "drinks", maxResults: 7),
                    SearchQuerySpec(query: "speakeasy bar", category: "speakeasy", group: "drinks", maxResults: 6),
                    SearchQuerySpec(query: "dessert cafe", category: "dessert cafe", group: "sweet", maxResults: 7),
                    SearchQuerySpec(query: "tea house", category: "tea house", group: "sweet", maxResults: 6),
                    SearchQuerySpec(query: "patisserie", category: "patisserie", group: "sweet", maxResults: 6),
                    SearchQuerySpec(query: "aquarium", category: "aquarium", group: "experience", maxResults: 7),
                    SearchQuerySpec(query: "museum", category: "museum", group: "experience", maxResults: 7),
                    SearchQuerySpec(query: "art gallery", category: "art gallery", group: "experience", maxResults: 6),
                    SearchQuerySpec(query: "planetarium", category: "planetarium", group: "experience", maxResults: 5),
                    SearchQuerySpec(query: "observation deck", category: "observation deck", group: "scenic", maxResults: 6),
                    SearchQuerySpec(query: "botanical garden", category: "botanical garden", group: "scenic", maxResults: 6),
                    SearchQuerySpec(query: "night view point", category: "night view", group: "scenic", maxResults: 5),
                    SearchQuerySpec(query: "cinema", category: "cinema", group: "night", maxResults: 6)
                ],
                fallbackQueries: [
                    SearchQuerySpec(query: "restaurant", category: "restaurant", group: "dining", maxResults: 10),
                    SearchQuerySpec(query: "rooftop bar", category: "rooftop bar", group: "drinks", maxResults: 7),
                    SearchQuerySpec(query: "garden", category: "garden", group: "scenic", maxResults: 7),
                    SearchQuerySpec(query: "spa", category: "spa", group: "experience", maxResults: 5),
                    SearchQuerySpec(query: "hotel lounge", category: "hotel lounge", group: "drinks", maxResults: 5)
                ],
                orderedGroups: ["dining", "drinks", "experience", "scenic", "sweet", "night"],
                minimumDesiredResults: 36,
                maxResults: 64,
                maxPerCategory: 6,
                maxPerGroup: 14
            )

        case .fun:
            return SearchPlan(
                queries: [
                    SearchQuerySpec(query: "arcade", category: "arcade", group: "games", maxResults: 8),
                    SearchQuerySpec(query: "game center", category: "game center", group: "games", maxResults: 8),
                    SearchQuerySpec(query: "karaoke", category: "karaoke", group: "games", maxResults: 8),
                    SearchQuerySpec(query: "bowling alley", category: "bowling", group: "games", maxResults: 7),
                    SearchQuerySpec(query: "billiards", category: "billiards", group: "games", maxResults: 6),
                    SearchQuerySpec(query: "darts bar", category: "darts bar", group: "games", maxResults: 6),
                    SearchQuerySpec(query: "board game cafe", category: "board game cafe", group: "games", maxResults: 6),
                    SearchQuerySpec(query: "vr arcade", category: "vr arcade", group: "games", maxResults: 6),
                    SearchQuerySpec(query: "escape room", category: "escape room", group: "activity", maxResults: 7),
                    SearchQuerySpec(query: "mini golf", category: "mini golf", group: "activity", maxResults: 6),
                    SearchQuerySpec(query: "amusement center", category: "amusement center", group: "activity", maxResults: 6),
                    SearchQuerySpec(query: "trampoline park", category: "trampoline park", group: "activity", maxResults: 5),
                    SearchQuerySpec(query: "roller skating rink", category: "roller skating", group: "activity", maxResults: 5),
                    SearchQuerySpec(query: "theme cafe", category: "theme cafe", group: "food", maxResults: 6),
                    SearchQuerySpec(query: "dessert cafe", category: "dessert cafe", group: "food", maxResults: 6),
                    SearchQuerySpec(query: "street food", category: "street food", group: "food", maxResults: 6),
                    SearchQuerySpec(query: "cinema", category: "cinema", group: "night", maxResults: 6)
                ],
                fallbackQueries: [
                    SearchQuerySpec(query: "sports bar", category: "sports bar", group: "food", maxResults: 6),
                    SearchQuerySpec(query: "comedy club", category: "comedy club", group: "night", maxResults: 5),
                    SearchQuerySpec(query: "laser tag", category: "laser tag", group: "activity", maxResults: 5),
                    SearchQuerySpec(query: "live music venue", category: "live music", group: "night", maxResults: 5),
                    SearchQuerySpec(query: "food hall", category: "food hall", group: "food", maxResults: 6)
                ],
                orderedGroups: ["games", "activity", "food", "night"],
                minimumDesiredResults: 30,
                maxResults: 56,
                maxPerCategory: 6,
                maxPerGroup: 16
            )

        case .adventure:
            return SearchPlan(
                queries: [
                    SearchQuerySpec(query: "amusement park", category: "amusement park", group: "outdoor", maxResults: 7),
                    SearchQuerySpec(query: "zoo", category: "zoo", group: "outdoor", maxResults: 7),
                    SearchQuerySpec(query: "aquarium", category: "aquarium", group: "outdoor", maxResults: 7),
                    SearchQuerySpec(query: "park", category: "park", group: "outdoor", maxResults: 10),
                    SearchQuerySpec(query: "hiking trail", category: "hiking", group: "outdoor", maxResults: 7),
                    SearchQuerySpec(query: "botanical garden", category: "botanical garden", group: "outdoor", maxResults: 6),
                    SearchQuerySpec(query: "campground", category: "campground", group: "outdoor", maxResults: 5),
                    SearchQuerySpec(query: "observation deck", category: "observation deck", group: "views", maxResults: 6),
                    SearchQuerySpec(query: "ferris wheel", category: "ferris wheel", group: "views", maxResults: 5),
                    SearchQuerySpec(query: "scenic point", category: "scenic point", group: "views", maxResults: 6),
                    SearchQuerySpec(query: "museum", category: "museum", group: "culture", maxResults: 6),
                    SearchQuerySpec(query: "science museum", category: "science museum", group: "culture", maxResults: 6),
                    SearchQuerySpec(query: "climbing gym", category: "climbing gym", group: "activity", maxResults: 6),
                    SearchQuerySpec(query: "activity center", category: "activity center", group: "activity", maxResults: 6),
                    SearchQuerySpec(query: "rope course", category: "rope course", group: "activity", maxResults: 5),
                    SearchQuerySpec(query: "boat rental", category: "boat rental", group: "activity", maxResults: 5)
                ],
                fallbackQueries: [
                    SearchQuerySpec(query: "landmark", category: "landmark", group: "culture", maxResults: 6),
                    SearchQuerySpec(query: "waterfall", category: "waterfall", group: "views", maxResults: 4),
                    SearchQuerySpec(query: "nature reserve", category: "nature reserve", group: "outdoor", maxResults: 5),
                    SearchQuerySpec(query: "cycling trail", category: "cycling trail", group: "activity", maxResults: 5)
                ],
                orderedGroups: ["outdoor", "views", "activity", "culture"],
                minimumDesiredResults: 32,
                maxResults: 60,
                maxPerCategory: 6,
                maxPerGroup: 18
            )
        }
    }

    private func deduplicatePlaces(_ places: [PlaceCandidate]) -> [PlaceCandidate] {
        let grouped = Dictionary(grouping: places) { place in
            "\(normalized(place.name))|\(normalized(place.address))"
        }

        return grouped.compactMap { _, matches in
            matches.sorted(by: sortByQuality).first
        }
    }

    private func balancePlaces(
        _ places: [PlaceCandidate],
        orderedGroups: [String],
        orderedCategories: [String],
        maxResults: Int,
        maxPerCategory: Int,
        maxPerGroup: Int
    ) -> [PlaceCandidate] {
        let categoryOrder = Dictionary(uniqueKeysWithValues: orderedCategories.enumerated().map { ($1, $0) })

        let interleavedByGroup: [String: [PlaceCandidate]] = Dictionary(
            uniqueKeysWithValues: Dictionary(grouping: places, by: \.group).map { group, matches in
                (
                    group,
                    interleaveCategories(
                        matches,
                        categoryOrder: categoryOrder,
                        maxPerCategory: maxPerCategory,
                        maxPerGroup: maxPerGroup
                    )
                )
            }
        )

        let fallbackGroups = interleavedByGroup.keys
            .filter { !orderedGroups.contains($0) }
            .sorted()

        let groupOrder = orderedGroups + fallbackGroups
        var groupQueues = interleavedByGroup
        var results: [PlaceCandidate] = []
        var didAppend = true

        while results.count < maxResults && didAppend {
            didAppend = false

            for group in groupOrder {
                guard var queue = groupQueues[group], !queue.isEmpty else { continue }
                results.append(queue.removeFirst())
                groupQueues[group] = queue
                didAppend = true

                if results.count >= maxResults {
                    break
                }
            }
        }

        return results
    }

    private func interleaveCategories(
        _ places: [PlaceCandidate],
        categoryOrder: [String: Int],
        maxPerCategory: Int,
        maxPerGroup: Int
    ) -> [PlaceCandidate] {
        let groupedByCategory = Dictionary(grouping: places.sorted(by: sortByQuality), by: \.category)
        let orderedCategories = groupedByCategory.keys.sorted {
            let leftOrder = categoryOrder[$0] ?? .max
            let rightOrder = categoryOrder[$1] ?? .max
            if leftOrder == rightOrder {
                return $0 < $1
            }
            return leftOrder < rightOrder
        }

        var categoryQueues: [String: [PlaceCandidate]] = [:]
        for category in orderedCategories {
            categoryQueues[category] = Array(groupedByCategory[category, default: []].prefix(maxPerCategory))
        }

        var results: [PlaceCandidate] = []
        var didAppend = true

        while results.count < maxPerGroup && didAppend {
            didAppend = false

            for category in orderedCategories {
                guard var queue = categoryQueues[category], !queue.isEmpty else { continue }
                results.append(queue.removeFirst())
                categoryQueues[category] = queue
                didAppend = true

                if results.count >= maxPerGroup {
                    break
                }
            }
        }

        return results
    }

    private func sortByQuality(_ lhs: PlaceCandidate, _ rhs: PlaceCandidate) -> Bool {
        if abs(lhs.distanceFromCenter - rhs.distanceFromCenter) > 1 {
            return lhs.distanceFromCenter < rhs.distanceFromCenter
        }

        return normalized(lhs.name) < normalized(rhs.name)
    }

    private func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
    }

    private func uniquePreservingOrder(_ values: [String]) -> [String] {
        var seen: Set<String> = []

        return values.filter { value in
            seen.insert(value).inserted
        }
    }

    private func validateSearchPlan(_ searchPlan: SearchPlan, mood: DateMood) {
        #if DEBUG
        let allSpecs = searchPlan.queries + searchPlan.fallbackQueries

        let duplicateCategories = Dictionary(grouping: allSpecs, by: \.category)
            .filter { $0.value.count > 1 }
            .keys
            .sorted()

        if !duplicateCategories.isEmpty {
            assertionFailure("Duplicate categories in MapSearchService for mood \(mood.rawValue): \(duplicateCategories.joined(separator: ", "))")
        }

        let duplicateQueryPairs = Dictionary(grouping: allSpecs) { "\($0.group)|\($0.query.lowercased())" }
            .filter { $0.value.count > 1 }
            .keys
            .sorted()

        if !duplicateQueryPairs.isEmpty {
            assertionFailure("Duplicate search query/group pairs in MapSearchService for mood \(mood.rawValue): \(duplicateQueryPairs.joined(separator: ", "))")
        }
        #endif
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

private struct SearchPlan {
    let queries: [SearchQuerySpec]
    let fallbackQueries: [SearchQuerySpec]
    let orderedGroups: [String]
    let minimumDesiredResults: Int
    let maxResults: Int
    let maxPerCategory: Int
    let maxPerGroup: Int
}

private struct SearchQuerySpec {
    let query: String
    let category: String
    let group: String
    let maxResults: Int
}
