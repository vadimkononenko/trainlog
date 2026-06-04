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
- Backend workout templates.
- Backend workout sessions.
- Backend sync pull/push.
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

## Completed: Backend Workout Templates

Implemented:

- Added `WorkoutTemplate` and `WorkoutTemplateExercise` models.
- Added `CreateWorkoutTemplate` and `CreateWorkoutTemplateExercise` migrations.
- Added template DTOs, repository, service, and controller.
- Updated `docs/api.md`.
- Updated `contracts/openapi.yml`.

Endpoints:

```text
GET /workout-templates
POST /workout-templates
GET /workout-templates/:id
PATCH /workout-templates/:id
DELETE /workout-templates/:id
```

Behavior:

- All template endpoints require bearer auth.
- Templates are user-owned.
- Template exercises can reference global exercises or custom exercises visible to the current user.
- Updating `exercises` replaces the full template exercise list.
- Delete is soft delete.
- List supports `page` and `limit`.

## Completed: Backend Workout Sessions

Implemented:

- Added `WorkoutSession`, `WorkoutSessionExercise`, and `WorkoutSet` models.
- Added session and set migrations.
- Added session DTOs, repository, service, and controller.
- Updated `docs/api.md`.
- Updated `contracts/openapi.yml`.

Endpoints:

```text
GET /workout-sessions
POST /workout-sessions
GET /workout-sessions/:id
PATCH /workout-sessions/:id
DELETE /workout-sessions/:id
```

Behavior:

- All session endpoints require bearer auth.
- Sessions are user-owned.
- Sessions can optionally reference a user-owned workout template.
- Session exercises can reference global exercises or custom exercises visible to the current user.
- Updating `exercises` replaces the full session exercise and set list.
- Delete is soft delete.
- List supports `page` and `limit`.

## Completed: Backend Sync

Implemented:

- Added `GET /sync/pull`.
- Added `POST /sync/push`.
- Added sync DTOs and `SyncService`.
- Extended exercise repository with timestamp-based delta queries.
- Updated `docs/api.md`.
- Updated `contracts/openapi.yml`.

Behavior:

- All sync endpoints require bearer auth.
- Pull returns `serverTime`, changed visible exercises, changed workout templates, and changed workout sessions.
- Pull accepts optional `since` date-time and includes soft-deleted rows with `deletedAt` set.
- Push accepts create/update/delete mutations for workout templates and workout sessions.
- Create mutations may carry client-generated UUIDs.
- Update and delete mutations require resource IDs.

Verification:

- `swift build` passes.
- `swift test` passes.
- Protected route tests cover templates, sessions, and sync.
- Database-backed integration tests for template/session/sync CRUD still require local PostgreSQL.

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
- `GET /workout-templates` requires bearer token.
- `GET /workout-sessions` requires bearer token.
- `GET /sync/pull` requires bearer token.
- `POST /sync/push` requires bearer token.

Database-backed integration tests for register/login/exercise/template/session/sync CRUD are not yet automated because they require local PostgreSQL.

Current iOS tests:

- No iOS test target exists yet.

## Next Recommended Step

The backend MVP surface is now implemented. The user will implement the iOS client manually from scratch.

Suggested starting point:

```text
Build the iOS app foundation by hand from the empty SwiftUI baseline.
```

Keep backend implementation intact. Do not change `docs/api.md` or `contracts/openapi.yml` unless the backend API shape changes.

## New Chat Prompt

Use this prompt to continue in another chat:

```text
Read AGENTS.md, docs/progress.md, docs/mvp-plan.md, docs/architecture.md, docs/api.md, and contracts/openapi.yml. The backend MVP surface is implemented: foundation, auth, exercises, workout templates, workout sessions, and sync pull/push. The iOS app has intentionally been reset to an empty SwiftUI baseline so the user can implement it by hand. Inspect the repo before editing, keep backend intact unless explicitly asked, and update docs/progress.md after completed work.
```
