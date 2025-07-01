//
//  NetWorkError.swift
//  DemoNetworkManagerFramework
//
//  Created by Hao Nguyen on 2/5/25.
//


import Foundation

// MARK: - Custom NetworkError
public enum NetworkError: Error {
    case invalidURL
    case invalidData
    case invalidResponse(statusCode: Int)
    case decodingError(error: Error)
    case networkError(error: Error)
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case unknownError(statusCode: Int)
    
    public var errorDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidData:
            return "Invalid Data"
        case .invalidResponse(let statusCode):
            return "Invalid Response: \(statusCode)"
        case .clientError(let statusCode):
            return "Client Error: \(statusCode)"
        case .serverError(let statusCode):
            return "Server Error: \(statusCode)"
        case .decodingError(error: let error):
            return "Decoding Error: \(error.localizedDescription)"
        case .networkError(error: let error):
            return "Network Error: \(error.localizedDescription)"
        case .unknownError(let statusCode):
            return "Unknown Error Code: \(statusCode)"
        }
    }
}
