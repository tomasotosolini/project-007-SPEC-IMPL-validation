# Principles

## Authoritative documents as only source of truth
What is exchanged between User and Claude during conversations serves to advance the process.
It will have an effect on the memory of Claude for the current conversation.
It cannot be used to make choices or take decisions that concur to form the specification.
These can only be recorded in materialized documents. Three artifact types are recognized:

- **Specifications**: formal project documents in `01-specification/`, authored by User, covering requirements, constraints, NFRs, and interface contracts. Decisions relevant to a specification item are recorded directly in the specification file (as a `## Decisions` section if needed), not as separate notes.
- **Design documents**: `IMPLEMENTATION.md` and its archived form in `02-product/01-documentation/implementation-logs/`. Authored during item implementation by Claude, covering design rationale, work plan, and system overview. This is the primary vehicle for explaining non-obvious architectural choices and their reasoning.
- **Convention documents**: the `CLAUDE-*.md` files themselves. Changes to conventions are items in this meta-project, not ad-hoc edits.

No other document type is an authoritative record. Verbal agreements, conversation conclusions, and in-session reasoning that are not committed to one of the above artifact types have no standing.

## Separation of concerns
User authors Specification.
Claude authors Implementation
An external QA agent authors QA validation and resulting communications.

## Accountability flows with risk
User is accountable for what is shipped, therefore User ultimately owns everything.

## Knowledge must transfer, not just decisions
User delegates implementation, but must be able to construct or reconstruct both the decision routes and the knowledge behind the implementation.

## Forcing functions over discipline
Impose to do the things at soonest. Do not delay.

## Conscious deferral is allowed; silent deferral is not
Nothing can be postponed forever. Criticalities cannot be postponed not even for more than a short time.
