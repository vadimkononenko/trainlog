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
- iOS project skeleton and app navigation.
- iOS auth flow, token storage, and session state.

The iOS project exists at `apps/ios/TrainLog` and now has an MVVM+C navigation skeleton with real auth API integration.

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

## Completed: iOS Project Skeleton and App Navigation

Implemented:

- Replaced the starter `ContentView` with a SwiftUI app root.
- Added `DIContainer` with constructor-created shared dependencies.
- Added `AppCoordinator` with auth and authenticated root flows.
- Added `AuthCoordinator` and placeholder auth screen.
- Added authenticated tab navigation for exercises, templates, active workout, history, and settings.
- Added feature coordinators and placeholder view models for the MVP feature areas.
- Added SwiftData container setup and initial `LocalExercise` persistence model.
- Added `TokenStore` actor and placeholder `SyncEngine` actor.
- Set the iOS deployment target to 18.0.

Behavior:

- Launch starts in the auth flow.
- The placeholder Continue button marks the session authenticated and switches to the main tab shell.
- Settings includes a placeholder sign-out action that returns to the auth flow.
- Feature view models do not perform navigation directly.
- Coordinators own `NavigationPath`.

Verification:

- `xcodebuild -project apps/ios/TrainLog/TrainLog.xcodeproj -scheme TrainLog -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/TrainLogDerivedData build CODE_SIGNING_ALLOWED=NO` passes.
- The first sandboxed build attempt failed with `sandbox-exec: sandbox_apply: Operation not permitted`; the same command passed when rerun outside the sandbox.

## Completed: iOS Auth Flow, Token Storage, and Session State

Implemented:

- Added a minimal `APIClient`, `Endpoint`, `HTTPMethod`, `NetworkSessionProtocol`, and typed `APIError`.
- Added auth request/response DTOs matching the backend auth contract.
- Added `RemoteAuthDataSource`, `AuthRepository`, and `DefaultAuthRepository`.
- Replaced the placeholder auth screen with separate sign-in and sign-up flows.
- Added form view models for sign in and sign up with loading/error state.
- Wired `POST /auth/login`, `POST /auth/register`, and `POST /auth/logout` through the auth repository.
- Updated `TokenStore` actor to persist auth session data in Keychain for the live app.
- Kept preview token storage in memory so previews do not read or write real Keychain data.
- Updated `AuthSession` to support restoring, signed-out, and signed-in states.
- Updated `AppCoordinator` and `AppRootView` to restore stored session state on app launch.
- Updated Settings sign out to revoke the refresh token best-effort, clear local token state, and return to the auth flow.

Behavior:

- App launch starts in a restoring state, then moves to the auth flow or main app flow.
- Successful sign in/sign up saves access token, refresh token, and current user locally.
- Stored auth state can restore the main app shell without the placeholder demo user.
- Sign out clears local auth state even if the remote logout request fails.

Verification:

- `xcodebuild -project apps/ios/TrainLog/TrainLog.xcodeproj -scheme TrainLog -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/TrainLogDerivedData build CODE_SIGNING_ALLOWED=NO` passes.
- Auth endpoints were not manually tested from the app in this step because the local backend runtime was not started.
- No iOS test target exists yet; APIClient tests should be added when the iOS test target is introduced.

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

Follow the original MVP order and start the iOS side:

```text
iOS networking layer and exercise list
```

Build on the existing iOS project in:

```text
apps/ios/TrainLog
```

Use:

- iOS 18+
- SwiftUI lifecycle
- `@Observation`
- MVVM+C
- `DIContainer`
- constructor injection
- authenticated API requests
- exercise repository
- exercise list UI
- error and loading states
- Swift Testing

Alternative if staying backend-first:

```text
Backend Workout Templates
```

Use the same backend layering and documentation style as Auth and Exercises.

## New Chat Prompt

Use this prompt to continue in another chat:

```text
Read AGENTS.md, docs/progress.md, docs/mvp-plan.md, docs/architecture.md, docs/api.md, and contracts/openapi.yml. Continue from the next MVP step. Inspect the repo before editing, follow the established architecture, update docs when APIs or architecture change, and run tests after implementation.
```
