//
//  DateGenerationService.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/21.
//

import Foundation

final class DateGenerationService {
    
    func generateDatePlan(request: DateRequestData, places: [PlaceCandidate]) async throws -> GeneratedDatePlan {
        
        
        /// URL LOCAL : "http://localhost:3000/generate-date-plan"
        // Prepare URL
        guard let url = URL(string: "https://dateplanner-back.onrender.com/generate-date-plan") else {
            throw URLError(.badURL)
        }
        
        // Build request body
        let body: [String: Any] = [
            "request": [
                "budget": request.budget,
                "currency": request.currency.rawValue,
                "locationName": request.locationName,
                "mood": request.mood.rawValue,
                "ideasForLLM": request.ideasForLLM
            ],
            "places": places.map { place in
                [
                    "name": place.name,
                    "category": place.category,
                    "distanceFromCenter": place.distanceFromCenter,
                    "address": place.address
                ]
            }
        ]
        
        // Create URLRequest
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // Call backend
        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        // Debug
        if let jsonString = String(data: data, encoding: .utf8) {
            print("=== BACKEND RESPONSE ===")
            print(jsonString)
        }
        
        // Decode response
        let plan = try JSONDecoder().decode(GeneratedDatePlan.self, from: data)
        return plan
    }
    
    private func buildPrompt(request: DateRequestData, places: [PlaceCandidate]) -> String {
        
        let placesText = places.prefix(40).enumerated().map {index, place in
            "\(index + 1). \(place.name) | \(place.category) | \(Int(place.distanceFromCenter))m | \(place.address)"
        }.joined(separator: "\n")
        
        return """
            You are an expert date planner.
            
            Create a date plan based on the following user preferences.
            
            USER:
            - Budget: \(request.budget)\(request.currency.rawValue)
            - Location: \(request.locationName)
            - Mood: \(request.mood.rawValue)
            - Ideas: \(request.ideasForLLM)
            
            AVAILABLE PLACES:
            \(placesText)
            
            INSTRUCTIONS:
            - Select 2 to 4 stops
            - Create a logical and enjoyable flow
            - Mix variety when possible (e.g cafe, activity, restaurant)
            - Prefer places that are reasonably close to each other
            - Stay within budget
            - Use ONLY places from the AVAILABLE PLACES list above
            - NEVER invent, rename, or substitute a place
            - Keep the exact name, category, address, latitude, and longitude of each selected place from the provided data
            - If there are not enough good options, use fewer stops rather than inventing new ones
            - If the list is empty, return an empty stops array
            
            IMPORTANT: Every stop in the JSON must match one place from AVAILABLE PLACES exactly.
            OUTPUT FORMAT (JSON):
            {
                "title": "...",
                "summary": "...",
                "stops": [
                    {
                        "name": "...",
                        "description": "...",
                        "reason": "...",
                        "category": "...",
                        "address": "Use the exact address from AVAILABLE PLACES",
                        "latitude": 0,
                        "longitude": 0,
                        "order": 1,
                        "estimatedPrice": 0
                    }
                ]
            }
            """
    }
    
    private func mockPlan() -> GeneratedDatePlan {
        return GeneratedDatePlan(
                title: "Chill Evening in Tokyo",
                summary: "A relaxed and cozy date with a mix of coffee and a nice dinner.",
                stops: [
                    GeneratedDateStop(
                        name: "Shibuya Cafe",
                        description: "Start with a calm coffee in a cozy atmosphere.",
                        order: 1,
                        reason: "Good place to start the date and talk",
                        imageURL: nil,
                        category: "cafe",
                        address: "Shibuya",
                        latitude: 0,
                        longitude: 0,
                        estimatedPrice: 1000
                    ),
                    GeneratedDateStop(
                        name: "Local Restaurant",
                        description: "Enjoy a nice dinner together.",
                        order: 2,
                        reason: "Main moment of the date",
                        imageURL: nil,
                        category: "restaurant",
                        address: "Shibuya",
                        latitude: 0,
                        longitude: 0,
                        estimatedPrice: 3000
                    )
                ]
            )
        
    }
    
    private func parsePlan(from jsonString: String) throws -> GeneratedDatePlan {
        let data = Data(jsonString.utf8)
        return try JSONDecoder().decode(GeneratedDatePlan.self, from: data)
    }
}
