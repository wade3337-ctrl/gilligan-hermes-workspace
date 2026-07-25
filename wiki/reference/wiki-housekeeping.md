---
title: Wiki housekeeping standard
type: reference
domain: how-we-work
tags: [standard, wiki, memory, hygiene, linting, zettelkasten]
links: ["[[self-improvement-loop]]", "[[ROUTING]]", "[[HOME]]", "[[data-freshness-contract]]"]
updated: 2026-07-25
---

# 🧹 Wiki housekeeping standard

**Adopted 2026-07-25** after the first full audit of the vault (146 notes). Automated by **`wiki-lint.py`** (weekly cron, Sun 16:10 UTC — reports only when something is wrong).

## The five principles

1. **Links are the asset, not the notes.** A note nobody can reach does not exist. **MOC coverage outranks tidiness.**
2. **Every note reachable two ways** — by `[[link]]` from a related note *and* from an `index/` map. Search is a fallback, never the navigation strategy.
3. **Frontmatter is the machine-readable contract.** `title · type · domain · tags · links · updated`, always. Without it, hygiene cannot be automated — and manual hygiene does not survive a busy week.
4. **Archive what was true; delete only what was wrong.** A superseded fact gets *corrected in place* (with the old value noted). A point-in-time record gets *kept*.
5. **`updated:` is a lie detector.** A note claiming "in progress" that has not moved in 45 days is worse than no note — it actively misleads. `wiki-lint` flags those 🔴, harder than merely-old notes.

## Deliberate exceptions — things that are NOT defects
| Looks wrong | Why it's fine |
|---|---|
| **Dangling `[[forward-reference]]`** | `AGENTS.md`: an unmatched link "marks something worth writing later." The lint separates **typos** (case mismatch, illegal chars) from **planned** notes and only fails on typos. |
| **`[[links]]` inside `code spans`** | Illustrative, not navigation. The linter strips code spans and fences before scanning. |
| **`wiki/README.md`** | Documents the format *using example links*. Skipped. |
| **Point-in-time records** (monthly P&L, financial snapshots) | Immutable audit trail. **Do NOT merge them into a rolling note** — that destroys auditability, which matters while diligence is live. |
| **Long verbatim source documents** (e.g. the 2,516-line employee handbook) | Atomicity applies to **our knowledge**, not to a copy of someone else's document — splitting it would make it *wrong*. Goes to **`wiki/_archive/`**: still a valid `[[link]]` target, exempt from quality checks. |

## The routine
- **Weekly (automatic):** `wiki-lint.py --quiet` → `logs/wiki-lint.log`. Silence = clean.
- **On demand:** `bash wiki-lint.sh` for the full report.
- **When capturing:** check for an existing note first — **update, don't duplicate**; add the `[[link]]` *and* the MOC line in the same pass. A note added without a MOC entry is half-added.
- **Exit codes:** 0 clean · 1 problems (typos / orphans / frontmatter). MOC gaps and staleness are reported but do not fail the run.

## Baseline achieved 2026-07-25
From the first audit → **0 broken links · 0 orphans · 0 MOC gaps · 0 frontmatter defects · 0 stale notes**, across 145 notes + 1 archived. Fixed in that pass: 3 link typos, 13 frontmatter defects, **37 MOC gaps** (mostly project entries written as **bold text** instead of `[[links]]` — they read fine but were invisible to navigation), and the handbook archived.
