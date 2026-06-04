import Foundation
import Fluent

final class WorkoutSessionExercise: Model, @unchecked Sendable {
    static let schema = "workout_session_exercises"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "session_id")
    var session: WorkoutSession

    @Parent(key: "exercise_id")
    var exercise: Exercise

    @Field(key: "position")
    var position: Int

    @OptionalField(key: "notes")
    var notes: String?

    @Children(for: \.$sessionExercise)
    var sets: [WorkoutSet]

    init() { }

    init(
        id: UUID? = nil,
        sessionID: UUID,
        exerciseID: UUID,
        position: Int,
        notes: String?
    ) {
        self.id = id
        self.$session.id = sessionID
        self.$exercise.id = exerciseID
        self.position = position
        self.notes = notes
    }

    /// Converts the database model into a public API response DTO.
    ///
    /// - Returns: The workout session exercise response DTO.
    func toResponseDTO() throws -> WorkoutSessionExerciseResponseDTO {
        WorkoutSessionExerciseResponseDTO(
            id: try requireID(),
            exerciseId: $exercise.id,
            position: position,
            notes: notes,
            sets: try sets
                .sorted { $0.position < $1.position }
                .map { try $0.toResponseDTO() }
        )
    }
}

