//
//  NetworkManager.swift
//  DemoNetworkManagerFramework
//
//  Created by Hao Nguyen on 2/5/25.
//

import Foundation
import Combine

// MARK: - NetworkManager
public class NetworkManager: NetworkServiceProtocol {
    private let session: URLSession
    public init(session: URLSession = .shared) {
        self.session = session
    }
}
// MARK: NetworkManager with NetworkServiceProtocol
extension NetworkManager {
    // MARK: - 1. ASYNC/AWAIT
    public func requestAsync<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let urlRequest: URLRequest
        do {
            urlRequest = try createURLRequest(from: endpoint)
        } catch {
            throw error        }
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            throw NetworkError.networkError(error: urlError)
        } catch {
            throw NetworkError.networkError(error: error)
        }
        
        let _ = try handleHTTPResponse(response: response)
        
        return try decodeData(data, to: T.self)
    }
    
    // MARK: - 2. CALLBACK/RESULT
    public func requestCallback<T: Decodable>(endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) {
        
        let urlRequest: URLRequest
        do {
            urlRequest = try createURLRequest(from: endpoint)
        } catch {
            completion(.failure(error)) // Error from createURLRequest
            return
        }
        
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.networkError(error: error)))
                return
            }
            
            do {
                let _ = try self.handleHTTPResponse(response: response)
                
                guard let data = data else {
                    throw NetworkError.invalidData
                }
                
                let decoded = try self.decodeData(data, to: T.self)
                completion(.success(decoded))
                
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - 3. COMBINE PUBLISHER
    public func requestPublisher<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, Error> {
        
        let urlRequest: URLRequest
        do {
            urlRequest = try createURLRequest(from: endpoint)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                let _ = try self.handleHTTPResponse(response: response)
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> Error in
                switch error {
                case let networkError as NetworkError:
                    return networkError
                case is DecodingError:
                    return NetworkError.decodingError(error: error)
                case let urlError as URLError:
                    return NetworkError.networkError(error: urlError)
                default:
                    return NetworkError.networkError(error: error)
                }
            }
            .eraseToAnyPublisher()
    }
}
// MARK: DECODE & REQUEST FACTORY
extension NetworkManager {
    // Build URLRequest
    private func createURLRequest(from endpoint: Endpoint) throws -> URLRequest {
        guard var components = URLComponents(string: endpoint.baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Add headers
        endpoint.headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Add body cho POST/PUT
        request.httpBody = endpoint.body
        
        return request
    }
    
    // Handle Response/Status Code
    private func handleHTTPResponse(response: URLResponse?) throws -> HTTPURLResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(statusCode: 0)
        }
        
        let statusCode = httpResponse.statusCode
        
        switch statusCode {
        case 200..<300:
            return httpResponse
        case 400..<500:
            throw NetworkError.clientError(statusCode: statusCode)
        case 500..<600:
            throw NetworkError.serverError(statusCode: statusCode)
        default:
            throw NetworkError.unknownError(statusCode: statusCode)
        }
    }
    
    // Decode data
    private func decodeData<T: Decodable>(_ data: Data, to: T.Type) throws -> T {
        do {
            let result = try JSONDecoder().decode(T.self, from: data)
//            Logger.shared.debug("Data received: \(String(data: data, encoding: .utf8) ?? "No data")")
            return result
        } catch {
            throw NetworkError.decodingError(error: error)
        }
    }
}
