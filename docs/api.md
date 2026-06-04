# API

API design notes and endpoint documentation.

## Auth

### `POST /auth/register`

Creates a user and returns an access token, refresh token, and user DTO.

Request:

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### `POST /auth/login`

Authenticates an existing user and returns an access token, refresh token, and user DTO.

### `POST /auth/refresh`

Rotates a valid refresh token and returns a new access token and refresh token.

Request:

```json
{
  "refreshToken": "refresh-token"
}
```

### `POST /auth/logout`

Revokes a refresh token.

Request:

```json
{
  "refreshToken": "refresh-token"
}
```

### `GET /me`

Returns the current authenticated user. Requires `Authorization: Bearer <access-token>`.

Auth response:

```json
{
  "accessToken": "access-token",
  "refreshToken": "refresh-token",
  "user": {
    "id": "2F527C38-295C-42AE-BAE2-48436A15D56F",
    "email": "user@example.com"
  }
}
```

## Exercises

All exercise endpoints require `Authorization: Bearer <access-token>`.

Supported values:

```text
category: chest, back, legs, shoulders, arms, core, cardio, other
exerciseType: strength, cardio, mobility, bodyweight
equipment: barbell, dumbbell, machine, band, bodyweight, cable, kettlebell, other
```

### `GET /exercises?page=1&limit=20&query=bench&category=chest&equipment=barbell`

Returns exercises visible to the current user. The response includes global exercises and custom exercises owned by the user.

Response:

```json
{
  "items": [
    {
      "id": "2F527C38-295C-42AE-BAE2-48436A15D56F",
      "ownerUserId": "56E72C0B-3D14-4012-BE3E-E15754B5FB82",
      "name": "Bench Press",
      "category": "chest",
      "exerciseType": "strength",
      "equipment": "barbell",
      "primaryMuscles": ["chest", "triceps"],
      "instructions": "Lower the bar under control and press back up.",
      "createdAt": "2026-06-02T12:00:00Z",
      "updatedAt": "2026-06-02T12:00:00Z",
      "deletedAt": null,
      "version": 1
    }
  ],
  "metadata": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "hasNextPage": false
  }
}
```

### `POST /exercises`

Creates a custom exercise owned by the current user.

Request:

```json
{
  "name": "Bench Press",
  "category": "chest",
  "exerciseType": "strength",
  "equipment": "barbell",
  "primaryMuscles": ["chest", "triceps"],
  "instructions": "Lower the bar under control and press back up."
}
```

### `GET /exercises/:id`

Returns a visible exercise by ID.

### `PATCH /exercises/:id`

Updates a custom exercise owned by the current user. At least one field is required.

### `DELETE /exercises/:id`

Soft-deletes a custom exercise owned by the current user.

## Workout Templates

All workout template endpoints require `Authorization: Bearer <access-token>`.

### `GET /workout-templates?page=1&limit=20`

Returns workout templates owned by the current user.

### `POST /workout-templates`

Creates a workout template owned by the current user.

Request:

```json
{
  "name": "Push Day",
  "notes": "Chest, shoulders, triceps",
  "exercises": [
    {
      "exerciseId": "2F527C38-295C-42AE-BAE2-48436A15D56F",
      "position": 1,
      "targetSets": 4,
      "targetReps": 8,
      "targetWeight": 80,
      "restSeconds": 120,
      "notes": "Warm up first"
    }
  ]
}
```

Response:

```json
{
  "id": "7E8E269B-2045-4F24-9D1C-5D85F2D81692",
  "ownerUserId": "56E72C0B-3D14-4012-BE3E-E15754B5FB82",
  "name": "Push Day",
  "notes": "Chest, shoulders, triceps",
  "exercises": [
    {
      "id": "880B990E-6B12-473B-A62C-B9EA9C04BB18",
      "exerciseId": "2F527C38-295C-42AE-BAE2-48436A15D56F",
      "position": 1,
      "targetSets": 4,
      "targetReps": 8,
      "targetWeight": 80,
      "restSeconds": 120,
      "notes": "Warm up first"
    }
  ],
  "createdAt": "2026-06-04T12:00:00Z",
  "updatedAt": "2026-06-04T12:00:00Z",
  "deletedAt": null,
  "version": 1
}
```

### `GET /workout-templates/:id`

Returns a workout template owned by the current user.

### `PATCH /workout-templates/:id`

Updates a workout template owned by the current user. At least one field is required. When `exercises` is provided, it replaces the full exercise list.

### `DELETE /workout-templates/:id`

Soft-deletes a workout template owned by the current user.

## Workout Sessions

All workout session endpoints require `Authorization: Bearer <access-token>`.

### `GET /workout-sessions?page=1&limit=20`

Returns workout sessions owned by the current user, newest first.

### `POST /workout-sessions`

Creates a completed or in-progress workout session owned by the current user.

Request:

```json
{
  "templateId": "7E8E269B-2045-4F24-9D1C-5D85F2D81692",
  "startedAt": "2026-06-04T10:00:00Z",
  "endedAt": "2026-06-04T11:00:00Z",
  "notes": "Solid session",
  "exercises": [
    {
      "exerciseId": "2F527C38-295C-42AE-BAE2-48436A15D56F",
      "position": 1,
      "notes": "Paused reps",
      "sets": [
        {
          "position": 1,
          "reps": 8,
          "weight": 80,
          "durationSeconds": null,
          "distanceMeters": null,
          "isCompleted": true,
          "notes": null
        }
      ]
    }
  ]
}
```

### `GET /workout-sessions/:id`

Returns a workout session owned by the current user.

### `PATCH /workout-sessions/:id`

Updates a workout session owned by the current user. At least one field is required. When `exercises` is provided, it replaces the full exercise and set list.

### `DELETE /workout-sessions/:id`

Soft-deletes a workout session owned by the current user.

## Sync

All sync endpoints require `Authorization: Bearer <access-token>`.

### `GET /sync/pull?since=2026-06-04T12:00:00Z`

Returns exercise, workout template, and workout session changes visible to the current user. Omit `since` for a full initial pull. Soft-deleted rows are included with `deletedAt` set.

Response:

```json
{
  "serverTime": "2026-06-04T12:05:00Z",
  "exercises": [],
  "workoutTemplates": [],
  "workoutSessions": []
}
```

### `POST /sync/push`

Applies workout template and workout session mutations from the client. Create mutations may include a client-generated UUID in `id`; update and delete mutations require `id`.

Request:

```json
{
  "workoutTemplates": [
    {
      "action": "create",
      "id": "7E8E269B-2045-4F24-9D1C-5D85F2D81692",
      "template": {
        "name": "Push Day",
        "notes": null,
        "exercises": []
      }
    }
  ],
  "workoutSessions": []
}
```

Response:

```json
{
  "serverTime": "2026-06-04T12:05:00Z",
  "workoutTemplates": [],
  "workoutSessions": [],
  "deletedWorkoutTemplateIds": [],
  "deletedWorkoutSessionIds": []
}
```
