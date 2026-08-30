# Bowerkeep Agent Instructions

These instructions apply to the entire repository. A more specific `AGENTS.md` may add or tighten rules for a subtree, but it must not weaken the repository-wide safety, privacy, testing, or review requirements below.

## Project purpose

Bowerkeep is a personal, local-first iPhone application for scanning individual English Magic: The Gathering cards, recording their exact physical printings, tracking collection and Commander deck locations, and flagging cards with an indicative value of A$20 or more.

The approved implementation plan is the product and architecture source of truth:

- [`docs/superpowers/plans/2026-08-30-bowerkeep-mvp.md`](docs/superpowers/plans/2026-08-30-bowerkeep-mvp.md)
- [Bowerkeep MVP milestone](https://github.com/auleewilliams/Bowerkeep/milestone/1)

When an active issue and the implementation plan disagree, stop and ask for clarification. Do not silently choose one.

## Mandatory workflow

1. Start from a specific, unblocked GitHub implementation issue.
2. Read the issue, its parent tracking issue, its blockers, and the relevant plan section before changing files.
3. Inspect `git status` and preserve all pre-existing work. Never discard or rewrite another contributor's changes.
4. Work on a dedicated branch or worktree named `codex/issue-<number>-<short-slug>`. Never implement directly on `main`.
5. Keep one implementation issue per branch and pull request. Do not begin downstream issues or unrelated cleanup.
6. Use test-driven development for behavior changes: establish a failing test, implement the smallest passing change, then refactor with the tests green.
7. Run the narrowest relevant verification during development and the full issue-level verification before requesting review.
8. Open a pull request that links the issue with `Closes #<number>` and records exact verification commands and results.
9. Merge prerequisite work before branching dependent issues. Parallel work may begin only when the GitHub dependency graph permits it.
10. Close a parent tracking issue only after all native sub-issues are closed and its completion gate has been rerun.

Do not commit, push, merge, close issues, or modify GitHub metadata unless the user has requested that action.

## Architecture guardrails

- Target iOS 18+, Swift 6 strict concurrency, and iPhone 15 or newer.
- Build the UI with SwiftUI and use AVFoundation, Vision, GRDB 7.11.1, Swift Testing, and XCUITest as specified by the plan.
- Keep domain models independent of SQLite records and network DTOs.
- Screens and scanning flows depend on the repository, catalogue, recognizer, exchange-rate, and backup protocols—not concrete infrastructure.
- SQLite is the offline source of truth. Preserve stable client-generated IDs, revision metadata, timestamps, and deletion tombstones for future synchronization.
- A physical card copy has exactly one location. Moving it changes its location; it must not create a duplicate.
- Store monetary values in minor units and keep source currency, finish, and retrieval timestamps explicit.
- Add database changes through versioned migrations. Once a migration has shipped or merged, add a new migration rather than rewriting its history.
- Keep network access behind services with deterministic stubs. Unit tests must not depend on live external services.
- Do not add a backend, login, binder-page scanning, image-similarity recognition, Commander legality engine, or MTG Mate automation without a separately approved design.
- Do not introduce XcodeGen, Tuist, or additional third-party dependencies without explicit approval.

## Privacy and security

- Never persist, log, upload, or commit scan photographs. Release captured image data after recognition or cancellation.
- Never commit personal collection databases, `.bowerkeep` backups, private fixture data, credentials, tokens, or `.env` files.
- Keep the 200-card real-device acceptance fixture private and uncommitted under `fixtures/private/` or a `PrivateFixtures/` directory.
- Treat catalogue prices as indicative retail-market data. Never present them as confirmed offers.
- Link to MTG Mate's public buylist only; do not scrape it or automate its cart.
- Preserve user data transactionally. Backup restore must validate compatibility and integrity and retain a rollback path before replacing the live database.

## Swift and UI conventions

- Prefer small value types, explicit dependencies, and focused actors or services with one responsibility.
- Make concurrency boundaries explicit and satisfy `Sendable` requirements without unsafe annotations unless the safety argument is documented.
- Avoid force unwraps, force casts, and `try!` in production code. If an invariant genuinely makes one appropriate, explain it in code and cover it with a test.
- Keep view bodies declarative; place state transitions and asynchronous work in testable models or services.
- Give new UI meaningful accessibility labels, support Dynamic Type and VoiceOver ordering, and respect reduced-motion settings.
- Use user-facing language from the plan: exact printing, physical copy, indicative value, Collection, Decks, Scan, and Value.

## Testing and verification

Every issue must satisfy the tests and acceptance criteria in its body. Add regression coverage for every bug fix.

Once the Xcode project exists, discover available schemes with:

```sh
xcodebuild -project apps/ios/Bowerkeep.xcodeproj -list
```

Build and test with an installed iPhone 15-or-newer simulator destination. Record the exact project, scheme, destination, and command used in the pull request. Do not claim a build or test passes without fresh command output showing a successful exit.

Always run these repository checks before review:

```sh
git diff --check
git status --short
```

Verification must also confirm, as applicable:

- no live network calls in unit tests;
- database migrations upgrade from every supported schema;
- grouped quantities reconcile to physical-copy records;
- backup and restore preserve integrity and support rollback;
- no private fixture data or scan images are tracked;
- UI changes include accessibility coverage;
- performance-sensitive changes are exercised with 10,000 copies;
- recognition changes preserve conservative auto-add behavior.

## Git and review rules

- Use clear conventional commit subjects such as `feat:`, `fix:`, `test:`, `docs:`, and `chore:`.
- Keep commits reviewable and free of generated build products or unrelated formatting churn.
- Do not rewrite published history or use destructive Git commands.
- Rebase or merge the latest target branch only when necessary and resolve conflicts deliberately; never accept an entire side blindly.
- A pull request must include a concise summary, linked issue, test evidence, known limitations, and screenshots for visible UI changes.

## Definition of done

An issue is done only when its acceptance criteria are satisfied, required tests pass, privacy and architecture constraints still hold, documentation is current, the branch contains no unrelated changes, and the pull request provides reproducible verification evidence.
