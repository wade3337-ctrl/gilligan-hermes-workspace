# GSTS UI Style Guide (v2 — 2026-06-09)
**The canonical Great Scott look. Apply to every existing screen and every new build (TrimIT + Arbor AI).**
Derived from the **live production CSS** (`gsts-tokens.css` + Price Buddy `pricing-guide.css`) — this is
what Jason actually built, with real values, not a guess. Pair this doc with **`gsts-theme.css`**.

## How to use (for you, Codex, or Herman)
1. Attach this file + `gsts-theme.css` whenever asking an AI to build or update a GSTS/Arbor screen.
2. Link the theme on the page, put `class="gsts"` on `<body>`, and build with the `.gsts-*` classes.
3. **Never hard-code hex.** Use `var(--gsts-*)` tokens only.
4. **Mobile-first is law:** 44px minimum tap targets, 16px inputs (stops iOS zoom), works ~360px → ultrawide.
5. Back up before editing existing files (timestamped, per the standing rule).

## The look in one paragraph
Clean operations-dashboard style on a light slate background (`#f7f9fb`), white cards with soft shadows
and 6px corners. The signature is the **green gradient** (`135deg, #5C743D → #405528`) on the app bar and
section headers, white text on green, and green-filled active states (pills, tabs, selected rows). Status
reads in plain color + text: green `#166534` good, red `#c62828` bad. Everything is touch-friendly.

## Palette (real, in-use)
| Token | Value | Use |
|---|---|---|
| `--gsts-brand-green` | `#5C743D` | app bar, section headers, active/selected, table headers, accents |
| `--gsts-brand-green-grad` | `#405528` | gradient partner + green text on cards |
| `--gsts-brand-green-deep` | `#2A3A18` | deepest green (deep accents). ⚠️ tokens.css comment calls this the "Pro-Tip bg" — **STALE/WRONG**, see Pro-Tip note below |
| `--gsts-brand-green-pale` | `#D5EDB3` | pale green (light fills). ⚠️ tokens.css comment calls this the "Pro-Tip header" — **STALE/WRONG**, see below |
| `--gsts-body-bg` | `#f7f9fb` | page background |
| `--gsts-surface` / `--gsts-border` | `#fff` / `#e5e7eb` | cards, tables, inputs / borders |
| `--gsts-text` / `--gsts-text-muted` | `#1f2937` / `#475569` | text / labels |
| `--gsts-good` / `--gsts-bad` | `#166534` / `#c62828` | on-target / off-target |

## Components (classes in `gsts-theme.css`)
- `.gsts-appbar` + `h1` + `.gsts-summary` — 56px gradient header with a right-aligned stat pill.
- `.gsts-section-header` (`strong` + `span`) — green banner atop a card/report.
- `.gsts-card` + `.gsts-card-title` — white panel, 6px radius, soft shadow.
- `.gsts-table` (+ `.gsts-table-scroll`) — green header row, hairline borders.
- `.gsts-btn` / `.gsts-btn-primary`, `.gsts-pill` (`.is-selected`), `.gsts-segmented` (`a.active`) — green-filled when active.
- `.gsts-kpi` (`-label`/`-value`) and `.gsts-badge` (`.good`/`.watch`/`.poor`) — KPIs + status badges.
- `.gsts-good` / `.gsts-bad` — inline status text (e.g. TPH).
- **⭐ Pro-Tip popover — DECISION (Skipper, 2026-07-02): GO-FORWARD CANONICAL = the NEWER `assets/protips/` mechanism.** There are TWO pro-tip systems (this is what kept confusing us). **Build all new work on the newer one; the legacy one retires over time.**
  - **✅ CANONICAL (newer, go-forward):** `protips-include.cfm` (shared include) → loads `assets/css/gsts-tokens.css` + `assets/protips/protips.css` + `assets/protips/protips.js`; triggers via **`protip-key` attributes** (registry-driven). Classes `.gsts-protip` / `.gsts-protip__header` / `.gsts-protip-badge`, JS toggles `.show`. Used by the newer pages: Exec suite (Financial Overview Beta, Close%, Sales-by-Market/Rep/Crew), City Budgets, SPM, Reference, ZTest-Cockpit/SiteMap. arbor-core's `ProTip` component matches this. **⚠️ These assets 404 on PROD today → when deploying a newer page, SHIP its 3 protip assets with it (they just get ADDED; nothing to overwrite). The SPM deploy package already lists them — KEEP them.**
  - **⛔ LEGACY (retire over time):** `css/gsts-protips.css` (+ `js/pro-tips.js`) — uses `.pro-tip`/`.tip` classes. It's what PROD's ~15 older pages currently load (CustomerLeads, RevenuePerformance, SalesCommand/Pipeline/Queue, MarketFocus, ClosePercentage$ByRep, Sales$Overview, ClusterDefs). Leave them until touched; **migrate a legacy page to the newer mechanism opportunistically when you're already in it**, then once all are across, delete `css/gsts-protips.css`.
  - **The REAL look (both systems share it):** light-green body `rgb(240,245,230)`, olive text `rgb(64,85,40)`, 1px + 4px-left olive border `rgb(92,116,61)`, olive header bar `rgb(92,116,61)` white bold title, 8px radius, shadow `0 12px 28px rgba(92,116,61,.25)`. Trigger badge = 14px olive circle, white "?". (NOT the deep-green the `tokens.css` comment claims — that comment is stale.)
  - **Discipline:** ONE system per page (a few load BOTH — e.g. Exec Financial Overview — trim those to pure-newer when touched). Don't add a THIRD. They coexist safely meanwhile (different class names).

## Typography & shape
- Font: system stack (`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, …`). No web fonts.
- Sizes: app-bar h1 18/600 · card & section titles 15/600 · KPI value 30/700 · body/table 13–14 · labels 12/600.
- Radius 6px (cards/buttons/inputs), 8px (highlight panels/pro-tip). Inputs/buttons ≥ 44px tall.

## Do / Don't
- ✅ Tokens for every color; green gradient for headers; 44px tap targets; 16px inputs; status as color **and** text.
- ❌ Don't reuse the old `style.css` — that's leftover **template boilerplate** (blue `#00a9ff`, fixed 984px,
  sliders, social footer). It is NOT the brand. Don't propagate it.
- ❌ Don't introduce new third-party UI libraries; vanilla CSS/JS + these classes.

## Notes for maintainers
- Two source files already live in the app: `/gsts/assets/css/gsts-tokens.css` (colors) and the per-page CSS.
  `gsts-theme.css` consolidates and generalizes them so any page can adopt the full system with one link.
- Minor real-world drift to be aware of: the deployed `--gsts-brand-green-deep` is `#2A3A18`, but the Price
  Buddy header gradient uses `#405528` as its dark partner. The theme captures both (`-deep` vs `-grad`).
- Supersedes `gsts-ui-spec-v1.0.md` **for color/hex values only** (its hexes were estimates, e.g. `#5a7a3a`; use these real ones).
- **For COMPONENT behaviors — Welcome/Intro Modal, Pro-Tip pop-ups, drill-downs, filters — see `arbor-stack/gsts-ui-spec-v1.0.md`.** Notably **Section 2A (Welcome / Intro Modal)** is REQUIRED on every dashboard set's front page, with **colored-emoji** content (Skipper-approved style, Jun 19 2026). Canonical: `Executive$Financial$Overview$Frame$Beta.cfm` + `SalesProductionMeetingDashboard.cfm`.
