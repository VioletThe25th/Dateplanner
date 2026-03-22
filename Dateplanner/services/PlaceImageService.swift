
//
//  PlaceImageService.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/22.
//

import Foundation
import MapKit
import UIKit

final class PlaceImageService {
    
    func fetchImage(for stop: GeneratedDateStop) async -> UIImage? {
        let baseCoordinate = CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
        
        // Try to find a better map item using the place name first.
        if let refinedCoordinate = await refinedCoordinate(for: stop) {
            if let image = await lookAroundImage(for: refinedCoordinate) {
                return image
            }
        }
        
        // Fallback to the original coordinates from the generated stop.
        return await lookAroundImage(for: baseCoordinate)
    }

    private func refinedCoordinate(for stop: GeneratedDateStop) async -> CLLocationCoordinate2D? {
        let baseCoordinate = CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
        let searchRequest = MKLocalSearch.Request()
        
        if let address = stop.address, !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searchRequest.naturalLanguageQuery = "\(stop.name), \(address)"
        } else {
            searchRequest.naturalLanguageQuery = stop.name
        }
        
        searchRequest.region = MKCoordinateRegion(
            center: baseCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        do {
            let search = MKLocalSearch(request: searchRequest)
            let response = try await search.start()
            
            guard !response.mapItems.isEmpty else { return nil }
            
            let bestItem = response.mapItems.min { lhs, rhs in
                let lhsDistance = lhs.location.distance(from: CLLocation(latitude: baseCoordinate.latitude, longitude: baseCoordinate.longitude))
                let rhsDistance = rhs.location.distance(from: CLLocation(latitude: baseCoordinate.latitude, longitude: baseCoordinate.longitude))
                return lhsDistance < rhsDistance
            }
            
            return bestItem?.location.coordinate
        } catch {
            print("Refined coordinate search error:", error)
            return nil
        }
    }
    
    private func lookAroundImage(for coordinate: CLLocationCoordinate2D) async -> UIImage? {
        let sceneRequest = MKLookAroundSceneRequest(coordinate: coordinate)
        
        do {
            guard let scene = try await sceneRequest.scene else { return nil }
            
            let snapshotOptions = MKLookAroundSnapshotter.Options()
            snapshotOptions.size = CGSize(width: 600, height: 700)
            snapshotOptions.pointOfInterestFilter = .includingAll
            
            let snapshotter = MKLookAroundSnapshotter(scene: scene, options: snapshotOptions)
            let snapshot = try await snapshotter.snapshot
            return snapshot.image
            
        } catch {
            print("Look Around snapshot error:", error)
            return nil
        }
    }
}
