//
//  NetworkProtocols.swift
//  DemoNetworkManagerFramework
//
//  Created by Hao Nguyen on 2/5/25.
//

import Foundation
import Combine

// MARK: - Define HTTP
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Endpoint Protocol
public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    
    // Query for GET and Body for POST/PUT
    var queryItems: [URLQueryItem]? { get } // (queryParameters -> queryItems)
    var body: Data? { get } // Body for POST/PUT/PATCH
}

//extension Endpoint {
//    var queryItems: [URLQueryItem]? { nil }
//    var headers: [String: String]? { nil }
//    var body: Data? { nil }
//}

// MARK: - NetworkService Protocol
public protocol NetworkServiceProtocol: AnyObject { // AnyObject for Reference Type (weak referrence)
    
    // Async/Await
    func requestAsync<T: Decodable>(endpoint: Endpoint) async throws -> T
    
    // Combine Publisher
    func requestPublisher<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, Error>
    
    // Callback
    func requestCallback<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void)
}
