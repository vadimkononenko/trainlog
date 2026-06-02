import JWT
import Vapor

struct AccessTokenAuthenticator: AsyncBearerAuthenticator {
    private let repository: any AuthRepository

    init(repository: any AuthRepository) {
        self.repository = repository
    }

    /// Authenticates a request with a bearer access token.
    ///
    /// - Parameters:
    ///   - bearer: The bearer authorization header value.
    ///   - request: The request to authenticate.
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        let payload = try await request.jwt.verify(bearer.token, as: AccessTokenPayload.self)
        let userID = try payload.requireUserID()

        guard let user = try await repository.findUser(id: userID, on: request.db) else {
            throw Abort(.unauthorized, reason: "User not found.")
        }

        request.auth.login(user)
    }
}

