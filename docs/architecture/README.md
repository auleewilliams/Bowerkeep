# Bowerkeep architecture

The [Bowerkeep MVP implementation plan](../superpowers/plans/2026-08-30-bowerkeep-mvp.md) is the approved source of truth for the initial product scope, architecture, and acceptance targets.

## Foundational decisions

- Bowerkeep is a native SwiftUI app targeting iOS 18+ and iPhone 15 or newer.
- An app-managed SQLite database accessed through GRDB is the offline source of truth.
- Domain models and internal protocols remain independent of persistence and network DTOs.
- Each physical card copy has a stable identity and exactly one collection or deck location.
- Camera recognition, catalogue access, pricing, persistence, and backup are isolated behind protocols.
- Recognition is conservative: ambiguous evidence requires user review rather than a guessed printing.
- Scan photographs are ephemeral and never persisted.
- Stable IDs, tombstones, timestamps, and revisions preserve a future synchronization path without adding a backend to the MVP.

## Architecture decision records

Create an architecture decision record when a change establishes or reverses a project-wide technical constraint, including:

- persistence or migration strategy;
- domain or service boundaries;
- offline and future synchronization semantics;
- recognition approach or confidence policy;
- external service selection;
- privacy, retention, backup, or restore behavior;
- a new project-wide dependency or build tool.

Routine implementation details and local refactors do not require an ADR.

Name records `NNNN-short-title.md` and include these sections:

1. **Status** — proposed, accepted, superseded, or rejected.
2. **Context** — the problem, constraints, and relevant issue.
3. **Decision** — the chosen approach and its boundaries.
4. **Consequences** — benefits, costs, risks, and follow-up work.
5. **Alternatives considered** — credible options and why they were not chosen.

Link each ADR from this index and from the implementing pull request. No separate ADRs are required for decisions already fully captured by the approved MVP plan unless those decisions change.
