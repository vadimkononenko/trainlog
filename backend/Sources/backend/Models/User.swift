import Fluent
import Vapor

final class User: Model, Authenticatable, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Children(for: \.$user)
    var refreshTokens: [RefreshToken]

    init() { }

    init(id: UUID? = nil, email: String, passwordHash: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }

    /// Converts the database model into a public API response DTO.
    ///
    /// - Returns: The user response DTO.
    func toResponseDTO() throws -> UserResponseDTO {
        UserResponseDTO(id: try requireID(), email: email)
    }
}
