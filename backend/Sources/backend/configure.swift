import NIOSSL
import Fluent
import FluentPostgresDriver
import JWT
import Vapor

/// Configures application middleware, database access, and routes.
///
/// - Parameter app: The Vapor application instance to configure.
public func configure(_ app: Application) async throws {

    var middlewares = Middlewares()
    middlewares.use(RouteLoggingMiddleware(logLevel: .info))
    middlewares.use(APIErrorMiddleware())
    app.middleware = middlewares

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    await app.jwt.keys.add(hmac: HMACKey(from: try jwtSecret(for: app)), digestAlgorithm: .sha256)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateRefreshToken())

    try routes(app)
}

/// Returns the JWT secret for the current environment.
///
/// - Parameter app: The Vapor application instance.
/// - Returns: The JWT secret used for access token signing.
private func jwtSecret(for app: Application) throws -> String {
    if let secret = Environment.get("JWT_SECRET"), !secret.isEmpty {
        return secret
    }

    guard !app.environment.isRelease else {
        throw Abort(.internalServerError, reason: "JWT_SECRET is required in release.")
    }

    return "trainlog-development-jwt-secret"
}
