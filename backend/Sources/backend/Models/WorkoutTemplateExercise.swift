import Foundation
import Fluent

final class WorkoutTemplateExercise: Model, @unchecked Sendable {
    static let schema = "workout_template_exercises"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "template_id")
    var template: WorkoutTemplate

    @Parent(key: "exercise_id")
    var exercise: Exercise

    @Field(key: "position")
    var position: Int

    @OptionalField(key: "target_sets")
    var targetSets: Int?

    @OptionalField(key: "target_reps")
    var targetReps: Int?

    @OptionalField(key: "target_weight")
    var targetWeight: Double?

    @OptionalField(key: "rest_seconds")
    var restSeconds: Int?

    @OptionalField(key: "notes")
    var notes: String?

    init() { }

    init(
        id: UUID? = nil,
        templateID: UUID,
        exerciseID: UUID,
        position: Int,
        targetSets: Int?,
        targetReps: Int?,
        targetWeight: Double?,
        restSeconds: Int?,
        notes: String?
    ) {
        self.id = id
        self.$template.id = templateID
        self.$exercise.id = exerciseID
        self.position = position
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.restSeconds = restSeconds
        self.notes = notes
    }

    /// Converts the database model into a public API response DTO.
    ///
    /// - Returns: The workout template exercise response DTO.
    func toResponseDTO() throws -> WorkoutTemplateExerciseResponseDTO {
        WorkoutTemplateExerciseResponseDTO(
            id: try requireID(),
            exerciseId: $exercise.id,
            position: position,
            targetSets: targetSets,
            targetReps: targetReps,
            targetWeight: targetWeight,
            restSeconds: restSeconds,
            notes: notes
        )
    }
}

