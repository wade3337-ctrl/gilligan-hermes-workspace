# Deploy Package — TRIM IT UI quality-of-life fixes (2 of them)

**Date:** 2026-07-23
**Prepared for:** Jordan / IT Support (webroot deploy)
**Status:** ✅ Built + verified on **PLAY**, Skipper-approved. **HOLD for prod** until Jason gives the go.
**Change type:** **2 webroot `.cfm` files. No database, no IIS config, no stored procs.**

---

## TL;DR
Two small front-end fixes to the TRIM IT project/profile UI:

1. **Remove the dead "Availability / August 1st" box** from the profile landing page. It was a vestigial
   "Customer Broadcast" widget that just printed one stale `SystemLists` value under an "Availability"
   label — nobody uses it, and its markup even had a stray `"`.
2. **Fix the project-page header running over the tabs.** On any project with a longish name (e.g.
   `==Irvine Unified School District Portfolio==`) the green title wrapped to a 2nd line and spilled down
   onto the tab bar. Reworked the header so the title **flows and grows with the text**, and the tabs
   always sit **below** it. This one reproduces on prod today too — it's a long-standing layout fragility,
   not a play-only bug.

Both are cosmetic/structural HTML+CSS only.

---

## ⚠️ IMPORTANT — apply the DIFFS, do **not** blind-copy the play files
Play's copies of these pages carry other play-side modernization that prod does **not** have (e.g. the
profile shell's newer "fluid" layout). **Overwriting prod's files with play's would drag those unrelated
changes to prod.** So for each file:

1. Pull prod's current copy.
2. `diff` it against the matching `*.ORIGINAL.cfm` here.
   - If **identical** → you may drop in the `*.PATCHED.cfm` directly.
   - If **different** → apply the small change from the `.diff` by hand (they're tiny — see below).
3. **Back up prod's original first** (prod has no `Jasonsrepairs\` — use your normal prod backup location, **not** that folder).
4. Deploy, then hard-refresh (Ctrl+F5) and eyeball.

---

## File 1 — `Profile$Main.HiRes.cfm`  (Bug 1: remove Availability widget)
**Change:** delete the one `apDiv5` / `ProfileWidgetsFrame` block (the iframe that loads
`Maint-Customer-Broadcast.cfm`). See `bug1-availability-widget.diff` — it's a **2-line removal**:

```
-<div id="apDiv5">
-<iframe name="ProfileWidgetsFrame" ... src="Maint-Customer-Broadcast.cfm" ...></iframe></div>
+<!--- ProfileWidgetsFrame (Availability widget) removed 2026-07-23 - vestigial --->
```

- Leave `Maint-Customer-Broadcast.cfm` on disk (harmless; just no longer shown).
- The orphaned `#apDiv5 { ... }` CSS rule can stay (inert) or be removed — cosmetic.
- **Note:** the sibling shells (`Profile$CrewLeader$Main.HiRes.cfm`, `Pad$Profile$Main.HiRes.cfm`,
  `Profile$Main.cfm`) load a *different* widget (`Profile$Widgets.cfm` — real perf widgets) and are
  **not** touched.

## File 2 — `Profile.Project.Detail.cfm`  (Bug 2: header overlap)
**Change:** see `bug2-header-overlap.diff` (~70 lines, but 3 small edits):
1. `#MainDiv` CSS: `position:absolute; top:43px` → **`position:relative; margin:4px 0 0 9px`** (tabs now flow *below* the header).
2. `#apDiv` (title) CSS: drop the fixed `535×29` absolute box → **`flex:1 1 auto; min-width:0`** (grows with text).
3. `#apDiv3` (HTD) CSS: drop absolute box → **`flex:0 0 auto; white-space:nowrap`**.
4. Markup: the `#apDiv` (title) + `#apDiv3` (HTD) divs are **moved** from the bottom of `<body>` into a
   new flowing flex bar **`#ProjHdrBar`** inserted right after `<body>`, above `#MainDiv`. A pre-existing
   stray `</div>` at the old location is removed.

No CF logic changes — same queries, same `#Projects.Desc1#` / `#Company.Nickname#` / HTD iframe.

---

## Files in this package
| File | Purpose |
|---|---|
| `bug1-availability-widget.diff` | The Bug 1 change (unified diff). |
| `bug2-header-overlap.diff` | The Bug 2 change (unified diff). |
| `Profile$Main.HiRes.ORIGINAL.cfm` | Play's pre-fix shell (compare target / rollback of record). |
| `Profile$Main.HiRes.PATCHED.cfm` | Play's post-fix shell (drop-in only if prod == ORIGINAL). |
| `Profile.Project.Detail.ORIGINAL.cfm` | Play's pre-fix project page. |
| `Profile.Project.Detail.PATCHED.cfm` | Play's post-fix project page. |

## Rollback
Restore prod's own pre-deploy backup (step 3 above). The `*.ORIGINAL.cfm` here are play's pre-fix copies
for reference/diffing.

---

## Verification done on PLAY
- Bug 1: widget gone from the landing page; byte-preserving edit (file's special chars untouched); no dangling refs.
- Bug 2: served HTML renders with **0 ColdFusion errors**; `#ProjHdrBar` renders above `#MainDiv`; title/HTD/tabs all present and correct; **Skipper visually confirmed** on the worst-case Irvine project (title wraps 2 lines, tabs sit cleanly below, HTD figures on the right).
- Play backups: `Jasonsrepairs\Profile$Main.HiRes.cfm.avail-widget-bak-20260723-131809` · `Jasonsrepairs\Profile.Project.Detail.cfm.hdroverlap-bak-20260723-135937`.

## Related / future (NOT in this package)
Same fixed-box header pattern likely affects sibling detail pages (`Profile.WorkOrder.Detail.cfm`,
`Profile.GPSWorkOrder.Detail.cfm`, location pages). Propagating the Bug-2 rework to those is a **separate,
pending task** on play — do not bundle here.
