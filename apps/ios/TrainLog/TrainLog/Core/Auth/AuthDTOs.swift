import Foundation

struct RegisterRequest: Encodable, Sendable {
    let email: String
    let password: String
}

struct LoginRequest: Encodable, Sendable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Encodable, Sendable {
    let refreshToken: String
}

struct LogoutRequest: Encodable, Sendable {
    let refreshToken: String
}

struct AuthResponseDTO: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
    let user: UserResponseDTO
}

struct UserResponseDTO: Decodable, Sendable {
    let id: UUID
    let email: String
}

extension AuthResponseDTO {
    func toStoredSession() -> AuthStoredSession {
        AuthStoredSession(
            credentials: AuthCredentials(
                accessToken: accessToken,
                refreshToken: refreshToken
            ),
            user: CurrentUser(
                id: user.id,
                email: user.email
            )
        )
    }
}
