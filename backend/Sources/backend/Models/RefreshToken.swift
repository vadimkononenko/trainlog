import Foundation
import Fluent

final class RefreshToken: Model, @unchecked Sendable {
    static let schema = "refresh_tokens"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Field(key: "token_hash")
    var tokenHash: String

    @Field(key: "expires_at")
    var expiresAt: Date

    @OptionalField(key: "revoked_at")
    var revokedAt: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, userID: UUID, tokenHash: String, expiresAt: Date) {
        self.id = id
        self.$user.id = userID
        self.tokenHash = tokenHash
        self.expiresAt = expiresAt
    }

    /// Checks whether the refresh token can still be used.
    ///
    /// - Parameter now: The current date used for expiration comparison.
    /// - Returns: `true` when the token is not revoked and not expired.
    func isActive(now: Date = Date()) -> Bool {
        revokedAt == nil && expiresAt > now
    }
}
