# IMPLEMENTATION — user-model-and-auth

## Design rationale

**What is being built**
User model with hardcoded roles and entitlements, password-based authentication, a login screen, and a 60-minute inactivity session timeout. This establishes the identity layer the rest of the application depends on.

**Why it is structured this way**
- Rails `has_secure_password` with BCrypt is the idiomatic way to handle password hashing; no custom crypto.
- Roles and entitlements are constants defined in a dedicated module (`app/models/concerns/roles.rb`), not DB-stored, satisfying spec requirements 868ddd57, 94db1afa, b6f04691.
- The inactivity timeout is enforced via a `before_action` in `ApplicationController` that checks `session[:last_active_at]` on every request and clears the session when the threshold is exceeded. This is stateless (no server-side session store needed) and avoids a scheduled job.
- The root user is created by a seed (`db/seeds.rb`), not baked into a migration, so it can be re-run safely.
- A `SessionsController` handles login/logout; it is not a RESTful resource controller (sessions are not persisted) — it follows Rails convention for cookie-based auth.

**Key components**
- `app/models/concerns/roles.rb` — `Roles` module: role list, entitlement list, role→entitlement mapping (all constants)
- `app/models/user.rb` — `User` ActiveRecord model with `has_secure_password`, role validation, and entitlement helper
- `db/migrate/YYYYMMDDHHMMSS_create_users.rb` — migration: `username` (unique, not null), `password_digest` (not null), `role` (not null)
- `db/seeds.rb` — creates root user (username: root, password: root, role: admin) idempotently
- `app/controllers/sessions_controller.rb` — new / create / destroy actions
- `app/views/sessions/new.html.erb` — login form
- `app/controllers/application_controller.rb` — `require_authentication` and `refresh_session_timeout` before_actions
- `config/routes.rb` — login/logout routes

**How they relate**
All controllers inherit from `ApplicationController`, so the authentication gate and timeout refresh apply everywhere. `SessionsController` is the only controller exempt from `require_authentication`. User model delegates entitlement queries to the `Roles` concern.

**Assumptions**
- Cookie-based sessions (Rails default) are sufficient for a single-host demo application.
- `session[:user_id]` + `session[:last_active_at]` are the only session keys needed.
- The seed is idempotent: running it twice does not create duplicate root users.

---

## New dependencies

- **`bcrypt` (~> 3.1.7)** — required by `has_secure_password`. Already present in the Gemfile but commented out. This item uncomments it.

---

## Full work plan

1. **Uncomment `bcrypt`** in `Gemfile` and run `bundle install`.

2. **Create User migration** — columns: `username` (string, not null, unique index), `password_digest` (string, not null), `role` (string, not null).

3. **Create `Roles` concern** in `app/models/concerns/roles.rb` — defines `ROLES`, `ENTITLEMENTS`, and `ROLE_ENTITLEMENTS` constants; provides `can?(entitlement)` instance method to be included by `User`.

4. **Create `User` model** — `has_secure_password`, validates presence and uniqueness of `username`, validates `role` is in `Roles::ROLES`, includes `Roles` concern.

5. **Migrate and seed** — run `rails db:migrate`, then write and run `db/seeds.rb` to create root user (admin role, password: root).

6. **Create `SessionsController`** — `new` (login form), `create` (authenticate + set session), `destroy` (clear session + redirect to login).

7. **Create login view** (`app/views/sessions/new.html.erb`) — simple form with username and password fields.

8. **Update `ApplicationController`** — add `require_authentication` and `refresh_session_timeout` before_actions; add `current_user` helper.

9. **Wire routes** — `get "/login"`, `post "/login"`, `delete "/logout"`; set root to login for now (will be overridden by domUs listing item).

10. **Run full test suite** — confirm no regressions.

---

## Implementation log

**Step 1 — bcrypt**
Uncommented `gem "bcrypt", "~> 3.1.7"` in Gemfile. `bundler3.1 install` added bcrypt 3.1.22.

**Step 2 — User migration**
Generated `CreateUsers` migration via `rails generate migration`. Added `null: false` constraints on all three columns manually after generation. Unique index on `username` generated automatically.

**Step 3 — Roles concern**
`app/models/concerns/roles.rb` defines `ROLES`, `ENTITLEMENTS`, `ROLE_ENTITLEMENTS` as frozen constants and provides `can?(entitlement)` instance method included by User.

**Step 4 — User model**
`app/models/user.rb` uses `has_secure_password`, validates presence and uniqueness of `username`, validates `role` inclusion in `Roles::ROLES`. Case-insensitive uniqueness on username.

**Step 5 — Migrate and seed**
`rails db:migrate` created `users` table. `db/seeds.rb` uses `find_or_create_by!` for idempotency. Verified: root user created with role admin and `can?("CREATOR")` returns true.

**Step 6 — SessionsController**
`sessions#new` skips both `require_authentication` and `refresh_session_timeout` before_actions. `create` authenticates via `user&.authenticate(password)`; on success sets `session[:user_id]` and `session[:last_active_at]`. On failure sets `@error = "login failed"` and re-renders with 422. `destroy` calls `reset_session` then redirects to login.

**Step 7 — Login view**
Minimal ERB form. Displays `@error` paragraph when set. Preserves `username` field value on re-render. Password field always blank.

**Step 8 — ApplicationController**
`require_authentication` checks both `current_user` presence and `session_active?`. If either fails, calls `reset_session` (clears stale data) then redirects to login. `refresh_session_timeout` overwrites `session[:last_active_at]` on every authenticated request. `SESSION_TIMEOUT = 60.minutes`.

**Step 9 — Routes and placeholder home**
Defined `GET /login`, `POST /login`, `DELETE /logout`. `root "home#index"` points to a minimal `HomeController` placeholder (protected by auth) so that post-login redirect has a valid destination. Without this, the redirect-after-login would loop back to the login page. This placeholder will be replaced by the domUs listing item.

**Step 10 — Test suite**
22 tests, 48 assertions, 0 failures. Covers: User model validations, password auth, all entitlement combinations; SessionsController login success/failure/missing-fields, logout with and without session, session expiry at 61 minutes, session validity at 59 minutes.

---

## System overview

**Components and responsibilities**

| Component | Responsibility |
|---|---|
| `Roles` concern | Single source of truth for role names, entitlement names, and role→entitlement mapping (all constants) |
| `User` model | Persistence, password hashing via BCrypt, role validation, entitlement query via `can?` |
| `SessionsController` | Login/logout flow; the only controller exempt from authentication |
| `ApplicationController` | Enforces authentication and 60-minute inactivity timeout on every request via before_actions |
| `HomeController` | Placeholder protected root page; will be replaced by the domUs listing item |
| `db/seeds.rb` | Idempotent creation of the root admin user |

**Key interfaces and dependencies**
- `ApplicationController` depends on `User` (via `current_user`) and on `session[:user_id]` / `session[:last_active_at]` being set by `SessionsController#create`.
- `SessionsController` skips both auth before_actions; it is the trust entry point.
- `Roles` is included into `User` as a concern; `User` does not call `Roles` directly — `can?` delegates through `role`.

**Known assumptions and constraints**
- Cookie-based Rails sessions; no server-side session store. Session data lives in the signed, encrypted cookie.
- `reset_session` is called on both logout and expiry — this prevents session fixation by rotating the session id.
- The root user is seeded, not migrated. Running `db:seed` twice is safe; running `db:reset` drops and recreates the root user.
- `HomeController` is a placeholder. Its view will be superseded and can be deleted when the domUs listing item is implemented.

**Likely failure modes**
- If `bcrypt` is removed from the Gemfile, `has_secure_password` will raise `LoadError` at boot.
- If `db/seeds.rb` is not run after a fresh `db:create`, there is no root user and no way to log in.
- Session cookie tampering is handled by Rails' signed cookie; no additional protection needed.
- The 60-minute check is wall-clock based (`Time.current`). If the server clock jumps backwards, sessions could appear unexpired longer than expected.
