import Foundation
import Vapor

struct SyncService: Sendable {
    private let exerciseRepository: any ExerciseRepository
    private let templateService: WorkoutTemplateService
    private let sessionService: WorkoutSessionService

    init(
        exerciseRepository: any ExerciseRepository,
        templateService: WorkoutTemplateService,
        sessionService: WorkoutSessionService
    ) {
        self.exerciseRepository = exerciseRepository
        self.templateService = templateService
        self.sessionService = sessionService
    }

    /// Pulls server changes visible to the authenticated user.
    ///
    /// - Parameters:
    ///   - query: The sync pull query.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: Changed resources and the server timestamp.
    func pull(query: SyncPullQuery, for user: User, on request: Request) async throws -> SyncPullResponseDTO {
        SyncPullResponseDTO(
            serverTime: Date(),
            exercises: try await exerciseRepository
                .listChangedVisible(for: try user.requireID(), since: query.since, on: request.db)
                .map { try $0.toResponseDTO() },
            workoutTemplates: try await templateService.listChanged(since: query.since, for: user, on: request),
            workoutSessions: try await sessionService.listChanged(since: query.since, for: user, on: request)
        )
    }

    /// Applies client mutations and returns the accepted server state.
    ///
    /// - Parameters:
    ///   - dto: The sync push request.
    ///   - user: The authenticated user.
    ///   - request: The HTTP request.
    /// - Returns: Accepted mutations and deleted identifiers.
    func push(_ dto: SyncPushRequest, for user: User, on request: Request) async throws -> SyncPushResponseDTO {
        var templates: [WorkoutTemplateResponseDTO] = []
        var sessions: [WorkoutSessionResponseDTO] = []
        var deletedTemplateIDs: [UUID] = []
        var deletedSessionIDs: [UUID] = []

        for mutation in dto.workoutTemplates {
            switch mutation.action {
            case .create:
                let template = try requirePayload(mutation.template, resourceName: "template")
                templates.append(try await templateService.create(template, id: mutation.id, for: user, on: request))
            case .update:
                let templateID = try requireID(mutation.id, resourceName: "template")
                let template = try requirePayload(mutation.template, resourceName: "template")
                templates.append(try await templateService.replace(template, templateID: templateID, for: user, on: request))
            case .delete:
                let templateID = try requireID(mutation.id, resourceName: "template")
                try await templateService.delete(templateID: templateID, for: user, on: request)
                deletedTemplateIDs.append(templateID)
            }
        }

        for mutation in dto.workoutSessions {
            switch mutation.action {
            case .create:
                let session = try requirePayload(mutation.session, resourceName: "session")
                sessions.append(try await sessionService.create(session, id: mutation.id, for: user, on: request))
            case .update:
                let sessionID = try requireID(mutation.id, resourceName: "session")
                let session = try requirePayload(mutation.session, resourceName: "session")
                sessions.append(try await sessionService.replace(session, sessionID: sessionID, for: user, on: request))
            case .delete:
                let sessionID = try requireID(mutation.id, resourceName: "session")
                try await sessionService.delete(sessionID: sessionID, for: user, on: request)
                deletedSessionIDs.append(sessionID)
            }
        }

        return SyncPushResponseDTO(
            serverTime: Date(),
            workoutTemplates: templates,
            workoutSessions: sessions,
            deletedWorkoutTemplateIds: deletedTemplateIDs,
            deletedWorkoutSessionIds: deletedSessionIDs
        )
    }

    private func requireID(_ id: UUID?, resourceName: String) throws -> UUID {
        guard let id else {
            throw Abort(.badRequest, reason: "Sync \(resourceName) mutation requires an id.")
        }
        return id
    }

    private func requirePayload<Payload>(_ payload: Payload?, resourceName: String) throws -> Payload {
        guard let payload else {
            throw Abort(.badRequest, reason: "Sync \(resourceName) mutation requires a payload.")
        }
        return payload
    }
}

