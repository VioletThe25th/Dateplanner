//
//  DateGenerationService.swift
//  Dateplanner
//
//  Created by Jeremy Bilger on 2026/03/21.
//

import Foundation

final class DateGenerationService {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private let endpoint = "https://dateplanner-back.onrender.com/generate-date-plan"
    private let requestTimeout: TimeInterval = 30

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func generateDatePlan(request: DateRequestData, places: [PlaceCandidate]) async throws -> GeneratedDatePlan {
        guard let url = URL(string: endpoint) else {
            throw DateGenerationError.invalidEndpoint
        }

        let payload = GenerateDatePlanPayload(
            request: RequestPayload(from: request),
            places: places.map(PlacePayload.init)
        )

        var urlRequest = URLRequest(url: url, timeoutInterval: requestTimeout)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = try encoder.encode(payload)

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DateGenerationError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let responseBody = String(data: data, encoding: .utf8)
            throw DateGenerationError.unsuccessfulStatusCode(
                statusCode: httpResponse.statusCode,
                responseBody: responseBody
            )
        }

        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("=== BACKEND RESPONSE ===")
            print(jsonString)
        }
        #endif

        do {
            return try decoder.decode(GeneratedDatePlan.self, from: data)
        } catch {
            throw DateGenerationError.decodingFailed(underlyingError: error)
        }
    }
}

private struct GenerateDatePlanPayload: Encodable {
    let request: RequestPayload
    let places: [PlacePayload]
}

private struct RequestPayload: Encodable {
    let budget: Int
    let currency: String
    let locationName: String
    let mood: String
    let ideasForLLM: String

    init(from request: DateRequestData) {
        self.budget = request.budget
        self.currency = request.currency.rawValue
        self.locationName = request.locationName
        self.mood = request.mood.rawValue
        self.ideasForLLM = request.ideasForLLM
    }
}

private struct PlacePayload: Encodable {
    let name: String
    let category: String
    let distanceFromCenter: Double
    let address: String

    init(_ place: PlaceCandidate) {
        self.name = place.name
        self.category = place.category
        self.distanceFromCenter = place.distanceFromCenter
        self.address = place.address
    }
}

private enum DateGenerationError: LocalizedError {
    case invalidEndpoint
    case invalidResponse
    case unsuccessfulStatusCode(statusCode: Int, responseBody: String?)
    case decodingFailed(underlyingError: Error)

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "The date generation endpoint is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case let .unsuccessfulStatusCode(statusCode, responseBody):
            if let responseBody, !responseBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "The server returned status \(statusCode): \(responseBody)"
            } else {
                return "The server returned status \(statusCode)."
            }
        case let .decodingFailed(underlyingError):
            return "The generated plan could not be decoded: \(underlyingError.localizedDescription)"
        }
    }
}
