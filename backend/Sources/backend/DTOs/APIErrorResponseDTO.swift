import Vapor

struct APIErrorResponseDTO: Content {
    let code: String
    let message: String
    let details: [String: String]
}
