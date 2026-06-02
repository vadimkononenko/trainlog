import Vapor

func routes(_ app: Application) throws {
    app.get("health") { req async -> HealthResponseDTO in
        HealthResponseDTO(status: "ok")
    }
}
