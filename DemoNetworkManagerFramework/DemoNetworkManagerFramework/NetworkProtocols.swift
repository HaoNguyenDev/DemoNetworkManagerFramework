//
//  NetworkProtocols.swift
//  DemoNetworkManagerFramework
//
//  Created by Hao Nguyen on 2/5/25.
//

import Foundation

// MARK: - Define HTTP
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Endpoint
public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: [String: String]? { get }
    var headers: [String: String]? { get }
}

// MARK: - NetworkService
public protocol NetworkService {
    func fetchData<T: Decodable>(endpoint: Endpoint, responseType: T.Type) async throws -> T
}

