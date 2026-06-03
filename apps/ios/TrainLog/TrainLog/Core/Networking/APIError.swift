import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int, response: APIErrorResponseDTO?)
    case decodingFailed
}

struct APIErrorResponseDTO: Decodable, Sendable {
    let code: String
    let message: String
    let details: [String: String]
}
