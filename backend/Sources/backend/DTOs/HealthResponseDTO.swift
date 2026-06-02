import Vapor

struct HealthResponseDTO: Content, Sendable {
    let status: String
}
