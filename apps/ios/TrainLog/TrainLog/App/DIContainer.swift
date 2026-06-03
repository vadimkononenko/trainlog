import Foundation
import SwiftData

@MainActor
struct DIContainer {
    let modelContainer: ModelContainer
    let tokenStore: TokenStore
    let authSession: AuthSession
    let syncEngine: SyncEngine
    let appCoordinator: AppCoordinator

    init(
        modelContainer: ModelContainer,
        tokenStore: TokenStore,
        authSession: AuthSession,
        syncEngine: SyncEngine
    ) {
        self.modelContainer = modelContainer
        self.tokenStore = tokenStore
        self.authSession = authSession
        self.syncEngine = syncEngine
        self.appCoordinator = AppCoordinator(authSession: authSession)
    }

    /// Builds the production dependency graph for the SwiftUI app lifecycle.
    ///
    /// - Returns: A container with shared services and root navigation.
    static func live() -> DIContainer {
        let persistence = PersistenceController.live()
        let tokenStore = TokenStore()
        let authSession = AuthSession()
        let syncEngine = SyncEngine()

        return DIContainer(
            modelContainer: persistence.modelContainer,
            tokenStore: tokenStore,
            authSession: authSession,
            syncEngine: syncEngine
        )
    }
}
