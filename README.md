# Bowerkeep

**Every card in its place.**

Bowerkeep is a personal, native iPhone app for rapidly scanning individual English Magic: The Gathering cards, recording exact physical printings, tracking collection and Commander deck locations, and highlighting cards with an indicative value of A$20 or more.

## Status

Bowerkeep is in pre-implementation planning. The approved scope and architecture are documented in the [MVP implementation plan](docs/superpowers/plans/2026-08-30-bowerkeep-mvp.md), and delivery is tracked in the [Bowerkeep MVP milestone](https://github.com/auleewilliams/Bowerkeep/milestone/1).

The first implementation issue is [#1: Create the Xcode project and module scaffold](https://github.com/auleewilliams/Bowerkeep/issues/1).

## MVP principles

- Native SwiftUI application targeting iOS 18+ and iPhone 15 or newer.
- Local-first, app-managed SQLite storage through GRDB.
- Exact physical-copy and printing tracking rather than aggregate card names alone.
- Offline collection and deck access; network access only for identification and price refresh.
- Conservative OCR-assisted recognition that routes ambiguity to review.
- Explicit backup, transactional restore, and CSV export.
- No retained scan photographs, backend, login, binder scanning, or MTG Mate automation in v1.

## Prerequisites

- A Mac with the current stable Xcode installed and selected.
- An iOS 18-or-newer simulator or an iPhone 15-or-newer development device.
- Git and GitHub CLI for the issue-per-branch workflow.

After installing Xcode, launch it once to complete first-run setup, then verify the selected developer directory:

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

## Repository layout

The repository will grow into this structure as the MVP issues are implemented:

```text
.
├── apps/ios/                       # Xcode project, app, and test targets
├── docs/architecture/              # Architecture index and decision records
├── docs/superpowers/plans/         # Approved implementation plans
├── AGENTS.md                       # Mandatory agent and contributor workflow
├── README.md
└── .gitignore
```

## Development workflow

1. Choose an unblocked implementation issue from the MVP milestone.
2. Read its parent issue, blockers, acceptance criteria, and linked plan section.
3. Create a dedicated `codex/issue-<number>-<short-slug>` branch or worktree.
4. Implement only that issue, using test-driven development for behavior changes.
5. Run and record every required verification command.
6. Open a focused pull request containing `Closes #<number>`.

The complete rules are in [AGENTS.md](AGENTS.md). Do not implement directly on `main`.

## Build and test

Issue #1 will establish the Xcode project and its schemes. After it lands, list the available schemes with:

```sh
xcodebuild -project apps/ios/Bowerkeep.xcodeproj -list
```

Use an installed iPhone 15-or-newer simulator for builds and tests, and record the exact commands and destinations in each pull request.

## Data and privacy

Bowerkeep's collection database is local and user-controlled. Scan photographs are never retained after recognition or cancellation. Personal databases, backups, credentials, and the private real-device fixture set must never be committed.

## License

This project is available under the terms in [LICENSE](LICENSE).
