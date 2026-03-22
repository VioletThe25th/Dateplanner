//
//  GeneratedDatePlan.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/21.
//

struct GeneratedDatePlan: Decodable {
    let title: String
    let summary: String
    let stops: [GeneratedDateStop]
}

struct GeneratedDateStop: Decodable {
    let name: String
    let description: String
    let order: Int
    let reason: String
    let imageURL: String?
    let category: String?
    let address: String?
    let latitude: Double
    let longitude: Double
    let estimatedPrice: Int?
}
