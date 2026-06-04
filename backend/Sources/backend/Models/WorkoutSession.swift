import Foundation
import Fluent

final class WorkoutSession: Model, @unchecked Sendable {
    static let schema = "workout_sessions"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "owner_user_id")
    var owner: User

    @OptionalParent(key: "template_id")
    var template: WorkoutTemplate?

    @Field(key: "started_at")
    var startedAt: Date

    @OptionalField(key: "ended_at")
    var endedAt: Date?

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

    @Children(for: \.$session)
    var exercises: [WorkoutSessionExercise]

    init() { }

    init(
        id: UUID? = nil,
        ownerUserID: UUID,
        templateID: UUID?,
        startedAt: Date,
        endedAt: Date?,
        notes: String?,
        version: Int = 1
    ) {
        self.id = id
        self.$owner.id = ownerUserID
        self.$template.id = templateID
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.notes = notes
        self.version = version
    }

    /// Converts the database model into a public API response DTO.
    ///
    /// - Returns: The workout session response DTO.
    func toResponseDTO() throws -> WorkoutSessionResponseDTO {
        WorkoutSessionResponseDTO(
            id: try requireID(),
            ownerUserId: $owner.id,
            templateId: $template.id,
            startedAt: startedAt,
            endedAt: endedAt,
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

