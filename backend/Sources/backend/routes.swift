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

    let exerciseRepository = DefaultExerciseRepository()
    let exerciseService = ExerciseService(repository: exerciseRepository)
    let exerciseController = ExerciseController(
        service: exerciseService,
        authenticator: AccessTokenAuthenticator(repository: authRepository)
    )
    try app.register(collection: exerciseController)

    let workoutTemplateRepository = DefaultWorkoutTemplateRepository()
    let workoutTemplateService = WorkoutTemplateService(
        repository: workoutTemplateRepository,
        exerciseRepository: exerciseRepository
    )
    let workoutTemplateController = WorkoutTemplateController(
        service: workoutTemplateService,
        authenticator: AccessTokenAuthenticator(repository: authRepository)
    )
    try app.register(collection: workoutTemplateController)

    let workoutSessionRepository = DefaultWorkoutSessionRepository()
    let workoutSessionService = WorkoutSessionService(
        repository: workoutSessionRepository,
        templateRepository: workoutTemplateRepository,
        exerciseRepository: exerciseRepository
    )
    let workoutSessionController = WorkoutSessionController(
        service: workoutSessionService,
        authenticator: AccessTokenAuthenticator(repository: authRepository)
    )
    try app.register(collection: workoutSessionController)

    let syncService = SyncService(
        exerciseRepository: exerciseRepository,
        templateService: workoutTemplateService,
        sessionService: workoutSessionService
    )
    let syncController = SyncController(
        service: syncService,
        authenticator: AccessTokenAuthenticator(repository: authRepository)
    )
    try app.register(collection: syncController)
}
