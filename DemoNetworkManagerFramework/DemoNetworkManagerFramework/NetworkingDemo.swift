//
//  NetworkingDemo.swift
//  DemoNetworkManagerFramework
//
//  Created by Hao Nguyen on 10/5/25.
//

import Foundation
import Combine

enum NetworkingError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case networkError(String)
    case other(Error)
    
    static func getErrorWith(statusCode code: Int) -> Self {
        switch code {
        case 400..<500:
            return .clientError(statusCode: code)
        case 500..<600:
            return .serverError(statusCode: code)
        default:
            return .other(NSError(domain: "NetworkingError", code: code, userInfo: [NSLocalizedDescriptionKey: "Unknown status code"]))
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid HTTP response"
        case .decodingFailed:
            return "Failed to decode response data"
        case .clientError(statusCode: let code):
            return "Client error with status code: \(code)"
        case .serverError(statusCode: let code):
            return "Server error with status code: \(code)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .other(let error):
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
}

protocol NetworkingDemoProtocol {
    func fetchData<T: Decodable>(from url: URL) -> AnyPublisher<T, any Error>
    func fetchData<T: Decodable>(from url: URL) async throws -> T
}

class NetworkingDemo: NetworkingDemoProtocol {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchData<T: Decodable>(from url: URL) -> AnyPublisher<T, any Error> {
        guard url.absoluteString.isEmpty == false else {
            return Fail(error: NetworkingError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkingError.invalidResponse
                }
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    throw NetworkingError.getErrorWith(statusCode: httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                switch error {
                case is URLError:
                    return NetworkingError.networkError(error.localizedDescription)
                case is DecodingError:
                    return NetworkingError.decodingFailed
                case let networkingError as NetworkingError:
                    return networkingError
                default:
                    return NetworkingError.other(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchData<T: Decodable>(from url: URL) async throws -> T {
        guard url.absoluteString.isEmpty == false else {
            throw NetworkingError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkingError.invalidResponse
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkingError.getErrorWith(statusCode: httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkingError.decodingFailed
            }
        } catch {
            if let urlError = error as? URLError {
                throw NetworkingError.networkError(urlError.localizedDescription)
            }
            throw NetworkingError.other(error)
        }
    }
}
