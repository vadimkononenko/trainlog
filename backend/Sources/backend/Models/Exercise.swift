import Foundation
import Fluent

final class Exercise: Model, @unchecked Sendable {
    static let schema = "exercises"

    @ID(key: .id)
    var id: UUID?

    @OptionalParent(key: "owner_user_id")
    var owner: User?

    @Field(key: "name")
    var name: String

    @Field(key: "category")
    var category: String

    @Field(key: "exercise_type")
    var exerciseType: String

    @Field(key: "equipment")
    var equipment: String

    @Field(key: "primary_muscles")
    var primaryMuscles: [String]

    @Field(key: "instructions")
    var instructions: String

    @Field(key: "version")
    var version: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        ownerUserID: UUID?,
        name: String,
        category: ExerciseCategory,
        exerciseType: ExerciseType,
        equipment: ExerciseEquipment,
        primaryMuscles: [String],
        instructions: String,
        version: Int = 1
    ) {
        self.id = id
        self.$owner.id = ownerUserID
        self.name = name
        self.category = category.rawValue
        self.exerciseType = exerciseType.rawValue
        self.equipment = equipment.rawValue
        self.primaryMuscles = primaryMuscles
        self.instructions = instructions
        self.version = version
    }

    /// Converts the database model into a public API response DTO.
    ///
    /// - Returns: The exercise response DTO.
    func toResponseDTO() throws -> ExerciseResponseDTO {
        ExerciseResponseDTO(
            id: try requireID(),
            ownerUserId: $owner.id,
            name: name,
            category: ExerciseCategory(rawValue: category) ?? .other,
            exerciseType: ExerciseType(rawValue: exerciseType) ?? .strength,
            equipment: ExerciseEquipment(rawValue: equipment) ?? .other,
            primaryMuscles: primaryMuscles,
            instructions: instructions,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            version: version
        )
    }
}

