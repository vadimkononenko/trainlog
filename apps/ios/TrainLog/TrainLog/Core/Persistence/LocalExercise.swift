import Foundation
import SwiftData

@Model
final class LocalExercise {
    @Attribute(.unique) var localID: UUID
    var remoteID: UUID?
    var name: String
    var category: String
    var equipment: String?
    var instructions: String?
    var syncStatusRawValue: String
    var createdAt: Date
    var updatedAt: Date

    init(
        localID: UUID = UUID(),
        remoteID: UUID? = nil,
        name: String,
        category: String,
        equipment: String? = nil,
        instructions: String? = nil,
        syncStatus: LocalSyncStatus = .synced,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.localID = localID
        self.remoteID = remoteID
        self.name = name
        self.category = category
        self.equipment = equipment
        self.instructions = instructions
        self.syncStatusRawValue = syncStatus.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension LocalExercise {
    var syncStatus: LocalSyncStatus {
        get {
            LocalSyncStatus(rawValue: syncStatusRawValue) ?? .failed
        }
        set {
            syncStatusRawValue = newValue.rawValue
        }
    }
}

enum LocalSyncStatus: String, CaseIterable, Codable, Sendable {
    case synced
    case pendingCreate
    case pendingUpdate
    case pendingDelete
    case failed
    case conflicted
}
