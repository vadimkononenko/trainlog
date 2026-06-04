import Foundation
import Fluent

final class WorkoutTemplate: Model, @unchecked Sendable {
    static let schema = "workout_templates"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "owner_user_id")
    var owner: User

    @Field(key: "name")
    var name: String

    @OptionalField(key: "notes")
    var notes: String?

    @Field(key: "version")
    var version: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    @Children(for: \.$template)
    var exercises: [WorkoutTemplateExercise]

    init() { }

    init(
        id: UUID? = nil,
        ownerUserID: UUID,
        name: String,
        notes: String?,
        version: Int = 1
    ) {
        self.id = id
        self.$owner.id = ownerUserID
        self.name = name
        self.notes = notes
        self.version = version
    }

    /// Converts the database model into a public API response DTO.
    ///
    /// - Returns: The workout template response DTO.
    func toResponseDTO() throws -> WorkoutTemplateResponseDTO {
        WorkoutTemplateResponseDTO(
            id: try requireID(),
            ownerUserId: $owner.id,
            name: name,
            notes: notes,
            exercises: try exercises
                .sorted { $0.position < $1.position }
                .map { try $0.toResponseDTO() },
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            version: version
        )
    }
}

