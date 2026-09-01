# Handoff: Bowerkeep MVP — Scan, Collection, Decks, Value

## Overview

Bowerkeep is a local-first iOS app for cataloguing a physical Magic: The Gathering
collection by scanning cards with the camera. This handoff covers the six screens the
owner prioritised for the MVP, plus the two modal decision points that make scanning
trustworthy:

1. **Scan** — live camera, running session tally, OCR readout
2. **Finish prompt** — modal, shown when a printing has multiple finishes
3. **Ambiguity review** — modal, shown when no exact printing can be determined
4. **Session summary** — shown when the user taps Done
5. **Collection** — compact table of every physical copy, with filters
6. **Card detail** — one exact printing, its copies, and Move…
7. **Deck detail** — Commander deck, 100-card validation
8. **Value** — cards over the A$20 threshold, MTG Mate handoff
9. **Settings** — thresholds, backup, restore, CSV export

The design vocabulary comes directly from `docs/superpowers/plans/2026-08-30-bowerkeep-mvp.md`
in the Bowerkeep repo: *exact printing*, *physical copy*, *indicative value*, the A$20
high-value threshold, and the MTG Mate handoff being a link rather than an integration.

## About the design files

`Bowerkeep.dc.html` in this bundle is a **design reference created in HTML** — a
prototype showing intended look and behaviour. It is not production code to port.

The task is to **recreate these designs in SwiftUI** in the Bowerkeep repo, following
the patterns and guardrails already set out in that repo's `AGENTS.md` and architecture
docs. At the time of the handoff the repo is pre-implementation (plan and architecture
docs only, no Swift source), so the implementing agent is establishing the view layer,
not fitting into an existing one.

Two things in the HTML are deliberately not real and must not be reproduced literally:

- **Card art** is a diagonal-stripe placeholder. Real art comes from Scryfall image
  URLs, cached on disk per the plan's caching task.
- **Camera preview** is a diagonal-stripe fill. Real implementation is an
  `AVCaptureVideoPreviewLayer` filling the same region.

## Fidelity

**High-fidelity.** Colours, typography, spacing and interaction states are final and
should be matched. Fonts are web families standing in for iOS choices — see
*Typography* below for the substitution to make in SwiftUI.

## Design tokens

### Colour

| Token | Hex | Use |
| --- | --- | --- |
| `paper` | `#F2EDE2` | App background, light screens |
| `paperRaised` | `#FAF7F0` | Cards, grouped list rows, sheets over paper |
| `ink` | `#1F1C17` | Primary text, toast background, dark tab bar |
| `inkMuted` | `#6B6459` | Secondary text, table values |
| `inkFaint` | `#8A8172` | Column headings, captions, metadata |
| `rule` | `rgba(31,28,23,0.07)` | Table row separators |
| `ruleStrong` | `rgba(31,28,23,0.12)` | Card borders, header/footer rules |
| `forest` | `#3D5C47` | Accent: primary buttons, active tab, links, filter chip on |
| `forestLight` | `#5C8A6B` | Scan lock-on indicator (on dark) |
| `forestWash` | `rgba(61,92,71,0.07)` | Commander row highlight, MTG Mate banner |
| `ochre` | `#8F6B2F` | High-value amounts (≥ A$20), warnings |
| `ochreWash` | `rgba(143,107,47,0.10)` | Deck validation warning background |
| `ochreText` | `#6F5828` | Text on `ochreWash` |
| `night` | `#14120F` | Scan screen background, scan-mode tab bar |
| `nightRaised` | `#1E1B16` | Panels on the scan screen |
| `cream` | `#F4F0E6` | Text and shutter on `night` |
| `creamMuted` | `rgba(244,240,230,0.50)` | Secondary text on `night` |
| `creamFaint` | `rgba(244,240,230,0.28)` | Unlocked capture guide |
| `brass` | `#C8B06A` | Done affordance and Undo-in-toast on dark |

Rule: an amount is rendered in `ochre` when it is at or above the user's high-value
threshold (default A$20.00) and in `inkMuted` otherwise. This single rule drives the
colour of every price in the app.

### Typography

Three roles. The web families in the prototype map to iOS as follows:

| Role | Prototype | SwiftUI | Used for |
| --- | --- | --- | --- |
| Card name | Lora (serif), weight 600 | `.system(.body, design: .serif).weight(.semibold)` or New York | Card names, screen titles |
| UI | Archivo, weights 400/500/600 | `.system(design: .default)` (SF Pro) | Labels, buttons, body copy |
| Data | JetBrains Mono, weights 500/700 | `.system(design: .monospaced)` | Set codes, collector numbers, quantities, money, copy IDs, timestamps |

Sizes as used (px in the prototype = pt in SwiftUI):

| Element | Size / weight / line-height |
| --- | --- |
| Screen title (serif) | 27 / 600 / 1.1 |
| Summary headline (serif) | 30 / 600 / 1.1 |
| Card name in table (serif) | 15 / 600 / 1.15 |
| Card name in scan readout (serif) | 22 / 600 / 1.1 |
| Detail card name (serif) | 25 / 600 / 1.1 |
| Sheet title (serif) | 20–22 / 600 / 1.15 |
| Body / row label (sans) | 13.5 / 500 |
| Button label (sans) | 14–14.5 / 600 |
| Caption (sans) | 10.5–12 / 400 / 1.35–1.45 |
| Tab label (sans) | 10 / 600 |
| Section eyebrow (mono) | 9–10 / 500, letter-spacing 0.12em, uppercase |
| Table column head (mono) | 8.5 / 500, letter-spacing 0.11em, uppercase |
| Table data (mono) | 10.5–12.5 / 500 |
| Money in table (mono) | 11.5 / 600 |
| Big numeral (mono) | 22–34 / 700 / 1 |

All-caps mono strings are a deliberate motif: they mark machine-derived facts (set code,
collector number, condition, timestamps, integrity status). Never set human-facing prose
in mono.

### Spacing, radius, elevation

- Screen horizontal margin: **18**. Sheet padding: **20** sides, **46** bottom.
- Grouped card padding: **12–14**. Table row vertical padding: **11**.
- Radii: sheets **22** (top corners only), cards and buttons **12**, small cards
  **10**, chips and shutter **fully round**, card-art placeholder **8** (thumb **4**).
- No shadows anywhere. Separation is done with 1px rules and background steps
  (`paper` → `paperRaised`). Keep it that way; a shadow would read as a different app.
- Safe areas in the prototype are the iPhone frame's: **59** top inset for content
  under the status bar, **34** bottom for the home indicator. Tab bar is **82** tall
  including that inset, with **9** top padding.

## Screens

### 1. Scan

The centre of gravity. Full-bleed camera with almost no chrome; the tally sits in a
corner and the OCR readout collapses to a single line.

**Layout, top to bottom:**

- Camera preview fills the entire screen, behind everything.
- **Top left**, inset 18 from the left, 68 from the top, width 130, stacked with gap 6:
  a `Done` control (sans 12.5/600, `brass`); a 3pt-tall progress rule, full width,
  radius 2, track `rgba(244,240,230,0.16)`, fill width = title confidence (18% when
  seeking, 96% when locked), fill colour `creamFaint` unlocked / `forestLight` locked;
  and a status line (mono 9, letter-spacing 0.08em, `creamMuted`) reading
  `SEEKING EDGES` or `STEADY · FOCUS OK`.
- **Top right**, inset 18: the session tally. Count in mono 34/700 `cream`, with
  `INTO COLLECTION` beneath in mono 9, letter-spacing 0.12em, `creamMuted`, gap 4.
- **Centred**, a capture guide of four **corner brackets only** — no full rectangle,
  no dimming mask. Frame 268×374 (2.5:3.5, a card's aspect). Each bracket is 34×34,
  3pt strokes on its two outer edges, 10pt radius on its outer corner. Stroke colour
  `creamFaint` while seeking, `forestLight` on lock.
- **Bottom readout**, inset 18, 170 from the bottom, a single baseline-aligned row:
  card name (serif 22/600, `creamMuted` while seeking → `cream` on lock); then set,
  collector number and language (mono 12, `rgba(244,240,230,0.6)`, e.g. `C21 · 263 · EN`,
  `— · — · —` while seeking); then, right-aligned, the lock label (mono 9.5,
  letter-spacing 0.1em, in the guide colour) reading `HOLD STEADY` or `LOCKED 0.96`.
- **Shutter row**, 82 from the bottom, 88 tall, with a gradient scrim from transparent
  to `rgba(20,18,15,0.85)` at 55%. Shutter centred: 76pt circle, `cream` fill, 5pt
  `rgba(244,240,230,0.16)` ring, inner 60pt hairline ring at
  `rgba(31,28,23,0.16)`; scales to 0.94 on press. `Undo` sits at the right edge,
  inset 24, 30 from the bottom — sans 12.5/600, `cream` when there is something to
  undo, `rgba(244,240,230,0.35)` when not.
- **Tab bar** in scan mode uses the dark palette: `night` background, top rule
  `rgba(244,240,230,0.12)`, active item `brass`, inactive `rgba(244,240,230,0.45)`.
- **Recent-adds stack**, inset 18, 212 from the bottom, shown when the session has
  adds and no sheet or toast is up: up to three rows, gap 6, each
  `rgba(61,92,71,0.92)` radius 10, padding 8×11, containing `+1` (mono 11/700,
  `#CFE0D3`), the card name (serif 14/600, `cream`, truncating), and the set code
  (mono 10, `rgba(244,240,230,0.6)`). Newest first.

**Confidence is the point.** The readout must show what OCR actually read — title, set,
collector number, language — before the card is committed, and the lock label must carry
the numeric confidence. Do not simplify this to a checkmark.

### 2. Finish prompt (modal sheet over Scan)

Shown when the resolved printing has more than one finish. Bottom sheet, `paper`,
radius 22 top, over `rgba(14,12,10,0.6)`.

- Eyebrow `FINISH REQUIRED` (mono 9.5, letter-spacing 0.13em, `inkFaint`).
- Card name (serif 22/600). Sub-line (sans 12, `inkMuted`):
  `Return to Ravnica · 51 · three finishes exist for this printing`.
- Three options, gap 8, each a `paperRaised` row, 1px `ruleStrong` border, radius 12,
  padding 14×16, border turns `forest` on hover/press: `Non-foil` / `A$42.60`,
  `Foil` / `A$88.10`, `Etched` / `no price` (the last in `inkFaint` — absent price is
  shown as absent, never as A$0.00).
- Picking a finish dismisses the sheet, adds the copy, and raises a toast.

### 3. Ambiguity review (modal sheet over Scan)

Shown when the footer is unreadable and no exact printing can be determined. Same sheet
shell.

- Eyebrow `REVIEW — NO EXACT PRINTING` in `#8F6B2F`.
- Card name (serif 22/600) and explanation (sans 12, `inkMuted`):
  `Footer unreadable. Ranked by collector number, year and frame.`
- Three candidate rows, gap 8, each 12 padding, `paperRaised`, radius 12, 1px
  `ruleStrong`: 40×56 art thumbnail (radius 4); set and collector number (serif
  14.5/600); year, frame and language (mono 10.5, `inkMuted`); confidence percentage
  right-aligned, centred vertically — the top candidate's in `forest`, the rest in
  `inkMuted`.
- Footer control `View all 31 printings` (sans 13/600, `forest`, centred).

The ranking signals (collector number, year, frame) must be visible. The user is being
asked to make a judgement, so give them what the judgement rests on.

### 4. Session summary

Reached by tapping `Done`. `paper`, padding 66 top / 20 sides / 40 bottom, scrolls.

- Eyebrow `SESSION ENDED · 14 MIN`; headline `47 cards filed` (serif 30/600); sub-line
  `All into Collection, Near Mint by default.`
- Two stat cards side by side, gap 10, `paperRaised`, radius 12, padding 13: numeral
  mono 24/700 and a caption sans 11/500 `inkMuted`. Left: `3` /
  `Unresolved — sent to review`. Right: `2` in `ochre` / `New cards over A$20`.
- `NEW HIGH VALUE` list in a `paperRaised` card: one row per card — name (serif 15/600),
  set code and finish (mono 10.5, `inkMuted`), amount (mono 13/600, `ochre`).
- Provenance line (sans 11/1.5, `inkFaint`): indicative retail-market values from
  Scryfall USD, converted at the ECB daily rate, not an offer.
- Two buttons pinned to the bottom, gap 10: `Review 3` (outline, 1px
  `rgba(31,28,23,0.16)`) and `Scan again` (`forest` fill, `cream` label). Both 15
  padding, radius 12.

### 5. Collection

Compact table — the owner's explicit preference over a card grid.

- Header: title `Collection` (serif 27/600) with `4,912 PHYSICAL COPIES · 1,806 PRINTINGS`
  beneath (mono 10.5, `inkFaint`); `Settings` at the right (sans 12.5/600, `forest`).
- Filter chips, gap 7, horizontally scrolling: `All`, `Foil`, `A$20+`, `In decks`.
  On = `forest` fill with `cream` label; off = transparent with `inkMuted` label and
  1px `rgba(31,28,23,0.18)` border. Padding 7×12, fully round, sans 11.5/600.
- Column header row, 1px rules above and below, padding 7×18, grid
  `26 / 1fr / 74 / 46`, gap 8: `QTY`, `CARD`, `SET · №`, `A$` (right-aligned).
- Rows on the same grid, padding 11×18, 1px `rule` beneath, hover `#EAE4D6`:
  quantity (mono 12.5, `inkMuted`); name (serif 15/600, truncating) over a metadata
  line (mono 9.5, `inkFaint`, e.g. `NON-FOIL · NM · COLLECTION`); set code (mono 10.5,
  `inkMuted`); amount (mono 11.5/600, right-aligned, `ochre` if ≥ threshold).
- Bottom padding 104 so the tab bar never covers the last row.

Filters are exclusive, not additive, in this design. `In decks` shows copies whose
location is not Collection.

### 6. Card detail

Pushed over Collection. `paper`, scrolls.

- Back control `← Collection` at the left, `Edit` at the right (both sans 13/600,
  `forest`).
- Hero row, gap 16: art placeholder 132×184 (radius 8) beside a stack — card name
  (serif 25/600), type line (sans 12, `inkMuted`), then eyebrow `EXACT PRINTING`
  (mono 10, letter-spacing 0.12em, `inkFaint`) over the printing itself on two lines
  (mono 12.5/1.45, `ink`), e.g. `Commander 2021 · 263 · EN` / `non-foil · Near Mint`.
- Facts card (`paperRaised`, radius 12, rows separated by 1px `rule`): `Indicative value`
  → amount (mono 14/600, `ochre` if ≥ threshold); `Physical copies` → count (mono
  14/600); `Location` → name (sans 13/600).
- `COPIES — EACH TRACKED SEPARATELY` card: one row per physical copy — a copy ID
  (mono 10, `inkFaint`, e.g. `COPY A1F4`), its condition (mono 11, `inkMuted`), and its
  location (sans 11.5/600). This is the screen that makes the copy-level model legible;
  it should list every copy, not a count.
- Footer buttons, gap 10: `Move…` (`forest` fill, flexible width) and `Delete`
  (outline, hugging). Both 15 padding, radius 12.

### 7. Move sheet (modal over Card detail)

- Eyebrow `MOVE ONE COPY`, card name (serif 20/600), and the clarification
  `Moving changes the copy's location. It does not create a duplicate.`
- One row per destination — `Collection`, and each deck — showing name (sans 14.5/600)
  and current size (mono 11, `inkFaint`, e.g. `98 cards`). Same row treatment as the
  finish sheet.
- `Cancel` (sans 13/600, `inkMuted`, centred).
- On pick: sheet dismisses, the copy's location changes, and a toast confirms with Undo.

### 8. Deck detail (Commander)

- Title `Sunbird Storm` (serif 27/600) with `COMMANDER DECK · UPDATED 2 DAYS AGO`
  beneath (mono 10.5, `inkFaint`).
- Three-cell stat strip in one bordered `paperRaised` card, cells split by 1px
  `rgba(31,28,23,0.09)`: `98` in `ochre` / `physical cards`; `1` / `commander`;
  `A$740` / `indicative`. Numerals mono 22/700, captions sans 10/500 `inkMuted`.
- Validation banner, `ochreWash`, radius 10, padding 10×12: a `!` glyph (mono 11/700,
  `ochre`) beside the message (sans 11.5/1.4, `ochreText`):
  `98 cards — two short of 100. Duplicate non-basic: Sol Ring ×2.`
  The count going amber is the whole point of the screen — a Commander deck that is
  not exactly 100 singleton cards is an error state the user needs to see immediately.
- Table on grid `1fr / 74 / 58`: `CARD`, `SET · №`, `COND` (right-aligned). The
  commander's row is highlighted `forestWash` and carries a `COMMANDER` eyebrow
  (mono 9.5, letter-spacing 0.1em, `forest`) beneath its name.

### 9. Value

- Title `Value` with `THRESHOLD A$20 · REFRESHED TODAY 08:12` beneath.
- Banner across the full width, `forestWash`, rules above and below:
  `Check with MTG Mate — Near Mint only` (sans 11.5/600, `#2F4A38`) over
  `Indicative only. Verify current acceptance terms on their buylist.` (sans 10.5/1.35,
  `#5B6B5F`).
- Rows: quantity (mono 12, fixed 20 wide); name (serif 15/600) over metadata (mono 9.5,
  `inkFaint`); then a right-aligned pair — line total (mono 13/600, `ochre`) over
  `A$61.40 ea` (mono 9.5, `inkFaint`).
- Second section header `Valuable, played or damaged` on `rgba(31,28,23,0.05)`, holding
  cards above the threshold that are not Near Mint. Their amounts stay `inkMuted` —
  they are worth money but are not buylist candidates.
- Closing card: the Scryfall/ECB provenance sentence, then
  `Open MTG Mate buylist →` (sans 13/600, `forest`). This is a link out, not an
  integration.

### 10. Settings

Three grouped cards, each with a mono eyebrow header and rows split by 1px rules.

- **SCANNING** — `High-value threshold` / `A$20.00` (mono); `Default condition` /
  `Near Mint`; `Auto-add confidence gate` / `0.85`, with the sub-caption
  `Below this, cards go to review`.
- **BACKUP** — `Last backup` over `29 AUG 2026 · 18:04 · 4,912 COPIES · INTEGRITY OK`
  (mono 11, `inkMuted`); `Create .bowerkeep backup` (sans 13.5/600, `forest`) with
  `Files · AirDrop` at the right; `Restore from backup…` with the caption
  `Counts are shown for review first. The current database is kept as a rollback.`
- **EXPORT** — `Export CSV` with the caption
  `For inspection and sharing. Not a restore format.`

The captions here carry the plan's guarantees and should ship as written.

### Toast

`ink` background, radius 12, padding 13×15, inset 18, z above everything. Message in
sans 12.5/1.35 `cream`, with `Undo` at the right (sans 12/600, `brass`). Sits 250 from
the bottom on the scan screen (clear of the shutter row) and 96 from the bottom on
light screens (clear of the tab bar). It replaces the recent-adds stack while visible.

## Tab bar

Four items — `Scan`, `Collection`, `Decks`, `Value` — each a 20×20 mark over a
sans 10/600 label, gap 5. Marks differ by shape rather than by icon in the prototype
(radius 5 / 3 / 3 / round); in SwiftUI use SF Symbols and keep the same order and
labels. Active item takes the accent colour; the bar's palette flips to dark on the
scan screen so the camera is never framed in cream.

## Interactions

Two flows are wired in the prototype and should behave the same way in the app.

**Scan → summary.** Tapping the shutter the first time locks the readout and adds
Sol Ring, incrementing the tally and pushing a row into the recent-adds stack. The
second tap opens the finish prompt (Cyclonic Rift, three finishes). Picking a finish
adds the copy and raises a toast noting it is over the A$20 threshold. The third tap
opens ambiguity review (Counterspell, unreadable footer). Choosing a candidate files it
and toasts. `Undo` removes the most recent add and decrements the tally. `Done` opens
the session summary; from there `Scan again` resets the session and `Review 3` returns
to the review sheet.

**Collection → detail → move.** Chips filter the table. Tapping a row pushes card
detail. `Move…` opens the destination sheet; choosing a destination updates that copy's
location — reflected immediately in the row's metadata line and in the `In decks`
filter — and toasts with Undo.

Transitions: sheets slide up from the bottom, detail pushes from the trailing edge —
both standard iOS. The shutter's only feedback is the 0.94 press scale plus haptics;
no flash, no shutter animation. Lock-on is a colour change on the brackets and the
readout, not a bounce.

## State

Session state, held while scanning: `count` (adds this session), `tally` (recent adds,
newest first, display three), `stage` (what the next capture resolves to), `sheet`
(`nil` | `finish` | `review`), `toast`.

Navigation state: `tab`, `detail` (selected printing or `nil`), `move` (bool),
`settings` (bool), `summary` (bool).

Collection state: `filter` (`All` | `Foil` | `A$20+` | `In decks`), and per-copy
`location`, which is what `Move…` mutates.

The prototype's data is ten hardcoded printings with copy IDs. In the app these come
from the local store described in the plan's Task 1; prices come from the cached
Scryfall snapshot, converted at the stored ECB rate, and are always labelled indicative.

## Assets

None to transfer. Card art is a placeholder in the prototype and comes from cached
Scryfall URLs at runtime. Icons should be SF Symbols. The three fonts are stand-ins;
use the system serif, sans and monospaced faces per *Typography* above.

## Files

- `Bowerkeep.dc.html` — the design. Option `1a` is the interactive prototype and the
  spec; `1b`, `1c`, `1d` and `1e` are the alternate scan overlays, navigation model and
  dark-ground treatment that were explored. **`1a` already carries the chosen `1c`
  overlay** — build `1a`, and treat the other options as rejected unless told otherwise.
- `ios-frame.jsx` — the iPhone bezel the prototype renders inside. Presentation
  scaffolding only; nothing in it is part of the design.
- `github.md` — records which plan tasks each screen was derived from.

## Worktree and PR

The design work was done with read-only access to the repo, so the branch and PR are
still to be created. Suggested shape:

```sh
git -C /path/to/Bowerkeep fetch origin
git -C /path/to/Bowerkeep worktree add ../bowerkeep-mvp-ui -b feat/mvp-ui origin/main
cd ../bowerkeep-mvp-ui
```

Land the work as reviewable commits rather than one drop — design tokens and shared
row/table primitives first, then Collection and Card detail, then Scan with its two
sheets and the summary, then Deck detail, Value and Settings. Then:

```sh
git push -u origin feat/mvp-ui
gh pr create --base main --title "MVP UI: scan, collection, decks, value" \
  --body "Implements the six MVP screens from the design handoff. See design_handoff_bowerkeep_mvp/README.md."
```

Check `AGENTS.md` in the repo first — it sets the commit and review conventions this
PR should follow.
