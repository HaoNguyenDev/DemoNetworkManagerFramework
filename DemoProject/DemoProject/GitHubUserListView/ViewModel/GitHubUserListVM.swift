//
//  GitHubUserListVM.swift
//  DemoProject
//
//  Created by Hao Nguyen on 2/5/25.
//

import Combine
import Foundation
import DemoNetworkManagerFramework

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
    private let networkService: GithubServiceProtocol
    private var paginationConfig: PaginationConfig
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(networkService: GithubServiceProtocol = GitHubNetworkService(),
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
            do {
                let newUsers = try await networkService.fetchUsers(perPage: paginationConfig.perPage,
                                                                   since: paginationConfig.since)
                appendUsers(newUsers)
                updatePagination(from: newUsers)
            } catch {
                self.error = error
            }
        }
    }
    
    func fetchUser2() {
        networkService.fetchUsersWithCombine(perPage: paginationConfig.perPage, since: paginationConfig.since)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }) { [weak self] newUsers in
                self?.updateUsers(newUsers)
                self?.updatePagination(from: newUsers)
            }
            .store(in: &cancellables)
    }
    
    func loadMoreUser2() {
        networkService.fetchUsersWithCombine(perPage: paginationConfig.perPage, since: paginationConfig.since)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }) { [weak self] newUsers in
                self?.appendUsers(newUsers)
                self?.updatePagination(from: newUsers)
            }
            .store(in: &cancellables)
    }
    
    func updatePagination(from users: [User]) {
        if let lastUserId = users.last?.id {
            paginationConfig.since = lastUserId
        }
    }
    
    func loadMoreDataIfNeed(currentUser: User) {
        guard let lastUser = users.last, currentUser == lastUser,
        !isLoading,
        !users.isEmpty else { return }
        #if DEBUG
        print(">>> Load more data from user withID \(String(describing: currentUser.id))")
        #endif
        /* load more if scroll to the last user */
//        Task {
//            await loadMoreUser()
//        }
        loadMoreUser2()
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
