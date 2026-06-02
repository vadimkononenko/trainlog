import Vapor

struct RegisterRequest: Content, Sendable {
    let email: String
    let password: String
}

struct LoginRequest: Content, Sendable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Content, Sendable {
    let refreshToken: String
}

struct LogoutRequest: Content, Sendable {
    let refreshToken: String
}

struct AuthResponseDTO: Content, Sendable {
    let accessToken: String
    let refreshToken: String
    let user: UserResponseDTO
}

struct UserResponseDTO: Content, Sendable {
    let id: UUID
    let email: String
}

