# TrainLog Agent Instructions

Use this file as the project-specific instruction source when changing TrainLog code. Follow these rules with balanced strictness: prefer these patterns, but adapt when the existing codebase proves a better local convention.

## Project Shape

TrainLog is a monorepo with two Swift applications:

- `apps/ios` contains the iOS 18+ SwiftUI client.
- `backend` contains the Vapor REST API.
- `contracts` contains API contracts and example payloads.
- `docs` contains architecture, API, sync, and decision notes.
- `scripts` contains project automation.

## Architecture Rules

- iOS uses SwiftUI, Swift Concurrency, `@Observation`, MVVM+C, SwiftData, Swift Testing, and manual DI.
- Backend uses Vapor, Fluent, PostgreSQL, Swift Concurrency, and VaporTesting.
- Use `DIContainer` plus constructor injection. Do not introduce a third-party DI framework.
- Use coordinators for navigation. `AppCoordinator` owns the root flow. Each large feature owns a `FeatureCoordinator`.
- Keep `NavigationPath` inside coordinators. View models must not perform navigation directly.
- Use local-first repositories on iOS. UI reads from SwiftData, repositories write locally first, and remote APIs are not called directly from view models.
- Use `SyncEngine` as an actor responsible for pending sync operations.
- Backend layering is `Controller -> Service -> Repository -> Fluent Model`.

## Concurrency Rules

- Mark iOS view models as `@MainActor`.
- Use actors for shared mutable services, including token storage and sync coordination.
- DTOs should conform to `Sendable` where practical.
- Repository contracts should be protocols.
- Do not use non-isolated mutable shared state.
- Prefer async/await APIs. Use Future-based Vapor APIs only when required by Vapor interfaces.

## Naming Rules

Use these names consistently:

- `FeatureNameView`
- `FeatureNameViewModel`
- `FeatureNameCoordinator`
- `FeatureNameRepository`
- `DefaultFeatureNameRepository`
- `RemoteFeatureNameDataSource`
- `LocalFeatureNameDataSource`
- `CreateExerciseRequest`
- `ExerciseResponseDTO`
- `LocalExercise`

## Documentation Rules

Document important architectural functions and non-trivial public or internal APIs using this format:

```swift
/// Description.
///
/// - Parameters:
///   - value: Description.
/// - Returns: Description.
```

Do not document trivial helpers just to add noise.

## Testing Rules

- Use Swift Testing for iOS unit tests.
- Use VaporTesting for backend tests.
- Add APIClient tests when networking behavior changes.
- Add SyncEngine tests when sync behavior changes.
- Add ViewModel tests for business-heavy flows.
- UI tests are optional for MVP.

## Implementation Defaults

- Keep MVP changes focused and production-style.
- Prefer small, testable types over large feature files.
- Keep API request and response DTOs separate from domain and local persistence models.
- Keep backend models separate from API DTOs.
- Update `docs/architecture.md`, `docs/api.md`, or `docs/sync-strategy.md` when changing architecture, API shape, or sync behavior.

