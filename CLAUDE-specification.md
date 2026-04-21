# Specification

This is set of written texts that, taken together, depict the project at least from the perspective of what it is, what it does.
It could contain also indications about tools and tecnologies used, use cases, intended users.
In some cases it is also possible to add implementation constraints, like file structure, coding standards, namings standards, formatting standards.

# Specification authoring, review and refinement process

Specification authoring is User-led. Claude's role in specification work is reviewer, challenger, question-asker, and assistant — not primary author. Claude may identify gaps, surface risks, flag ambiguities, and propose options, but the act of deciding and writing the specification belongs to the User alone. This is distinct from implementation, where Claude is the primary actor.

The User writes or modifies the specification. In general we expect this to be an iterative process.

Before implementation begins on any item, Claude reviews the relevant specification to guarantee that:

  1. No missing details that would block implementation.
  2. No ambiguities that leave implementation undirected.
  3. No internal contradictions.
  4. No constraints that may be technically infeasible.
  5. Interface contracts: a contract artifact authored by the User (as contract author) exists in `01-specification/interface-contracts/` for each exposed interface in the item's scope. Claude verifies the artifact exists — it does not judge its adequacy. If no contract artifact exists, Claude raises this as a blocking issue and does not proceed until the User has authored one.

Claude always raises findings as questions, detailing and motivating each. The User resolves them by updating the specification — the update is the decision.
Implementation is prohibited until the specification is unambiguous.

In order to allow back referencing from implemented PRs whose message requires the "Why" field, items in specification must have a unique identification system: every single item must have a GUID (UUID4) assigned. The reason why we choose GUIDs is that as the whole specification is a set of texts, it is possible that they get resorted by changing the order at any time, and an order-based identification system could break or force weird representations. GUIDs remain unchanged regardless of reordering. Claude will make sure GUID is created/assigned when missing.

## Interface contracts

Exposed interfaces are defined as standalone artifacts by the User, acting as **contract author**. The contract author is independent of both implementation and quality assurance: Claude (implementer) cannot author a contract it will implement against; the QA agent cannot author a contract it will test against.

Each interface contract lives in `01-specification/interface-contracts/` as a separate file. It specifies the interface in enough detail that an independent QA agent can test against it without knowledge of the implementation. Typical content includes: endpoints or entry points, accepted inputs and their types, expected outputs and their types, error conditions and codes, and any ordering or sequencing constraints.

When the User is authoring an interface contract and needs assistance identifying what to document, Claude may describe what the implementation will expose — but the act of declaring the contract adequate for testing is the User's alone.

## Non-functional requirements

Non-functional requirements (NFRs) define the qualities of the system as a whole — not what it does, but how well it does it and under what conditions.

NFRs are architectural constraints that shape every design decision. Unlike functional requirements, which can often be added or changed incrementally, NFRs missed at specification time are expensive and sometimes structurally impossible to retrofit. They are the most common source of production failures that were never explicitly discussed.

NFRs are checked at two levels:

  1. **Project level**: the main specification must contain an explicit NFR section
  addressing all categories once, as a baseline for the whole system.
  Claude verifies this section exists in the spec file — a verbal or in-conversation
  decision is not sufficient.

  2. **Item level**: before each implementation item begins, Claude checks whether
  the item introduces anything not covered by the project-level decisions (e.g. a
  new endpoint with materially different performance characteristics, a new data
  store with distinct security implications). If so, Claude raises the delta as a
  question and the spec must be updated before implementation proceeds.

Every specification must address each of the seven categories defined in [Domains](#domains).
Silencing on a category is not acceptable.
For each category the User must make one of three explicit decisions:

  - **Addressed**: the requirement is defined and will be implemented.

  - **Not applicable**: a conscious declaration that the category does
  not apply to this item or project.

  - **Postponed**: the category is acknowledged but deliberately deferred.
  A postponed NFR is a known risk carried forward. When a category is
  postponed, Claude immediately records an entry in
  `01-specification/nfr-postponed.md` (creating the file if absent)
  with: the NFR category, the implementation item that postponed it, the
  date, and the stated reason. Claude checks this register as a
  precondition before each new implementation item and surfaces any
  entries that may be relevant to the item under consideration — see
  [CLAUDE-workflow.md](CLAUDE-workflow.md). This makes postponement
  re-surfacing process-enforced rather than memory-dependent.

Claude explicitly checks that each category has received one of the three
decisions before implementation begins.
Decisions must be recorded in the spec file — Claude verifies there, not
in conversation (refer to [CLAUDE-principles.md](CLAUDE-principles.md#authoritative-documents-as-only-source-of-truth)).
If any category is absent from the spec, Claude raises it as a question.
The User must address, declare not applicable, or explicitly postpone
each one before implementation proceeds.

Addressed and Postponed NFRs must have a (non empty set of) classification tags, chosen by the User. The goal of this is to prevent Claude from always taking into account **all** the NFRs, when doing the relevance check when NFR is postponed and reanalyzed later. Not applicable ones do not need tags as they are not going to be applied. If Not applicable is applied, Claude raises an error.


### Domains

**Cost / financial-operational**: Budget, token usage boundaries. Expected market grow.

**Performance**: Response time, throughput, and resource consumption under expected and peak load. Example constraints: maximum acceptable latency per operation, minimum requests per second, memory and CPU ceilings. Without these, the implementation will be optimized for correctness only, and performance issues will surface in production under real load.

**Security**: Authentication, authorization, data protection at rest and in transit, input validation, and handling of sensitive data. Security NFRs must be specified before implementation because they affect the fundamental structure of the system — adding security after the fact typically requires architectural rework. This category also covers compliance obligations (e.g. GDPR, data retention policies).

**Scalability**: How the system is expected to grow — in data volume, user load, or operational scope — and whether it must scale horizontally, vertically, or both. A system designed for ten users may be fundamentally incompatible with ten thousand without a rewrite.

**Reliability and availability**: Acceptable downtime, fault tolerance expectations, behaviour under partial failure, and recovery objectives (RTO/RPO). These determine whether the system needs redundancy, circuit breakers, retry logic, or graceful degradation.

**Operability and observability**: How the system will be monitored, diagnosed, and operated in production. This includes logging strategy, metrics, alerting, health checks, and the ability to diagnose incidents without access to a debugger. A system that cannot be observed cannot be operated safely. This category directly supports the User's accountability for production.

**Maintainability**: Expectations on code structure, documentation, testability, and the ease with which the system can be modified by someone other than its original author. Relevant when the system is expected to evolve over time or be handed to a different team.

**Compatibility and portability**: Target runtime environments, operating systems, language or platform versions, and integration constraints with external systems. These constrain the choice of tools and libraries from the start.
