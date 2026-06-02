import Foundation
import JWT
import Vapor

struct AccessTokenPayload: JWTPayload, Sendable {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case issuedAt = "iat"
    }

    let subject: SubjectClaim
    let expiration: ExpirationClaim
    let issuedAt: IssuedAtClaim

    init(userID: UUID, expiresAt: Date, issuedAt: Date = Date()) {
        self.subject = SubjectClaim(value: userID.uuidString)
        self.expiration = ExpirationClaim(value: expiresAt)
        self.issuedAt = IssuedAtClaim(value: issuedAt)
    }

    /// Verifies token claims after signature verification.
    ///
    /// - Parameter algorithm: The JWT algorithm used to verify the token signature.
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try expiration.verifyNotExpired()
    }

    /// Extracts the user identifier from the subject claim.
    ///
    /// - Returns: The user identifier stored in the token subject.
    func requireUserID() throws -> UUID {
        guard let userID = UUID(uuidString: subject.value) else {
            throw Abort(.unauthorized, reason: "Invalid access token subject.")
        }
        return userID
    }
}
