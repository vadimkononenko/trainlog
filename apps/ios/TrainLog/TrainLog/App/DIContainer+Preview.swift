import Foundation
import SwiftData

extension DIContainer {
    static func preview() -> DIContainer {
        let persistence = PersistenceController.preview()
        let tokenStore = TokenStore(persistsToKeychain: false)
        let apiClient = APIClient(baseURL: URL(string: "http://localhost:8080")!)
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
