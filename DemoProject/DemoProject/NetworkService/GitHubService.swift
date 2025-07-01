//
//  GitHubService.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import DemoNetworkManagerFramework
import Combine

// MARK: - GitHubServiceProtocol
protocol GitHubServiceProtocol {
    func fetchUsers(perPage: Int, since: Int) async throws -> [User]
    func fetchUserDetail(by username: String) async throws -> UserDetail
    
    func fetchUsersWithCombine(perPage: Int, since: Int) -> AnyPublisher<[User], Error>
    func fetchUserWithResult(perPage: Int, since: Int, completion: @escaping (Result<[User], Error>) -> Void)
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
    
    func fetchUsersWithCombine(perPage: Int, since: Int) -> AnyPublisher<[User], Error> {
        let endpoint = GitHubAPIEndpoint.getUsersEndpoint(perPage: perPage, since: since)
        return networkManager.fetchData(endpoint: endpoint, responseType: [User].self)
    }
    
    func fetchUserWithResult(perPage: Int, since: Int, completion: @escaping (Result<[User], Error>) -> Void) {
        let endpoint = GitHubAPIEndpoint.getUsersEndpoint(perPage: perPage, since: since)
        return networkManager.fetchData(endpoint: endpoint, responseType: [User].self, completion: completion)
    }
}
