import SwiftData

struct PersistenceController {
    let modelContainer: ModelContainer

    /// Creates the app SwiftData container.
    ///
    /// - Returns: A persistence controller backed by the on-device store.
    @MainActor
    static func live() -> PersistenceController {
        makeController(isStoredInMemoryOnly: false)
    }

    /// Creates an in-memory SwiftData container for previews and tests.
    ///
    /// - Returns: A persistence controller backed by an in-memory store.
    @MainActor
    static func preview() -> PersistenceController {
        makeController(isStoredInMemoryOnly: true)
    }

    @MainActor
    private static func makeController(isStoredInMemoryOnly: Bool) -> PersistenceController {
        let schema = Schema([
            LocalExercise.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        do {
            let modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )

            return PersistenceController(modelContainer: modelContainer)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }
}
