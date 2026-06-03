import SwiftData

extension DIContainer {
    static func preview() -> DIContainer {
        let persistence = PersistenceController.preview()
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
