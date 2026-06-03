import Foundation
import SwiftData

@MainActor
struct DIContainer {
    let modelContainer: ModelContainer
    let apiClient: APIClient
    let tokenStore: TokenStore
    let authRepository: AuthRepository
    let authSession: AuthSession
    let syncEngine: SyncEngine
    let appCoordinator: AppCoordinator

    init(
        modelContainer: ModelContainer,
        apiClient: APIClient,
        tokenStore: TokenStore,
        authRepository: AuthRepository,
        authSession: AuthSession,
        syncEngine: SyncEngine
    ) {
        self.modelContainer = modelContainer
        self.apiClient = apiClient
        self.tokenStore = tokenStore
        self.authRepository = authRepository
        self.authSession = authSession
        self.syncEngine = syncEngine
        self.appCoordinator = AppCoordinator(
            authSession: authSession,
            authRepository: authRepository
        )
    }

    /// Builds the production dependency graph for the SwiftUI app lifecycle.
    ///
    /// - Returns: A container with shared services and root navigation.
    static func live() -> DIContainer {
        let persistence = PersistenceController.live()
        let apiClient = APIClient(baseURL: URL(string: "http://localhost:8080")!)
        let tokenStore = TokenStore()
        let remoteAuthDataSource = RemoteAuthDataSource(apiClient: apiClient)
        let authRepository = DefaultAuthRepository(
            remoteDataSource: remoteAuthDataSource,
            tokenStore: tokenStore
        )
        let authSession = AuthSession()
        let syncEngine = SyncEngine()

        return DIContainer(
            modelContainer: persistence.modelContainer,
            apiClient: apiClient,
            tokenStore: tokenStore,
            authRepository: authRepository,
            authSession: authSession,
            syncEngine: syncEngine
        )
    }
}
