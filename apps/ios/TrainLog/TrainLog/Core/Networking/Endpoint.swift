import Foundation

struct Endpoint: Sendable {
    let method: HTTPMethod
    let path: String
    let queryItems: [URLQueryItem]

    init(
        method: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem] = []
    ) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
    }
}

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
}
