//
//  GitHubUserListVM.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import Combine
import Foundation

// MARK: - Support for Loadmore
struct PaginationConfig {
    var perPage: Int
    var since: Int
}

// MARK: - UserListViewModel Protocol
protocol GitHubUserListVMProtocol {
    var users: [User] { get }
    var isLoading: Bool { get }
    var error: Error? { get }
    func fetchUsers() async
    func loadMoreUser() async
    func updatePagination(from users: [User])
}

class GitHubUserListVM: ObservableObject, GitHubUserListVMProtocol {
    
    @Published var users: [User] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    private let networkService: GitHubServiceProtocol
    private var paginationConfig: PaginationConfig
    
    init(networkService: GitHubServiceProtocol = GitHubNetworkService(),
         paginationConfig: PaginationConfig = PaginationConfig(perPage: 20, since: 0)) {
        self.networkService = networkService
        self.paginationConfig = paginationConfig
    }
}

// MARK: - Public Methods
extension GitHubUserListVM {
    func fetchUsers() async {
        await performWithLoading {
            do {
                var newUsers: [User] = []
                newUsers = try await networkService.fetchUsers(perPage: paginationConfig.perPage,
                                                            since: paginationConfig.since)
                updateUsers(newUsers)
                updatePagination(from: newUsers)
            } catch {
                self.error = error
            }
        }
    }
    
    func loadMoreUser() async {
        await performWithLoading {
            let newUsers = try await networkService.fetchUsers(perPage: paginationConfig.perPage,
                                                               since: paginationConfig.since)
            appendUsers(newUsers)
            updatePagination(from: newUsers)
        }
    }
    
    func updatePagination(from users: [User]) {
        if let lastUserId = users.last?.id {
            paginationConfig.since = lastUserId
        }
    }
}

// MARK: - Private Helper Methods
extension GitHubUserListVM {
    @MainActor
    private func performWithLoading(_ operation: () async throws -> Void) async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            try await operation()
        } catch {
            self.error = error
        }
    }
    
    private func updateUsers(_ newUsers: [User]) {
        DispatchQueue.main.async { [weak self] in
            self?.users = newUsers
        }
    }
    
    private func appendUsers(_ newUsers: [User]) {
        DispatchQueue.main.async { [weak self] in
            self?.users.append(contentsOf: newUsers)
        }
    }
}
