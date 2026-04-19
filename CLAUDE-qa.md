# Quality assurance

Development and quality assurance are performed by separate, independent agents. Claude participating in the implementation of this project must not perform external quality assurance. This is a structural requirement, not a preference: an AI agent that produced the code shares the same reasoning, assumptions, and blind spots that may have introduced defects — it cannot objectively verify its own work, for the same reason a developer does not sign off on their own QA in a structured organization.

External QA lives in a dedicated, separate project with its own repository and conventions. The QA agent operates independently, with access only to the specification and the interface contracts defined in `01-specification/interface-contracts/` — never to the implementation code or the development context. Interface contracts are authored by the User (as contract author), not by Claude or QA — see [CLAUDE-specification.md](CLAUDE-specification.md#interface-contracts).

Internal development tests written during implementation are working tools for the development process only. They have no external quality assurance value.

## QA communications board

The external QA project communicates findings by depositing markdown files into `02-product/03-qa-communications/inbox/`, with the basic assumption that there is a shared the filesystem available. Each finding is a single file named `YYYY-MM-DD-<id>-<short-title>.md`, where `id` is a sequential integer on the day, starting from 1. File contains: date, reference to the specification item tested, finding type (defect, non-conformance, note), severity, description, and expected vs actual behaviour.

Severity levels:

| Severity | Meaning |
|---|---|
| Critical | System unusable or data loss; block release |
| Major | Core functionality broken; must fix before release |
| Minor | Degraded experience; fix before or shortly after release |
| Observation | No defect; improvement suggestion or informational |
| Specification wrong | No defect in software; specification has ambiguity, inconsistence or error, must fix before implementation |

Findings follow a lifecycle tracked entirely on the development side by moving files between state folders:

| State | Folder | Meaning |
|---|---|---|
| Open | `inbox/` | Received from QA, not yet reviewed |
| Acknowledged | `acknowledged/` | Reviewed and accepted as valid, queued for action |
| In progress | `in-progress/` | Being addressed on a development branch (file annotated with branch/PR reference) |
| Resolved | `resolved/` | Fix implemented and merged |
| Rejected | `rejected/` | Deliberately not actioned (file annotated with stated reason, see below about annotation guidance) |

QA deposits findings asynchronously and independently of the development schedule. Once deposited, QA's responsibility ends. Lifecycle management is a development responsibility.

Moving a finding to `rejected/` is exclusively User authority. Claude may not move a finding to `rejected/` on its own judgement. The rejection annotation must include a User-authored reason.

### Critical finding deferral time-box

A Critical finding carries a different risk profile from all other severities. It may be deferred without a remediation plan for at most 7 days from its discovery date (the date recorded in the finding filename). Once this period expires, Claude enforces one of two outcomes before any new implementation item may begin:

- A remediation plan is written into the finding file and the finding moves to `acknowledged/`; or
- The project is blocked — no new items start until the plan exists.

The 7-day threshold is fixed and not negotiable in the moment. Its purpose is to force a conscious decision at a defined time, not to reflect precise risk calibration. Deferral of Major, Minor, and Observation findings is not time-constrained.

### Annotations guidance

When finding resolution is in progress, a comment like this must be added at top of document:
```
IN PROGRESS

Started: YYYY-MM-DD
Reference: branch/PR
```

When finding is in acknowledged, a comment like this must be added at top of document:
```
ACKNOWLEDGED

On: YYYY-MM-DD
```

When finding was resolved, a comment like this must be added at top of document:
```
RESOLVED

On: YYYY-MM-DD
Reference: implementation-log-entry
```

When finding is rejected, a comment like this must be added at top of document:

```
REJECTED

Rejected: YYYY-MM-DD
Reason: <bla bla bla ...>
```
