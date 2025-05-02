# DemoNetworkManagerFramework
How to use framework:

import DemoNetworkManagerFramework
then you can use NetworkManager method
func fetchData<T>( endpoint: any Endpoint, responseType: T.Type ) async throws -> T where T : Decodable
fetchData method need inject parameters Endpoint and responseType object

Endpoint type is a part of framework
create your custom endpoint and conform Endpoint protocol like example below

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
                    headers: ["Content-Type": "application/json;charset=utf-8"])
            }
    }

then create an network service to use networkmanager method in our framework 
 
    import DemoNetworkManagerFramework
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
    }
