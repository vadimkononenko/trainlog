# Progress

This file is the handoff source for continuing TrainLog in a new chat. Read `AGENTS.md` first, then this file.

## Current State

The repository is a monorepo at:

```text
/Users/vadimkononenko/projects/ios-startup/trainlog
```

Implemented so far:

- Backend foundation.
- Backend auth.
- Backend exercises.
- iOS project reset to an empty SwiftUI baseline intentionally.

The iOS project exists at `apps/ios/TrainLog`, but the previous iOS architecture implementation was removed on purpose. The user wants to implement the iOS client by hand from a blank baseline.

## Local Runtime

Vapor backend:

```text
http://localhost:8080
```

Local Swagger UI:

```text
http://localhost:8081
```

PostgreSQL is expected to run through Docker Compose from `backend/docker-compose.yml`.

Useful commands:

```bash
cd /Users/vadimkononenko/projects/ios-startup/trainlog/backend
docker compose up db
swift run backend migrate
swift run backend serve
swift test
```

Swagger UI command:

```bash
cd /Users/vadimkononenko/projects/ios-startup/trainlog
docker run -p 8081:8080 -e SWAGGER_JSON=/tmp/openapi.yml -v "$PWD/contracts/openapi.yml:/tmp/openapi.yml" swaggerapi/swagger-ui
```

Do not use online Swagger Editor for `Try it out` against `localhost`; use local Swagger UI.

## Completed: Backend Foundation

Implemented:

- Removed Vapor Todo starter.
- Added `GET /health`.
- Added structured API error response:

```json
{
  "code": "not_found",
  "message": "Not Found",
  "details": {}
}
```

- Added `APIErrorMiddleware`.
- Added CORS middleware for browser-based Swagger testing.
- Added foundation tests.

Verification:

- `swift test` passes.
- `GET /health` works.

## Completed: Backend Auth

Implemented:

- Added Vapor JWT dependency.
- Added `User` and `RefreshToken` models.
- Added `CreateUser` and `CreateRefreshToken` migrations.
- Added auth DTOs and JWT payload.
- Added `AuthController`, `AuthService`, `AuthTokenService`, `AuthRepository`, and `AccessTokenAuthenticator`.

Endpoints:

```text
POST /auth/register
POST /auth/login
POST /auth/refresh
POST /auth/logout
GET /me
```

Verification:

- `swift test` passes.
- Auth was manually tested with Postman and works.

## Completed: Backend Exercises

Implemented:

- Added `Exercise` model.
- Added `CreateExercise` migration.
- Added exercise enums and DTOs.
- Added generic pagination DTOs.
- Added `ExerciseController`, `ExerciseService`, and `ExerciseRepository`.
- Updated `docs/api.md`.
- Updated `contracts/openapi.yml`.

Endpoints:

```text
GET /exercises
POST /exercises
GET /exercises/:id
PATCH /exercises/:id
DELETE /exercises/:id
```

Behavior:

- All exercise endpoints require bearer auth.
- Exercises can be global (`ownerUserId == nil`) or user-owned.
- Current create endpoint creates user-owned custom exercises.
- Update/delete only applies to custom exercises owned by the current user.
- Delete is soft delete.
- List supports `page`, `limit`, `query`, `category`, and `equipment`.

Verification:

- `swift build` passes.
- `swift test` passes.
- OpenAPI YAML parses.
- Exercise routes still need manual end-to-end verification in local Swagger UI if not already completed.

## iOS Baseline

Current iOS state:

- The iOS app is intentionally empty.
- The app contains only a minimal SwiftUI `TrainLogApp`, `ContentView`, and assets.
- No iOS coordinators, DI container, repositories, networking layer, SwiftData models, token storage, auth flow, or feature modules are currently implemented.

Verification:

- `xcodebuild -project apps/ios/TrainLog/TrainLog.xcodeproj -scheme TrainLog -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/TrainLogDerivedData build CODE_SIGNING_ALLOWED=NO` should pass after reset.

## Current Tests

Current backend tests cover:

- `GET /health` returns OK.
- Missing route returns structured API error.
- `GET /me` requires bearer token.
- `GET /exercises` requires bearer token.

Database-backed integration tests for register/login/exercise CRUD are not yet automated because they require local PostgreSQL.

Current iOS tests:

- No iOS test target exists yet.

## Next Recommended Step

The user will implement the iOS client manually from scratch.

Suggested starting point:

```text
Build the iOS app foundation by hand from the empty SwiftUI baseline.
```

Keep backend implementation intact. Do not change `docs/api.md` or `contracts/openapi.yml` unless the backend API shape changes.

## New Chat Prompt

Use this prompt to continue in another chat:

```text
Read AGENTS.md, docs/progress.md, docs/mvp-plan.md, docs/architecture.md, docs/api.md, and contracts/openapi.yml. The backend foundation/auth/exercises are implemented. The iOS app has intentionally been reset to an empty SwiftUI baseline so the user can implement it by hand. Inspect the repo before editing, keep backend intact unless explicitly asked, and update docs/progress.md after completed work.
```
