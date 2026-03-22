//
//  DataRequestData.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/21.
//

import Foundation
import CoreLocation

struct DateRequestData {
    let budget: Int
    let currency: CurrencyOption
    
    let locationName: String
    let latitude: Double
    let longitude: Double
    let radius: CLLocationDistance
    
    let mood: DateMood
    let ideas: String
    
    var hasUserIdeas: Bool {
        !ideas.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var cleanedIdeas: String {
        ideas.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var ideasForLLM: String {
        cleanedIdeas.isEmpty
        ? "The user has no specific ideas and is open to suggestions"
        : cleanedIdeas
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var debugDescription: String {
        """
        Budget: \(budget)\(currency.rawValue)
        Location: \(locationName)
        Coordinates: (\(latitude), \(longitude))
        Radius: \(Int(radius))m
        Mood: \(mood.rawValue)
        Ideas: \(cleanedIdeas)
        """
    }
}
