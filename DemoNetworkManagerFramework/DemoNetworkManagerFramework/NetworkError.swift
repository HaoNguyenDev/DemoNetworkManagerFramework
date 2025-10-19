//
//  NetWorkError.swift
//  DemoNetworkManagerFramework
//
//  Created by Hao Nguyen on 2/5/25.
//

import Foundation

// MARK: - NetworkError
public enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case invalidData
    case networkError(error: Error) // Include URLError (timeout, no connection)
    case invalidResponse(statusCode: Int)
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case decodingError(error: Error)
    case unknownError(statusCode: Int)
    
    // errorDescription of LocalizedError
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided."
        case .invalidData:
            return "Invalid Data"
        case .networkError(let error):
            return "Network connection failed: \(error.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "Invalid HTTP Response received. Status code: \(statusCode)"
        case .clientError(let statusCode):
            return "Client error (4xx). Status code: \(statusCode)"
        case .serverError(let statusCode):
            return "Server error (5xx). Status code: \(statusCode)"
        case .decodingError(let error):
            return "Data decoding failed: \(error.localizedDescription)"
        case .unknownError(let statusCode):
            return "An unknown error occurred. Status code: \(statusCode)"
        }
    }
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL): return true
        case (.invalidResponse(let lhsCode), .invalidResponse(let rhsCode)),
             (.clientError(let lhsCode), .clientError(let rhsCode)),
             (.serverError(let lhsCode), .serverError(let rhsCode)),
             (.unknownError(let lhsCode), .unknownError(let rhsCode)):
            return lhsCode == rhsCode
        case (.networkError, .networkError),
             (.decodingError, .decodingError):
            return true
        default:
            return false
        }
    }
}

enum AppError: Error {
    case generic(String)
    case custom(Error)
}
