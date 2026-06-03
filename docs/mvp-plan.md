# MVP Plan

TrainLog MVP is an offline-first workout tracker with a small Swift backend. The app should let a user authenticate, load exercises, create workout templates, complete workouts, save data locally first, and sync with the backend.

## Target Stack

- Backend: Vapor, Fluent, PostgreSQL, JWT, Swift Concurrency, VaporTesting.
- iOS: iOS 18+, SwiftUI, `@Observation`, SwiftData, MVVM+C, Swift Concurrency, actors, `Sendable`, Swift Testing.
- Architecture: backend `Controller -> Service -> Repository -> Fluent Model`; iOS local-first repositories with `DIContainer` and constructor injection.

## Build Order

1. Backend foundation: health endpoint, database config, structured errors.
2. Backend auth: register, login, refresh, logout, current user.
3. Backend exercises: protected exercise catalog CRUD, pagination, search, filters.
4. iOS project skeleton and app navigation.
5. iOS auth flow, token storage, and session state.
6. iOS networking layer and exercise list.
7. iOS SwiftData persistence for exercises.
8. Backend workout templates.
9. iOS workout templates.
10. Active workout local-only.
11. Backend workout sessions.
12. Sync queue and SyncEngine.
13. Offline save and later sync.
14. History screen.
15. Tests, docs, and portfolio polish.

## Backend MVP Scope

Backend resources:

- Auth
- Exercises
- Workout templates
- Workout sessions
- Sync push/pull

Backend conventions:

- Keep API DTOs separate from Fluent models.
- Keep route handlers thin.
- Put business rules in services.
- Put database access in repositories.
- Protect user-owned resources with bearer auth.
- Use soft deletes for sync-relevant resources.
- Update `docs/api.md` and `contracts/openapi.yml` for each API change.

## iOS MVP Scope

iOS features:

- Auth flow.
- Exercise catalog from API.
- Local SwiftData cache.
- Workout template creation.
- Active workout logging.
- Workout history.
- Offline-first writes.
- Sync queue.
- Light/dark theme.
- English/Ukrainian localization.

iOS conventions:

- Views render state and send events.
- View models are `@MainActor`.
- View models depend on repositories, not `APIClient`.
- Coordinators own navigation.
- SwiftData is the source of truth.
- `SyncEngine` is an actor.

## Post-MVP

- Analytics and Charts.
- Apple Health.
- Notifications.
- Widgets.
- CSV/JSON export.
- Conflict resolution UI.
- CI.
