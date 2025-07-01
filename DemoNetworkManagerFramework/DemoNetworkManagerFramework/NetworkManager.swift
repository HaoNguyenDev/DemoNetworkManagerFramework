//
//  NetworkManager.swift
//  DemoNetworkManagerFramework
//
//  Created by Hao Nguyen on 2/5/25.
//

import Foundation
import Combine

// MARK: - NetworkManager
public class NetworkManager: NetworkService {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func fetchData<T: Decodable>(endpoint: Endpoint, responseType: T.Type) async throws -> T {
        let urlRequest = try createURLRequest(from: endpoint)
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: 0)
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return try decodeData(data, to: responseType)
        case 400..<500:
            throw NetworkError.clientError(statusCode: httpResponse.statusCode)
        case 500..<600:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.unknownError(statusCode: httpResponse.statusCode)
        }
    }
    
    public func fetchData<T: Decodable>(endpoint: Endpoint, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        let urlRequest: URLRequest
        do {
            urlRequest = try createURLRequest(from: endpoint)
        } catch {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        session.dataTask(with: urlRequest) { data, response, error in
            if error is URLError {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse(statusCode: 0)))
                return
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                guard let data = data else {
                    completion(.failure(NetworkError.invalidResponse(statusCode: httpResponse.statusCode)))
                    return
                }
                do {
                    let decoded = try self.decodeData(data, to: T.self)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(NetworkError.decodingError(error: error)))
                }
            case 400..<500:
                completion(.failure(NetworkError.clientError(statusCode: httpResponse.statusCode)))
            case 500..<600:
                completion(.failure(NetworkError.serverError(statusCode: httpResponse.statusCode)))
            default:
                completion(.failure(NetworkError.unknownError(statusCode: httpResponse.statusCode)))
            }
        }.resume()
    }
    
    public func fetchData<T: Decodable>(endpoint: Endpoint, responseType: T.Type) -> AnyPublisher<T, Error> {
        let urlRequest: URLRequest
        do {
            urlRequest = try createURLRequest(from: endpoint)
        } catch {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse(statusCode: 0)
                }
                switch httpResponse.statusCode {
                case 200..<300:
                    return data
                case 400..<500:
                    throw NetworkError.clientError(statusCode: httpResponse.statusCode)
                case 500..<600:
                    throw NetworkError.serverError(statusCode: httpResponse.statusCode)
                default:
                    throw NetworkError.unknownError(statusCode: httpResponse.statusCode)
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                switch error {
                case is DecodingError:
                    return NetworkError.decodingError(error: error)
                default:
                    return NetworkError.networkError(error: error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func createURLRequest(from endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(string: endpoint.baseURL + endpoint.path)
        if let queryParameters = endpoint.queryParameters {
            components?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        endpoint.headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
    
    private func decodeData<T: Decodable>(_ data: Data, to type: T.Type) throws -> T {
        do {
            let result = try JSONDecoder().decode(T.self, from: data)
            #if DEBUG
            print("Data received: \(String(data: data, encoding: .utf8) ?? "No data")")
            #endif
            return result
        } catch {
            throw NetworkError.decodingError(error: error)
        }
    }
}
