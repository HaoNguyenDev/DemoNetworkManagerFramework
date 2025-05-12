//
//  NetworkingDemo.swift
//  DemoNetworkManagerFramework
//
//  Created by Hao Nguyen on 10/5/25.
//

import Foundation
import Combine

//MARK: Custom Error
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
        case .clientError(let code):
            return "Client error with status code: \(code)"
        case .serverError(let code):
            return "Server error with status code: \(code)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .other(let error):
            return "Unexpected error: \(error.localizedDescription)"
        }
    }
}

//MARK: NetworkingManager
protocol NetworkingManagerProtocol {
    func fetchWithCompletion<T: Decodable>(from url: URL, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void)
    func fetchWithPublisher<T: Decodable>(from url: URL, responseType: T.Type) -> AnyPublisher<T, Error>
    func fetchWithAsync<T: Decodable>(from url: URL, responseType: T.Type) async throws -> T
}

class NetworkingManager: NetworkingManagerProtocol {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchWithCompletion<T: Decodable>(from url: URL, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard !url.absoluteString.isEmpty else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error as? URLError {
                completion(.failure(NetworkingError.networkError(error.localizedDescription)))
                return
            } else if let error = error {
                completion(.failure(NetworkingError.other(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkingError.invalidResponse))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkingError.getErrorWith(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkingError.invalidResponse))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(NetworkingError.decodingFailed))
            }
        }.resume()
    }
    
    func fetchWithPublisher<T: Decodable>(from url: URL, responseType: T.Type) -> AnyPublisher<T, Error> {
        guard !url.absoluteString.isEmpty else {
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
    
    func fetchWithAsync<T: Decodable>(from url: URL, responseType: T.Type) async throws -> T {
        guard !url.absoluteString.isEmpty else {
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
            return try JSONDecoder().decode(T.self, from: data)
        } catch let error as URLError {
            throw NetworkingError.networkError(error.localizedDescription)
        } catch {
            throw NetworkingError.other(error)
        }
    }
}

//MARK: Model
struct User: Decodable {
    let name: String
}

// MARK: UserService
protocol UserServiceProtocol {
    func fetchUsersWithCompletion(url: URL, completion: @escaping (Result<[User], Error>) -> Void)
    func fetchUsersWithPublisher(url: URL) -> AnyPublisher<[User], Error>
    func fetchUsersWithAsync(url: URL) async throws -> [User]
}

class UserService: UserServiceProtocol {
    let networkingManager: NetworkingManagerProtocol
    
    init(networkingManager: NetworkingManagerProtocol = NetworkingManager()) {
        self.networkingManager = networkingManager
    }
    
    func fetchUsersWithCompletion(url: URL, completion: @escaping (Result<[User], Error>) -> Void) {
        networkingManager.fetchWithCompletion(from: url, responseType: [User].self, completion: completion)
    }
    
    func fetchUsersWithPublisher(url: URL) -> AnyPublisher<[User], Error> {
        networkingManager.fetchWithPublisher(from: url, responseType: [User].self)
    }
    
    func fetchUsersWithAsync(url: URL) async throws -> [User] {
        try await networkingManager.fetchWithAsync(from: url, responseType: [User].self)
    }
}


//MARK: ViewModel
class ViewModel {
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var users: [User] = []
    @Published var error: Error?
    
    let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    func fetchDataWithAsync() {
        Task {
            do {
                let url = URL(string: "https:github.com/users")!
                let usersData = try await userService.fetchUsersWithAsync(url: url)
                self.users = usersData
            } catch {
                self.error = error
            }
        }
    }
    
    func fetchDataWithCombine() {
        let url = URL(string: "https:github.com/users")!
        userService.fetchUsersWithPublisher(url: url)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let err) = completion {
                    self?.error = err
                }
            } receiveValue: { [weak self] users in
                self?.users = users
            }
            .store(in: &cancellables)
    }
    
    func fetchDataWithCompletion() {
        let url = URL(string: "https:github.com/users")!
        userService.fetchUsersWithCompletion(url: url) { [weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self?.users = users
                case .failure(let error):
                    self?.error = error
                }
            }
            
        }
    }
}
