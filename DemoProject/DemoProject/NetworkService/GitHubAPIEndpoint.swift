//
//  GitHubAPIEndpoint.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import DemoNetworkManagerFramework

// MARK: - Define GitHubAPIEndpoint
struct GitHubAPIEndpoint: Endpoint {
    var baseURL: String = "https://api.github.com"
    var path: String
    var method: HTTPMethod
    var queryParameters: [String : String]?
    var headers: [String : String]?
    
    static func getUsersEndpoint(perPage: Int, since: Int) -> GitHubAPIEndpoint {
        return GitHubAPIEndpoint(path: "/users",
                                method: .get,
                                queryParameters: ["per_page": String(perPage), "since": String(since)],
                                headers: ["Content-Type": "application/json;charset=utf-8"])
    }
    
    static func getUserDetailEndpoint(username: String) -> GitHubAPIEndpoint {
        return GitHubAPIEndpoint(
            path: "/users/\(username)",
            method: .get,
            queryParameters: nil,
            headers: ["Content-Type": "application/json;charset=utf-8"]
        )
    }
}
