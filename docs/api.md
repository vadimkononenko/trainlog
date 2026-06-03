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
