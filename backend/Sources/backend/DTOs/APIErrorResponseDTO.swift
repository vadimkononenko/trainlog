import Vapor

struct APIErrorResponseDTO: Content, Sendable {
    let code: String
    let message: String
    let details: [String: String]
}
