# Interface Contract — user-model-and-auth

## Scope

This contract covers the authentication interface exposed by the login/logout flow. It is the authoritative reference for QA testing of this item.

---

## Endpoints

### GET /login

**Purpose**: Display the login form.

**Inputs**: none

**Response**:
- HTTP 200 with the login form page
- Redirects to [#guests-listing] if a valid session is already active

---

### POST /login

**Purpose**: Authenticate a user and establish a session.

**Inputs** (form-encoded body):

| Field | Type | Required | Notes |
|---|---|---|---|
| `username` | string | yes | |
| `password` | string | yes | |

**Success response**:
- HTTP 302 redirect to [#guests-listing]
- Session is established; subsequent requests within 60 minutes of inactivity are authenticated

**Error responses**:

| Condition | Behavior |
|---|---|
| `username` or `password` missing | Re-render login form with: "login failed" |
| Credentials invalid (wrong username or password) | Re-render login form with: "login failed" |

---

### DELETE /logout

**Purpose**: Destroy the current session.

**Inputs**: none (requires an active session cookie)

**Response**:
- HTTP 302 redirect to GET /login
- Session is fully cleared

**If called without an active session**:
- ignore error code, just return 200. redirect to GET /login

---

## Session behavior

- A session established via POST /login expires after **60 minutes of inactivity** (i.e. 60 minutes since the last authenticated request).
- Each successful authenticated request resets the inactivity timer.
- On expiry, the next request by that client is treated as unauthenticated: session is cleared and the client is redirected to GET /login.
