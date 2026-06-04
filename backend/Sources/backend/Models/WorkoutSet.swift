import Foundation
import Fluent

final class WorkoutSet: Model, @unchecked Sendable {
    static let schema = "workout_sets"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "session_exercise_id")
    var sessionExercise: WorkoutSessionExercise

    @Field(key: "position")
    var position: Int

    @OptionalField(key: "reps")
    var reps: Int?

    @OptionalField(key: "weight")
    var weight: Double?

    @OptionalField(key: "duration_seconds")
    var durationSeconds: Int?

    @OptionalField(key: "distance_meters")
    var distanceMeters: Double?

    @Field(key: "is_completed")
    var isCompleted: Bool

    @OptionalField(key: "notes")
    var notes: String?

    init() { }

    init(
        id: UUID? = nil,
        sessionExerciseID: UUID,
        position: Int,
        reps: Int?,
        weight: Double?,
        durationSeconds: Int?,
        distanceMeters: Double?,
        isCompleted: Bool,
        notes: String?
    ) {
        self.id = id
        self.$sessionExercise.id = sessionExerciseID
        self.position = position
        self.reps = reps
        self.weight = weight
        self.durationSeconds = durationSeconds
        self.distanceMeters = distanceMeters
        self.isCompleted = isCompleted
        self.notes = notes
    }

    /// Converts the database model into a public API response DTO.
    ///
    /// - Returns: The workout set response DTO.
    func toResponseDTO() throws -> WorkoutSetResponseDTO {
        WorkoutSetResponseDTO(
            id: try requireID(),
            position: position,
            reps: reps,
            weight: weight,
            durationSeconds: durationSeconds,
            distanceMeters: distanceMeters,
            isCompleted: isCompleted,
            notes: notes
        )
    }
}

