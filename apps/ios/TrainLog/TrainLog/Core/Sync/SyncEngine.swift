import Foundation

actor SyncEngine {
    private var isSyncInProgress = false
    private var pendingOperations: [PendingSyncOperation] = []

    func enqueue(_ operation: PendingSyncOperation) {
        pendingOperations.append(operation)
    }

    func pendingOperationCount() -> Int {
        pendingOperations.count
    }

    func syncIfNeeded() async {
        guard !isSyncInProgress else {
            return
        }

        isSyncInProgress = true
        defer { isSyncInProgress = false }

        // Real upload/download behavior is added when the MVP reaches sync.
    }
}

struct PendingSyncOperation: Identifiable, Equatable, Sendable {
    let id: UUID
    let kind: SyncOperationKind
    let localID: UUID

    init(
        id: UUID = UUID(),
        kind: SyncOperationKind,
        localID: UUID
    ) {
        self.id = id
        self.kind = kind
        self.localID = localID
    }
}

enum SyncOperationKind: Equatable, Sendable {
    case createExercise
    case updateExercise
    case deleteExercise
}
