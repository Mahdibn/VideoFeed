//
//  APIError.swift
//  VideoFeed
//
//  Created by Mehdi Bahreini Nejad on 26.06.25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case networkError(Error)
    case invalidResponse
    case noData
    case simulationError

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription). Please check your internet connection."
        case .invalidResponse:
            return "Invalid server response. Please try again."
        case .noData:
            return "No data received from the server."
        case .simulationError:
            return "A simulated network error occurred. Please retry."
        }
    }
}
