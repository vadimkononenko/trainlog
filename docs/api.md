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
