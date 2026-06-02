import Vapor

/// Registers application routes.
///
/// - Parameter app: The Vapor application instance that owns the route collection.
func routes(_ app: Application) throws {
    app.get("health") { req async -> HealthResponseDTO in
        HealthResponseDTO(status: "ok")
    }

    let authRepository = DefaultAuthRepository()
    let authService = AuthService(repository: authRepository)
    let authController = AuthController(
        service: authService,
        authenticator: AccessTokenAuthenticator(repository: authRepository)
    )
    try app.register(collection: authController)
}
