# Test Framework

## Selection

The project uses **Minitest** via the standard Rails test stack (`rails test`). No additional test library is added — the framework is the one Rails generates by default when a new application is created.

## Rationale

- Zero additional dependency: ships with every Rails application out of the box.
- Full Rails integration: fixtures, transactional rollbacks, controller/integration test helpers, system tests via Capybara + Selenium are all available without configuration.
- Consistent with the project's demo/non-production nature: no justification exists for introducing a heavier framework (e.g. RSpec).

## Scope

| Type | Command | Location |
|---|---|---|
| Unit / model | `rails test` | `test/models/` |
| Controller | `rails test` | `test/controllers/` |
| Integration | `rails test` | `test/integration/` |
| System (browser) | `rails test:system` | `test/system/` |

## Verification

The framework is considered operational once the Rails application skeleton exists and `rails test` exits 0 with an empty suite. This is confirmed as part of the bootstrap item.
