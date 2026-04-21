# IMPLEMENTATION — domus-listing

## Design rationale

### What is being built
The domUs listing screen — the default screen shown to any authenticated user. It presents two tables:
- **Running domUs**: domUs currently in `running` status, showing config detail and simulated live resource usage (CPU %, memory used).
- **Configured domUs**: all registered domUs regardless of status, showing config detail only.

### Why it is structured this way
- The xl tool is simulated (per NFRs): all domU state lives in `XlSimulator`, a service with class-level mutable state. This means the simulator survives across requests within a server process (appropriate for a single-process demo), and can be mutated by future lifecycle items (create/destroy/start/stop) without touching the database.
- `Domu` is a plain Ruby `Struct` (not ActiveRecord) because domUs are not stored in the application database — they are owned by Xen and queried via xl.
- No additional authorization beyond `require_authentication` is needed: all authenticated roles (guest, user, admin) may view the listing (spec `a9f28dee`).

### Key components
1. `Domu` (app/models/domu.rb) — value object with all domU attributes.
2. `XlSimulator` (app/services/xl_simulator.rb) — singleton service; manages a class-level registry of `Domu` instances; provides `configured_list` and `running_list` (with simulated metrics).
3. `DomusController` (app/controllers/domus_controller.rb) — `index` action; delegates to XlSimulator and assigns view variables.
4. View (app/views/domus/index.html.erb) — two HTML tables.
5. Routes — root remapped from `home#index` to `domus#index`.

### How they relate
`DomusController#index` → `XlSimulator.configured_list` → `Array<Domu>`
`DomusController#index` → `XlSimulator.running_list` → `Array<{domu:, cpu_percent:, memory_used_mb:}>`
View iterates both arrays, rendering tables.

### Assumptions
- A Domu always has: name (string), vcpus (1–4), memory_mb (512–131072), disk_gb (4–1000), nic_type (nil | "NAT" | "HOST ONLY" | "BRIDGED"), status ("idle" | "running").
- Runtime metrics are deterministic fakes derived from the domU name (so they are stable per request but look plausible).
- The pre-seeded registry is the starting state; it resets on server restart (demo only).

---

## New dependencies

None. All implementation uses Rails built-ins and the Ruby standard library.

---

## Full work plan

1. **Create `Domu` struct** — `app/models/domu.rb`: keyword-init Struct with fields `name`, `vcpus`, `memory_mb`, `disk_gb`, `nic_type`, `status`.

2. **Create `XlSimulator` service** — `app/services/xl_simulator.rb`: class with a mutable class-level `@@registry` (Array<Domu>) pre-seeded with 4 sample domUs in mixed states. Public class methods: `configured_list` → all Domus; `running_list` → array of hashes `{domu:, cpu_percent:, memory_used_mb:}` for each running Domu with simulated metrics.

3. **Create `DomusController`** — `app/controllers/domus_controller.rb`: `index` action assigns `@configured_domus` and `@running_domus`.

4. **Create listing view** — `app/views/domus/index.html.erb`: header with logout button, two sections ("Running" and "Configured") each rendered as an HTML table.

5. **Update routes** — replace `root "home#index"` with `root "domus#index"`. Remove the now-stale placeholder comment.

6. **Remove dead code** — delete `app/controllers/home_controller.rb` and `app/views/home/index.html.erb` (replaced by domus controller/view).

7. **Write interface contract** — `01-specification/interface-contracts/domus-listing.md`.

8. **Write tests**:
   - `test/models/domu_test.rb` — Domu struct construction and attribute access.
   - `test/services/xl_simulator_test.rb` — configured_list returns all, running_list returns only running with metric keys.
   - `test/controllers/domus_controller_test.rb` — authentication required; all three roles (guest, user, admin) can reach index; response contains expected section headings.

---

## Implementation log

**Step 1 — Domu struct**
Created `app/models/domu.rb` as a keyword-init `Struct` with six fields: `name`, `vcpus`, `memory_mb`, `disk_gb`, `nic_type`, `status`. Plain Ruby, no ActiveRecord — domUs are not persisted by the application.

**Step 2 — XlSimulator service**
Created `app/services/xl_simulator.rb`. Uses a class-level `@@registry` (mutable Array<Domu>) pre-seeded from a frozen `SEED` constant with 4 sample domUs (2 running, 2 idle). `configured_list` returns a shallow dup; `running_list` filters to running domUs and adds deterministic fake metrics via `simulated_cpu` and `simulated_memory` (derived from the name byte sum, so stable per-request). `reset!` is provided for test isolation.

**Step 3 — DomusController**
Created `app/controllers/domus_controller.rb` with a single `index` action. Inherits `require_authentication` and `refresh_session_timeout` from `ApplicationController`. No additional authorization needed — all authenticated roles may view the listing.

**Step 4 — Listing view**
Created `app/views/domus/index.html.erb` with a page header (username, role, logout button) and two `<table>` sections: "Running" (includes CPU % and Mem Used columns) and "Configured" (all domUs, status column). Empty-state messages are shown when either list is empty.

**Step 5 — Routes**
Replaced `root "home#index"` with `root "domus#index"`. Removed the stale placeholder comment.

**Step 6 — Dead code removal**
Deleted `app/controllers/home_controller.rb` and `app/views/home/index.html.erb` (superseded by domus controller/view). Removed now-empty `app/views/home/` directory.

**Step 7 — Interface contract**
Created `01-specification/interface-contracts/domus-listing.md` documenting the `GET /` endpoint, authentication/authorization requirements, and the content contract for both table sections.

**Step 8 — Tests**
Added `test/fixtures/users.yml` entry for `normal_user` (role: user). Wrote:
- `test/models/domu_test.rb` — 3 tests covering struct construction and nil nic_type.
- `test/services/xl_simulator_test.rb` — 7 tests covering list contents, metric keys, metric value ranges, and copy isolation.
- `test/controllers/domus_controller_test.rb` — 9 tests covering unauthenticated redirect, all three roles, section headings, table content, and session expiry.
Full suite: 41 tests, 87 assertions, 0 failures, 0 errors.

---

## System overview

### Components and responsibilities

| Component | Responsibility |
|---|---|
| `Domu` (app/models/domu.rb) | Value object representing a single Xen domU. Carries all config attributes and status. No persistence. |
| `XlSimulator` (app/services/xl_simulator.rb) | In-memory domU registry. Source of truth for all domU state. Simulates xl list and xl info commands. Mutated by future lifecycle operations. |
| `DomusController` (app/controllers/domus_controller.rb) | HTTP layer. Queries XlSimulator and exposes data to view. Inherits auth guards from ApplicationController. |
| View (app/views/domus/index.html.erb) | Renders two HTML tables: running domUs (with metrics) and all configured domUs. |

### Key interfaces and dependencies

- `XlSimulator.configured_list` → `Array<Domu>` (all domUs)
- `XlSimulator.running_list` → `Array<{domu: Domu, cpu_percent: Integer, memory_used_mb: Integer}>` (running only, with metrics)
- `XlSimulator.reset!` → used in test setup/teardown to restore the seeded registry
- `ApplicationController#require_authentication` guards all actions on `DomusController`

### Known assumptions and constraints

- The simulator registry is class-level state: it persists across requests but resets on server restart. This is intentional for a single-process demo app.
- Runtime metrics are deterministic fakes (derived from name bytes), not real Xen data.
- Pre-seeded data (4 domUs) is the only way to populate the registry in this item; create/destroy operations are deferred to the domu-lifecycle item.

### Likely failure modes

- If `XlSimulator.configured_list` or `running_list` raises, the root page will 500. First place to look: `app/services/xl_simulator.rb` and the `@@registry` state.
- Test failures in `xl_simulator_test.rb` after a registry mutation in another test indicate missing `reset!` in setup/teardown.
