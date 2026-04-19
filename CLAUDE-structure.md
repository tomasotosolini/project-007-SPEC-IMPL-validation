# Structure

## Nature of this project

This is a meta-project. Its product is the `CLAUDE-*.md` convention set itself — a framework for running future vertical software projects with AI-assisted development. The framework is complete when it is capable of guiding the full lifecycle of a vertical project from specification to delivery.

The framework currently covers the **development loop**: specification → item implementation → QA → merge. It does not yet cover the **lifecycle loop**: release, versioning, hotfix, security update, deprecation, and sunset. This is a known scope boundary, not an accidental omission. Extending the framework to cover the lifecycle loop is a future item.

The bootstrap procedure — initializing a vertical project's repository, toolchain, and specification structure before item 1 begins — is also a future item in this meta-project. Until that item exists, teams applying this framework to a new vertical project will need to establish the initial environment without a documented procedure.

## Directory layout

This project is organized into two layers, each in its own directory. The `XX-` numeric prefixes are visual ordering aids only — they carry no semantic meaning.

```
.
..
.git
IMPLEMENTATION.md           — present at repository root during active item only; moved to implementation-logs/ on item completion
01-specification/
  - business needs
  - use cases
  - requirements
  - specification constraints
  - nfr-postponed.md          — register of postponed NFRs (managed by Claude, see CLAUDE-specification.md)
  - interface-contracts/      — interface contract artifacts (authored by User as contract author, see CLAUDE-specification.md)
02-product/  — resulting from specification
  01-documentation/
    - user documentation
      - quick start
    - development documentation
      - architectural documentation
      - tools and libraries
      - build environment
    - implementation-logs/  — one archived IMPLEMENTATION.md per implemented item
  02-software/
  03-qa-communications/  — findings received from the external QA project
    - inbox/        — QA deposits findings here
    - acknowledged/ — reviewed and accepted, queued for action
    - in-progress/  — being addressed on a development branch
    - resolved/     — fix implemented and merged
    - rejected/     — deliberately not actioned, with stated reason
```

## Ownership, accountability, and responsibilities

User is the owner of everything because User is accountable for everything when software goes into production. Therefore User must always have a clear view of all the details, even if they are produced by Claude.

| Layer | Author | Reviewer/Reviser/Responsible |
|---|---|---|
| Specification | User | Claude |
| Product | Claude | User |
| QA Communications | External QA agent | Claude + User (lifecycle management) |

## Git

User is responsible that the directory presented above is a git repository and that all tools necessary are available to the development/testing on the system.

## Note about storage under "implementation-logs"

This location is always growing. To mitigate this problem introduce a sub structure:
For last 30 days from now (Claude most know the date or ask to User) just leave the items:
 - 2026-04-12-cleanup-database-struct-3429834
 - 2026-04-10-cleanup-database-struct-3429834

After item is 30 days old, move to dedicated month directory, with last 6 months of development like:

 - 2026-03/
 - 2026-02/
 - 2026-01/
 - 2025-12/
 - 2025-11/

And previous months are moved under:

 - archive

Claude will check the status and apply this archiving logic once at session start.
