# Architecture

TrainLog is a portfolio-focused monorepo for building a production-style iOS app with a small Swift backend. The main engineering goal is to practice middle-level iOS architecture: Swift Concurrency, actors, Sendable, isolation, `@Observation`, MVVM+C, local-first persistence, synchronization, testable networking, and manual dependency injection.

## Repository Structure

```text
trainlog/
├── apps/
│   └── ios/
├── backend/
├── contracts/
├── docs/
└── scripts/
```

- `apps/ios` contains the iOS 18+ SwiftUI client.
- `backend` contains the Vapor REST API.
- `contracts` contains OpenAPI definitions and example JSON payloads.
- `docs` contains architecture, API, sync strategy, and decisions.
- `scripts` contains project automation.

## iOS Architecture

The iOS app uses SwiftUI, iOS 18+, `@Observation`, SwiftData, MVVM+C, Swift Concurrency, Swift Testing, and manual DI.

Recommended feature structure:

```text
apps/ios/TrainLog/
├── App/
│   ├── TrainLogApp.swift
│   ├── AppCoordinator.swift
│   └── DIContainer.swift
├── Core/
│   ├── Networking/
│   ├── Persistence/
│   ├── Sync/
│   ├── Auth/
│   ├── DesignSystem/
│   ├── Localization/
│   └── Utilities/
├── Features/
│   ├── Auth/
│   ├── Exercises/
│   ├── WorkoutTemplates/
│   ├── ActiveWorkout/
│   ├── History/
│   └── Settings/
└── Resources/
```

### MVVM+C

- Views render state and forward user events to view models.
- View models are `@MainActor`.
- View models do not navigate directly.
- `AppCoordinator` manages the root flow: unauthenticated flow and authenticated app flow.
- Each large feature has a `FeatureCoordinator`.
- `NavigationPath` is owned by coordinators, not views or view models.

### Dependency Injection

Use `DIContainer` plus constructor injection.

- Do not introduce a third-party DI framework.
- View models receive repositories or use cases through initializers.
- Repositories receive local and remote data sources through initializers.
- Shared services are created in the container and passed down explicitly.

### Local-First Persistence

SwiftData is the local source of truth.

- UI reads from SwiftData.
- Repositories write locally first.
- Remote APIs are not called directly from view models.
- Local records carry sync metadata such as local ID, remote ID, version, timestamps, and sync status.
- `SyncEngine` is an actor responsible for pending sync operations.

Common sync statuses:

```text
synced
pendingCreate
pendingUpdate
pendingDelete
failed
conflicted
```

### Networking

Networking should be testable and protocol-driven.

Core types:

```text
APIClient
Endpoint
HTTPRequestBuilder
NetworkSessionProtocol
APIError
AuthInterceptor
TokenStore actor
```

Rules:

- Use async/await.
- Decode success and error responses into typed values.
- Attach bearer tokens through an auth layer, not feature code.
- Refresh expired access tokens once and retry the original request.
- If refresh fails, clear auth state and return to the auth flow.
- Feature view models should depend on repositories, not `APIClient`.

### Concurrency

- View models are `@MainActor`.
- Shared mutable services are actors.
- DTOs conform to `Sendable` where practical.
- Repositories are protocols.
- Avoid non-isolated mutable shared state.
- Prefer explicit isolation over implicit assumptions.

## Backend Architecture

The backend uses Vapor, Fluent, PostgreSQL, Swift Concurrency, and VaporTesting.

Recommended structure:

```text
backend/Sources/backend/
├── Controllers/
├── DTOs/
├── Middleware/
├── Migrations/
├── Models/
├── Repositories/
├── Services/
├── configure.swift
├── entrypoint.swift
└── routes.swift
```

Use this layering:

```text
Controller -> Service -> Repository -> Fluent Model
```

- Controllers own HTTP concerns: routes, request decoding, response DTOs, status codes.
- Services own business rules and orchestration.
- Repositories own database queries.
- Fluent models represent database persistence.
- DTOs represent public API request and response shapes.

Do not expose Fluent models directly as API responses.

## API Contracts

Keep API contracts in `contracts`.

- `contracts/openapi.yml` describes the public API.
- `contracts/examples` contains representative payloads.
- API request DTOs, response DTOs, domain models, and local persistence models are separate concepts.

Use stable API error responses:

```json
{
  "code": "not_found",
  "message": "Not Found",
  "details": {}
}
```

## Naming Conventions

Use these naming patterns consistently:

```text
FeatureNameView
FeatureNameViewModel
FeatureNameCoordinator
FeatureNameRepository
DefaultFeatureNameRepository
RemoteFeatureNameDataSource
LocalFeatureNameDataSource
CreateExerciseRequest
ExerciseResponseDTO
LocalExercise
```

Backend DTO examples:

```text
CreateExerciseRequest
UpdateExerciseRequest
ExerciseResponseDTO
PaginatedResponseDTO
```

Backend service and repository examples:

```text
ExerciseService
ExerciseRepository
DefaultExerciseRepository
```

## Documentation Style

Document important architectural functions and non-trivial public or internal APIs.

Use this format:

```swift
/// Description.
///
/// - Parameters:
///   - value: Description.
/// - Returns: Description.
```

Avoid comments for trivial code.

## Testing Strategy

Use Swift Testing for iOS unit tests and VaporTesting for backend tests.

Required test areas:

- APIClient success decoding, error decoding, cancellation, and token refresh.
- SyncEngine pending operations, retry behavior, and concurrent sync prevention.
- ViewModel tests for business-heavy flows.
- Backend route tests for auth, exercises, templates, sessions, and sync.
- Repository tests where query behavior or local-first behavior is non-trivial.

UI tests are optional for MVP.

## Decision Policy

Use balanced strictness.

- Follow these architecture rules by default.
- Adapt when existing code proves a better local convention.
- Do not introduce new frameworks or architectural patterns without documenting the reason in `docs/decisions`.
