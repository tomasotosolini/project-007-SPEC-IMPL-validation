# Work Item (or simply Item)

An item is a bounded unit of work that can be branched, implemented, tested, and merged independently and in certain cases also in parallel. Its scope must be unambiguous before implementation begins — scope and extension are established when the User confirms the item at the start of the implementation procedure. The item must determine a step forward in the project status (for any point of view, features, correctness, cleanliness, ...).

**In a vertical project**, an item is a spec-derived functional unit: a feature, a use case slice, an endpoint, a bug fix, a defined refactoring. It must have a specification anchor — no item may begin without a corresponding specification entry. An item should be completable in a single focused session; if it is too large, split it before branching, not mid-flight.

**Lower bound**: an item must produce a self-contained, reviewable change. A minor correction to a convention document does not require the full implementation procedure — it is handled as a direct edit with a commit.

**Upper bound**: an item that would require spec revision mid-implementation is too large or too ambiguous. Reduce scope or resolve the specification first.

**Origin**: Claude proposes candidate items based on the specification and open work; User confirms. The User may also name an item directly. The User's confirmation is the authoritative scope definition.

A new screen, for example, might be split into multiple items for convenience or to allow parallel execution — Claude can be invoked from multiple terminals simultaneously.

# Implementation procedure

## Preconditions

**Toolchain**: The test framework must be selected, installed, and verified operational before any implementation item is started. This is a project-level prerequisite — equivalent to a compiler for a compiled language — not an item-level dependency. It must be present and documented in `02-product/01-documentation/` before step 1 of the first implementation item begins. If not yet established when the first item is proposed, Claude surfaces this as a blocking prerequisite and does not proceed until it is resolved.

**Clean main**: The implementation procedure can be started only if the `main` branch on the local repository must be aligned with github, worktree must be clean, index must be empty. Notify and abort otherwise.

**Open QA findings**: Before proposing the next item, Claude checks `02-product/03-qa-communications/inbox/` and `02-product/03-qa-communications/acknowledged/` for open findings. If any are present, Claude surfaces them to the User, who decides, supplying a motivation, to address them before proceeding with next item. In case they are deferred, Claude must record fact and motivation in the findings file. Claude has also to report `02-product/03-qa-communications/in-progress/` in order to remind use of ongoing and not completed activities.

**Inter-item dependency**: Before proposing the next item, Claude checks whether the current state of the codebase, specification, or open findings suggests that a candidate item may be blocked by, or may invalidate, work from a previous item. If so, Claude surfaces this as a dependency observation. The User decides how to proceed; if a specification change is needed, it must be recorded before implementation begins.

**Critical finding time-box**: A Critical finding may be deferred without a remediation plan for at most 7 days from its discovery date (the date recorded in the finding filename). Once this period expires, Claude enforces one of two outcomes before any new implementation procedure or item implementation procedure may begin: (a) a remediation plan is written into the finding file and the finding moves to `acknowledged/`; or (b) the project is blocked — no next item starts until the plan exists. This threshold is fixed and not negotiable in the moment; its purpose is to force a conscious decision at a defined time, not to reflect precise risk calibration.

**Postponed NFRs**: Before proposing the next item, Claude reads `01-specification/nfr-postponed.md` (if exists) and surfaces any entries that may be relevant to the item under consideration. If any postponed NFR has become relevant — for instance, because the item introduces the constrained concern — Claude raises it as a question before implementation proceeds.

**Remote**: Before any operation requiring a remote name (push, cleanup), Claude resolves it from `.git/config`: one remote defined — use it; none defined — notify User and abort; multiple defined — ask User which to use.

## Outer process (strictly follow order)

  1. User asks to indicate next item (**the work item**)suitable for implementation.

  2. Claude responds with a brief list with no more than 3 elements in order of precedence according to its judgement and proposes next.

  3. User confirms proposition or selects a different one.

  4. Claude creates new branch with name `YYYY-MM-DD-<item-name>-<6 lowercase hex characters autogenerated>`. The date is the item proposition/start date. The item name must be slugified: lowercase only, hyphens as word separators, no underscores, no spaces, no special characters, no length cap.

  5. Claude switches to that branch.

  6. Claude carries out the implementation of the item (see [Item implementation procedure](#item-implementation-procedure)).

  7. Claude runs the full test suite to confirm no regressions across all steps. All tests must pass before proceeding. If the test suite is empty, Claude blocks and does not proceed — the User must explicitly acknowledge in the current session that the suite is empty and that they choose to proceed despite it. This acknowledgment is session-scoped: it is never written to any persistent document, so each new session where the suite is still empty requires a fresh explicit acknowledgment before implementation proceeds.

  8. Claude summarizes in the console what was done during implementation (a short recap of what is reported in the `IMPLEMENTATION.md`, see [Item implementation procedure](#item-implementation-procedure)).

  9. Claude adds, commits and pushes changes (ACP). Note: `IMPLEMENTATION.md` has already been moved to `implementation-logs/` at this point and will be included in the commit.

  10. Claude creates `.github/pull_request_template.md` if it does not already exist (using the template defined in `[PR template](#pr-template)`), then opens a pull request using it.

  11. Claude switches back to `main` branch.

  12. Claude checks pull request status using `gh pr view <pr-url> --json state,mergedAt` and reports the result. If `gh` is not available, Claude asks the User to confirm status manually. Once the PR is confirmed merged, Claude asks whether the User has pulled `main` on the local repository.

  13. When User confirms, Claude does a [Cleanup of merged pull requests](#cleanup-of-merged-pull-requests).

## Item implementation procedure

This section is invoked at step 6 of the process above. It explicitly requires a working document `IMPLEMENTATION.md` at the repository root during item implementation procedure where the following information are stored:

  1. the upfront design rationale
  2. the new dependencies required, with justification
  3. the full work plan, splitting the operations into logic chunks to be executed stepwise to allow the human to follow both the overall operation, each detail and know/internalize the details of the process (as stated in [Ownership, accountability, and responsibilities](CLAUDE-structure.md#ownership-accountability-and-responsibilities))
  4. a final system overview (appended after item implementation procedure is complete)

### Preconditions

**Session resumption**: When a session is resumed mid-implementation, Claude reads `IMPLEMENTATION.md` at the repository root before doing anything else, in order to restore full context of what was planned, what was already executed, and what remains. Claude then explicitly tells the User where it left off and asks for confirmation before proceeding.

### Inner process (strictly follow order)

  1. Claude writes `IMPLEMENTATION.md` at the repository root containing:

    - **Design rationale**:

      1. what is being built
      2. why it is structured this way
      3. what are the key components
      4. how they relate
      5. what assumptions the system makes

    - **New dependencies**: any third-party libraries or packages required that are not already present in the project, with a brief justification for each

    - **Full work plan**: an ordered sequence of operations including what files/components are added/modified/deleted, along with a textual explanation

    - **Implementation log**: an incremental record of design decisions and reasoning, populated step by step during execution. Created empty when `IMPLEMENTATION.md` is first written; one entry is appended per work plan step as it completes.

  2. Claude presents a summary to the User

  3. If any new dependencies are listed, Claude explicitly surfaces them and waits for User approval before proceeding. User may approve, reject, or request alternatives for each dependency. Rejections and substitutions must be noted in IMPLEMENTATION.md before proceeding.

  4. Claude asks consent to start implementation according to work plan

  5. User can:

    1. confirm -> this means that implementation must be done by Claude step by step prompting the User for consent at every step
    2. confirm and proceed autonomously -> this means that implementation can be done by Clause without asking consent at every step
    3. give different instuctions -> Claude will follow instructions

  6. If User confirms (either normal (5.1) or autonomously (5.2)), Claude (in an orderly fashion):

    1. implements the next step described in the work plan
    2. records in the **Implementation log** section of `IMPLEMENTATION.md` the modifications made and the design reasoning behind each choice; in mode 5.1, also surfaces this explanation to the User
    3. writes and runs internal development tests covering the step just implemented; all tests must pass before proceeding. When the interface for a step is stable enough to specify upfront, Claude may apply TDD (write tests first, then implement). Note: these tests are internal development tools only and carry no external quality assurance value.
    4. if point 5.1 is the choice:
      1. asks the User to review the modifications on filesystem
      2. waits for confirmation
      3. when User confirms, Claude moves to next step, until no more steps are left
    5. if point 5.2 is the choice:
      1. Claude simply moves to next step, until no more steps are left

### Spec revision during implementation

If during execution of the work plan (Outer, step 6) Claude discovers that the specification is incorrect, ambiguous, or incomplete in a way that blocks the current step:

  1. Claude halts implementation immediately.
  2. Claude describes the issue to the User, referencing the specification and the blocked work plan step.
  3. User updates the specification to resolve the ambiguity or error.
  4. Claude verifies the update is sufficient to unblock the step.
  5. Implementation resumes from the halted step.

A verbal resolution in conversation is not sufficient — the specification must be updated before implementation resumes. This follows the document-as-source-of-truth principle (see [CLAUDE-principles.md](CLAUDE-principles.md)).

  7. After all steps are completed, Claude appends a **System overview** section to `IMPLEMENTATION.md` containing:

    1. components and their responsibilities
    2. key interfaces and dependencies between components
    3. known assumptions and constraints
    4. likely failure modes and where to look first in a production incident

  8. Claude moves `IMPLEMENTATION.md` from the repository root to `02-product/01-documentation/implementation-logs/`, preserving it as a permanent archived record on the feature branch and in the eventual merge to main.

---

# Appendix

## PR template

```
  ---
  Title format: [<item-name>] <one-line summary of what was done>

  Example: [user-auth] Add JWT-based authentication endpoint

  ---
  Body:

  ## What
  <1–3 sentences describing what was implemented. No implementation details — what the system can now do that it couldn't before.>

  ## Why
  <Reference to the specification item this implements. E.g.: "Implements spec item: 01-specification/03-auth.md § 2.1">

  ## Work done
  <Bullet list of the main changes: files added/modified/deleted and their purpose. Keep it factual, no commentary.>

  ## Notes for reviewer
  <Optional. Anything the reviewer should pay particular attention to, known limitations, or decisions that deviate from the work plan with stated reason.>

  ## NFRs affected
  <List any NFR categories (Performance, Security, etc.) that are directly implicated by this change, or "None beyond those addressed in the spec".>
  ---
```

Rules:
  - Title must reference the item name exactly as it appears in the branch name.
  - "Why" must include a direct spec reference — no freeform justification.
  - "Notes for reviewer" may be omitted only if there is nothing to flag.
  - "NFRs affected" is mandatory, not optional — "None" is a valid entry but must be stated.

## Cleanup of merged pull requests

### Precondition

Cleanup of merged pull requests can be executed only if pull request has already been merged on GitHub and `main` branch on local repository has already been pulled.

This procedure assumes the repository is used exclusively within this framework. Out-of-procedure modifications that leave uncommitted changes will cause `git branch -d` to fail — the User is responsible for resolving this before cleanup proceeds.

### Process
1. Claude deletes local branch: git branch -d <branch-name>.
2. Claude deletes remote tracking information: git branch --delete --remotes <remote>/<branch-name>.
3. Claude deletes remote branch: git push <remote> --delete <branch-name>.
