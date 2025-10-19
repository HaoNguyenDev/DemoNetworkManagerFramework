//
//  GitHubAPIEndpoint.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import DemoNetworkManagerFramework
import Foundation

// MARK: - GithubAPIEndpoint Implementation
struct GithubAPIEndpoint: Endpoint {
    var baseURL: String = "https://api.github.com"
    var path: String
    var method: HTTPMethod
    var headers: [String : String]?
    var queryItems: [URLQueryItem]?
    var body: Data?
    
    init(path: String, method: HTTPMethod, headers: [String: String]? = nil, queryItems: [URLQueryItem]? = nil, body: Data? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
    
    // MARK: - Factory Methods
    static func getUsersEndpoint(perPage: Int, since: Int) -> GithubAPIEndpoint {
        let queries = [
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "since", value: String(since))
        ]
        
        return GithubAPIEndpoint(
            path: "/users",
            method: .get,
            headers: ["Content-Type": "application/json"],
            queryItems: queries
        )
    }
    
    static func getUserDetailEndpoint(username: String) -> GithubAPIEndpoint {
        return GithubAPIEndpoint(
            path: "/users/\(username)",
            method: .get,
            headers: ["Content-Type": "application/json"]
            // queryItems and body are nil (default)
        )
    }
    
    /// Example for post http method api
    static func createGist(jsonBody: [String: Any]) -> GithubAPIEndpoint? {
        guard let data = try? JSONSerialization.data(withJSONObject: jsonBody, options: []) else {
            return nil
        }
        return GithubAPIEndpoint(
            path: "/gists",
            method: .post,
            headers: [
                "Content-Type": "application/json",
                "Authorization": "token YOUR_ACCESS_TOKEN" // POST thường cần Authorization
            ],
            body: data
        )
    }
}
