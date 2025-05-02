//
//  GitHubService.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import DemoNetworkManagerFramework

// MARK: - GitHubServiceProtocol
protocol GitHubServiceProtocol {
    func fetchUsers(perPage: Int, since: Int) async throws -> [User]
    func fetchUserDetail(by username: String) async throws -> UserDetail
}

// MARK: - GitHubNetworkService
class GitHubNetworkService: GitHubServiceProtocol {
    private let networkManager: NetworkService
    
    init(networkManager: NetworkService = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func fetchUsers(perPage: Int, since: Int) async throws -> [User] {
        let endpoint = GitHubAPIEndpoint.getUsersEndpoint(perPage: perPage, since: since)
        return try await networkManager.fetchData(endpoint: endpoint, responseType: [User].self)
    }
    
    func fetchUserDetail(by username: String) async throws -> UserDetail {
        let endpoint = GitHubAPIEndpoint.getUserDetailEndpoint(username: username)
        return try await networkManager.fetchData(endpoint: endpoint, responseType: UserDetail.self)
    }
}
