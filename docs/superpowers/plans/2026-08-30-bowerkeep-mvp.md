# Bowerkeep MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task.

**Goal:** Build a personal, native iPhone app that rapidly scans individual English MTG cards, records exact physical printings, tracks collection and Commander deck locations, and flags cards with an indicative value of A$20 or more.

**Architecture:** Bowerkeep is a local-first SwiftUI application backed by an app-managed SQLite database. Camera recognition, catalogue access, pricing, and persistence are isolated behind protocols so a future .NET 10 Minimal API can be added without rewriting the scanning or UI layers.

**Tech Stack:** iOS 18+, Swift 6, SwiftUI, AVFoundation, Vision, GRDB 7.11.1, Swift Testing, and XCUITest.

**Spec:** The approved product design is incorporated into this plan.

## Global Constraints

- Target iPhone 15 or newer and install personally through Xcode.
- Support English cards and one-card-at-a-time scanning only.
- Keep the collection and decks usable offline; identification and price refresh require internet.
- Store no scan photographs after recognition or cancellation.
- Use an app-managed SQLite file with explicit backup, restore, and CSV export.
- Do not add a backend, login, binder-page scanning, image-similarity model, or MTG Mate automation in v1.
- Preserve sync-ready identities and change metadata for a future .NET 10 Minimal API.

---

## Repository and Architecture

Use a future-ready monorepo:

```text
bowerkeep/
├── apps/ios/
│   ├── Bowerkeep.xcodeproj
│   ├── Bowerkeep/
│   ├── BowerkeepTests/
│   └── BowerkeepUITests/
├── docs/
│   ├── architecture/
│   └── superpowers/plans/
├── README.md
└── .gitignore
```

Bootstrap requirements:

- Install current stable Xcode; the development Mac currently has Swift and .NET 10 but not full Xcode.
- Target iOS 18+, Swift 6 strict concurrency, and iPhone 15 or newer.
- Use bundle identifier `au.com.leew.bowerkeep`.
- Add GRDB 7.11.1 through Swift Package Manager for SQLite persistence and backups.
- Use SwiftUI, AVFoundation, Vision, Swift Testing, and XCUITest.
- Commit the standard Xcode project; do not introduce XcodeGen or Tuist.

### Core contracts and types

Define domain models independently of SQLite or network DTOs:

- `CardPrinting`: Scryfall ID, Oracle ID, name, set, collector number, language, type line, supported finishes, and image URL.
- `OwnedCardCopy`: UUID, printing ID, finish, condition, deck location, commander flag, and sync metadata.
- `Deck`: UUID, name, timestamps, revision, and deletion metadata.
- `ScanSession` and `RecognitionEvent`: destination, timing, candidate outcome, confidence, and correction result—never the card photograph.
- `PriceRecord`: printing, finish, USD minor units, and retrieval date.
- `SyncMetadata`: created, modified, and deleted timestamps; client revision; and origin-device UUID.
- `CardFinish`: non-foil, foil, or etched.
- `CardCondition`: Near Mint, Played, or Damaged.
- `InventoryLocation`: main collection or a deck UUID.

Expose these internal interfaces:

```swift
protocol CollectionRepository: Sendable
protocol CardCatalog: Sendable
protocol CardRecognizer: Sendable
protocol ExchangeRateProvider: Sendable
protocol BackupService: Sendable
```

Screens and scanning workflows depend only on these interfaces. SQLite is the initial `CollectionRepository`; a future remote or synchronizing implementation can be added without rewriting the camera or UI.

## Implementation Tasks

### Task 1: Project foundation and persistence

- Create the iOS app and test targets under `apps/ios`.
- Organize code by feature (`Scan`, `Collection`, `Decks`, `Value`, and `Settings`) with shared domain, persistence, networking, and camera modules.
- Build a GRDB-backed `AppDatabase` with versioned migrations and indexed tables for printings, physical copies, decks, scan events, prices, exchange rates, and settings.
- Represent a card in the main collection with a null deck ID; moving a copy changes its location rather than duplicating it.
- Preserve deleted entities as tombstones for future synchronization.
- Add repository tests for duplicate copies, deck moves, commander flags, soft deletion, migrations, and 10,000-copy query performance.
- Commit as `feat: establish Bowerkeep domain and persistence`.

### Task 2: Catalogue and valuation services

- Implement Scryfall lookup by exact set and collector number, fuzzy name, and batched Scryfall IDs.
- Send `User-Agent: Bowerkeep/0.1 (iOS; personal collection manager)` and the recommended JSON `Accept` header.
- Throttle requests to one every 150 ms and cache card data and prices for at least 24 hours. Scryfall asks clients to remain below ten requests per second and to cache or batch large lookups.
- Use finish-specific Scryfall USD values and Frankfurter’s ECB-backed USD-to-AUD rate, cached daily.
- Refresh distinct printings—not every physical copy—in batches on explicit request or app launch when data is stale and the network is not marked expensive.
- Treat prices as indicative retail-market data. Display source and timestamp; never present them as a confirmed MTG Mate offer.
- Cover exact, fuzzy, empty, malformed, throttled, stale, and unavailable responses with stubbed-network tests.
- Commit as `feat: add card catalogue and valuation services`.

References:

- [Scryfall API guidance](https://scryfall.com/docs/faqs/i-m-having-trouble-accessing-the-scryfall-api-or-i-m-blocked-17)
- [Frankfurter API](https://frankfurter.dev/)

### Task 3: Camera and recognition pipeline

- Request camera permission and provide manual search when access is unavailable.
- Show a card-shaped guide and process only its title and footer regions.
- Run fast OCR on live frames. Trigger a high-quality still capture after three consistent title readings while focus and exposure are stable; retain a manual shutter.
- Run accurate OCR on the still image and extract title, set code, collector number, language, and copyright year where available.
- Resolve candidates in this order:
  1. Unique set-code and collector-number match.
  2. Fuzzy title lookup ranked by collector number, year, frame clues, and English language.
  3. Manual “view all printings” search for old or ambiguous cards.
- Auto-add only when set, collector number, and normalized title resolve to one printing and each OCR field has confidence of at least 0.85.
- Send any disagreement or missing exact-printing evidence to review; never silently select a printing.
- Prompt for non-foil, foil, or etched whenever multiple finishes exist.
- Discard captured images after recognition or cancellation.
- Unit-test OCR normalization, footer parsing, confidence gates, candidate ranking, double-faced cards, and ambiguous printings.
- Commit as `feat: add card capture and recognition pipeline`.

### Task 4: Scanning and collection experience

Create four tabs: Scan, Collection, Decks, and Value.

The scan session must:

- Select Collection or a named deck as its destination.
- Select a default condition.
- Provide continuous scanning, haptic and audio confirmation, running quantities, and immediate undo.
- Pause only for finish selection or ambiguous-printing review.
- End with totals, unresolved cards, and newly discovered high-value cards.

Collection management must support:

- Search, set, finish, condition, and location filters plus grouped quantities.
- Exact-printing details and cached card imagery.
- Manual add, edit, move, and delete.
- Separate physical-copy records even when the UI groups identical cards.

Add view-model and UI tests for permission denial, continuous scanning, ambiguity review, finish choice, undo, manual entry, filtering, and location moves.

Commit as `feat: build scanning and collection workflows`.

### Task 5: Commander deck tracking

- Support named Commander decks and one or more commander flags.
- Scan directly into a deck or move existing copies into it.
- Count physical cards including commanders.
- Show non-blocking warnings for counts other than 100 and duplicate non-basic names.
- Move contained cards back to Collection when a deck is deleted.
- Do not implement a full Commander legality or deckbuilding engine in v1.
- Test deck creation, commander marking, physical allocation, duplicate warnings, count warnings, moves, and deck deletion.
- Commit as `feat: add physical Commander deck tracking`.

### Task 6: Value alerts and MTG Mate handoff

- Default the configurable high-value threshold to A$20 per physical card.
- Group identical copies while showing unit and aggregate indicative values.
- Separate Near Mint high-value cards into “Check with MTG Mate.”
- Show Played and Damaged cards as valuable without describing them as likely MTG Mate candidates.
- Link to MTG Mate’s public buylist and remind the user to verify current acceptance terms.
- Do not scrape MTG Mate pricing, automate its cart, or claim an offer amount.
- Test threshold boundaries, finishes, missing and stale prices, condition grouping, duplicate values, and manual refresh.
- Commit as `feat: add AUD value alerts`.

Reference: [MTG Mate buylist](https://www.mtgmate.com.au/buylist/)

### Task 7: Backup, restore, and export

- Register a `.bowerkeep` backup document type containing a consistent SQLite backup.
- Create backups with SQLite’s backup API, then run an integrity check before sharing through Files or AirDrop.
- Inspect an imported backup before restore and show copy, deck, and schema counts.
- Accept older schemas by migrating them; reject newer unsupported schemas.
- Before replacement, preserve the current live database as a rollback backup, atomically install the import, reopen it, and verify integrity.
- Export a separate CSV containing quantity, card, set, collector number, finish, condition, location, commander status, Scryfall ID, USD value, indicative AUD value, and price timestamp.
- Treat CSV as an inspection and sharing format, not a restoration format.
- Test interrupted writes, integrity failures, rollback, older and newer schemas, and full backup/restore equivalence.
- Commit as `feat: add collection backup and export`.

### Task 8: Hardening and real-device acceptance

- Add accessibility labels, Dynamic Type support, VoiceOver ordering, and reduced-motion behavior.
- Verify responsive search, grouping, moves, and deck counts with 10,000 physical-copy records.
- Maintain a private, uncommitted 200-card English fixture set covering modern, old-frame, borderless, promo, foil, etched, and double-faced cards.
- On an iPhone 15 or newer, require:
  - At least 95% of fixture cards resolve to the correct exact printing automatically or within the top three candidates.
  - Auto-added cards achieve at least 99% exact-printing precision.
  - Median feedback arrives within 2.5 seconds after the card is steady.
- Run all unit tests, UI tests, database performance tests, backup round trips, and the real-device fixture pass.
- If OCR misses its target, narrow auto-add eligibility and preserve manual review; do not add image-similarity recognition without a separately approved design.
- Commit as `test: verify Bowerkeep MVP acceptance criteria`.

## Assumptions and Defaults

- Product name: **Bowerkeep**.
- Tagline: **Every card in its place**.
- Personal installation through Xcode; no App Store release work in v1.
- SQLite remains the offline source of truth if a backend is introduced.
- A later backend will use .NET 10 Minimal APIs, authenticated users, stable client-generated IDs, and the existing repository and domain contracts. .NET 10 is currently an active LTS release through November 2028.
- Image-similarity recognition is deferred until real fixture results demonstrate that OCR plus catalogue lookup cannot meet the approved accuracy targets.

Reference: [Microsoft .NET support policy](https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core)
