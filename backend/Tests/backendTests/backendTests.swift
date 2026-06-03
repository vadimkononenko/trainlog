@testable import backend
import VaporTesting
import Testing

@Suite("App Foundation Tests")
struct BackendFoundationTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await test(app)
            try await app.asyncShutdown()
        } catch {
            try? await app.asyncShutdown()
            throw error
        }
    }

    @Test("Health route returns OK")
    func health() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "health") { res async throws in
                #expect(res.status == .ok)

                let body = try res.content.decode(HealthResponseDTO.self)
                #expect(body.status == "ok")
            }
        }
    }

    @Test("Missing route returns structured API error")
    func missingRoute() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "missing") { res async throws in
                #expect(res.status == .notFound)

                let body = try res.content.decode(APIErrorResponseDTO.self)
                #expect(body.code == "not_found")
                #expect(body.details.isEmpty)
            }
        }
    }

    @Test("Protected current user route requires bearer token")
    func currentUserRequiresBearerToken() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "me") { res async throws in
                #expect(res.status == .unauthorized)

                let body = try res.content.decode(APIErrorResponseDTO.self)
                #expect(body.code == "unauthorized")
                #expect(body.details.isEmpty)
            }
        }
    }

    @Test("Exercise list route requires bearer token")
    func exerciseListRequiresBearerToken() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "exercises") { res async throws in
                #expect(res.status == .unauthorized)

                let body = try res.content.decode(APIErrorResponseDTO.self)
                #expect(body.code == "unauthorized")
                #expect(body.details.isEmpty)
            }
        }
    }
}
