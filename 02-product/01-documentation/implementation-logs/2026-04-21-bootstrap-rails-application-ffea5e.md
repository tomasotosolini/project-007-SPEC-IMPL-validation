# IMPLEMENTATION — bootstrap-rails-application

## Design rationale

**What is being built**
A bare Rails 7.2 application skeleton placed in `02-product/02-software/xen_manager/`, with SQLite as the database and the default Minitest test suite. This is the foundational shell every subsequent feature item will build on.

**Why it is structured this way**
- The app lives in a named subdirectory (`xen_manager/`) inside `02-product/02-software/` so the software layer remains clearly separated from documentation and QA artefacts.
- SQLite is chosen because this is a demo/non-production application running on a single host (dom0); no multi-process concurrency or external DB server is needed.
- No extra gems are added beyond Rails defaults; every feature addition is deferred to its own item.

**Key components**
- `xen_manager/` — Rails app root (config, app/, db/, test/)
- `xen_manager/config/database.yml` — SQLite config for development and test environments
- `xen_manager/test/` — Minitest suite root; must exit 0 before this item closes

**How they relate**
The app skeleton wires together routing, the MVC stack, the ORM, and the test infrastructure. Each subsequent feature item adds models/controllers/views/tests on top of this skeleton without touching the core configuration established here.

**Assumptions**
- Ruby 3.1.2 and Rails 7.2.3.1 are already installed on the system (confirmed).
- `sqlite3` library is available on the host (will be verified at step 3).
- The `02-product/02-software/` directory exists and is empty (only `.gitkeep` present).

---

## New dependencies

None beyond what Rails 7.2 includes by default. The `sqlite3` gem is a Rails default for new apps; it is not an additional dependency introduced by this item.

---

## Full work plan

1. **Generate Rails app** — run `rails new xen_manager --database=sqlite3 --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable --skip-hotwire --skip-jbuilder` from inside `02-product/02-software/`. Flags remove unneeded subsystems to keep the skeleton minimal.

2. **Verify bundler and dependencies** — run `bundle install` inside `xen_manager/` and confirm it exits 0.

3. **Create and migrate database** — run `rails db:create db:migrate` in both development and test environments; confirm no errors.

4. **Verify test suite** — run `rails test` inside `xen_manager/`; confirm it exits 0 with an empty suite (0 failures, 0 errors).

5. **Document build environment** — write `02-product/01-documentation/build-environment.md` recording Ruby version, Rails version, SQLite version, and how to run the app and test suite.

---

## Implementation log

**Step 1 — Generate Rails app**
Generated with `rails new xen_manager --database=sqlite3 --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-storage --skip-action-cable --skip-hotwire --skip-jbuilder`. The `--skip-*` flags remove subsystems not required by the spec, keeping the skeleton minimal.

**Step 2 — Bundle install**
System gem cache (`/var/lib/gems/3.1.0/cache/`) is not writable by the user. Configured bundler to install gems locally via `bundler3.1 config set --local path 'vendor/bundle'`. Added `/vendor/bundle` to the app's `.gitignore`. `bundler3.1 install` completed: 104 gems installed. Note: on Debian, the bundler command is `bundler3.1`, not `bundler`.

**Step 3 — Create and migrate database**
`bundler3.1 exec rails db:create db:migrate` created `storage/development.sqlite3` and `storage/test.sqlite3`. No migrations exist yet; both databases are at baseline schema.

**Step 4 — Verify test suite**
`bundler3.1 exec rails test` exited 0: 0 runs, 0 assertions, 0 failures, 0 errors, 0 skips. Minitest is operational.

**Step 5 — Document build environment**
Wrote `02-product/01-documentation/build-environment.md` recording versions, gem installation procedure, and commands for running the app and test suite.

---

## System overview

**Components and responsibilities**
- `xen_manager/` — Rails 7.2 application root; owns all MVC structure, routing, DB schema, and test suite
- `storage/*.sqlite3` — SQLite database files for development and test; created locally, not committed
- `vendor/bundle/` — locally installed gems; not committed

**Key interfaces and dependencies**
- All commands run through `bundler3.1 exec` to use the local gem path
- `config/database.yml` points to `storage/development.sqlite3` and `storage/test.sqlite3`
- Test suite entry point: `bundler3.1 exec rails test`

**Known assumptions and constraints**
- The `bundler3.1` command (not `bundler` or `bundle`) must be used on this Debian system
- Gems install to `vendor/bundle/` because the system gem cache is not user-writable
- No internet access is required after initial `bundler3.1 install`

**Likely failure modes**
- `bundler3.1 install` failing: check network access to rubygems.org or verify `vendor/bundle/` exists
- `rails test` not found: ensure you are inside `02-product/02-software/xen_manager/` and have run `bundler3.1 install`
- DB errors: run `bundler3.1 exec rails db:create db:migrate` to recreate missing database files

---
