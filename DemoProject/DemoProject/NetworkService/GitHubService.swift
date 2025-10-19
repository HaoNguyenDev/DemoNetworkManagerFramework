//
//  GitHubService.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import DemoNetworkManagerFramework
import Combine

// MARK: - GitHubServiceProtocol
protocol GithubServiceProtocol {
    func fetchUsers(perPage: Int, since: Int) async throws -> [User]
    func fetchUserDetail(by username: String) async throws -> UserDetail
    
    func fetchUsersWithCombine(perPage: Int, since: Int) -> AnyPublisher<[User], Error>
    func fetchUserWithResult(perPage: Int, since: Int, completion: @escaping (Result<[User], Error>) -> Void)
}

// MARK: - GitHubNetworkService
class GitHubNetworkService: GithubServiceProtocol {
    private let networkManager: NetworkServiceProtocol
    
    init(networkManager: NetworkServiceProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func fetchUsers(perPage: Int, since: Int) async throws -> [User] {
        let endpoint = GithubAPIEndpoint.getUsersEndpoint(perPage: perPage, since: since)
        return try await networkManager.requestAsync(endpoint: endpoint)
    }
    
    func fetchUserDetail(by username: String) async throws -> UserDetail {
        let endpoint = GithubAPIEndpoint.getUserDetailEndpoint(username: username)
        return try await networkManager.requestAsync(endpoint: endpoint)
    }
    
    func fetchUsersWithCombine(perPage: Int, since: Int) -> AnyPublisher<[User], Error> {
        let endpoint = GithubAPIEndpoint.getUsersEndpoint(perPage: perPage, since: since)
        return networkManager.requestPublisher(endpoint: endpoint)
    }
    
    func fetchUserWithResult(perPage: Int, since: Int, completion: @escaping (Result<[User], Error>) -> Void) {
        let endpoint = GithubAPIEndpoint.getUsersEndpoint(perPage: perPage, since: since)
        return networkManager.requestCallback(endpoint: endpoint, completion: completion)
    }
}
