//
//  PlaceCandidate.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/21.
//

import Foundation
import CoreLocation

struct PlaceCandidate: Identifiable {
    let id = UUID()
    
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let category: String
    let distanceFromCenter: CLLocationDistance
}
