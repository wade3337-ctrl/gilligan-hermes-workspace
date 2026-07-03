---
title: Memory Wiki Redesign — Proposal
type: project
domain: how-we-work
status: in progress — Phases 1, 1b, 2, 3(folded), 4 DONE; Phase 5 (hygiene cron) + cleanup pass remain
updated: 2026-07-02
tags: [memory, wiki, obsidian, retrieval, projects]
links: ["[[ROUTING]]", "[[MEMORY]]"]
---

# Memory Wiki Redesign — Proposal (v0.1)

## Why (the two problems, named)
1. **Gilligan forgets things.** Root cause = *retrieval, not capture*. We write plenty (36 daily logs, 28K MEMORY.md,
   LESSONS, PLAYBOOK) but the right fact isn't surfaced at the right moment: facts sit in daily logs that aren't loaded,
   MEMORY.md is a 28K wall that gets skimmed, and there's no habit of searching before answering.
2. **Projects aren't sorted; the right context isn't applied.** Yesterday a UI got built without the correct
   **style guide** applied — the guide *existed* (`reference/GSTS-UI-STYLE-GUIDE.md`, `arbor-stack/gsts-ui-spec-v1.0.md`)
   but wasn't surfaced when the work started. Symptom of the same disease: reference/standards not *linked to* the
   projects that must use them.

Goal: **better performance** (less token bloat, sharper attention) + **less forgetting** (reliable recall) +
**projects + their standards always discoverable at the moment of work.**

## Principles
- **Home = the OpenClaw workspace** (`~/.openclaw/workspace/`). Plain markdown. **LLM-agnostic** — no dependence on any
  one model's native memory. The folder doubles as an **Obsidian vault** (Skipper can open it to browse the graph;
  Gilligan operates on the files via read/grep/memory_search).
- **Atomic notes** — one concept per file, kebab-case descriptive names, so only the relevant note loads.
- **Dense `[[wikilinks]]`** — every note links its neighbors; projects link the standards/reference they depend on.
- **Lean indexes (Maps of Content / MOCs)** — bootstrap loads a *small map*, not an encyclopedia; notes pulled on demand.
- **Retrieval discipline** — search the wiki before answering from memory; on project start, load the project note
  (which links its reference deps).
- **One home, no split-brain** — retire/redirect the barely-used `.claude` memory; everything lives in the workspace.

## Note schema (frontmatter — consistent, searchable)
```
---
title: <human title>
type: fact | project | reference | person | lesson | playbook | index
domain: work | personal | env | how-we-work
status: <for projects: active | parked | shipped | proposal>   # omit for static facts
tags: [..]
links: ["[[other-note]]", ..]
updated: YYYY-MM-DD
---
body — atomic. For projects: a **Resume pointer** + **Applies/uses:** links (e.g. [[gsts-ui-style-guide]]).
```

## Structure (inside the workspace)
- **Root identity (unchanged):** AGENTS.md, SOUL.md, USER.md, IDENTITY.md, ROUTING.md, RECOVERY.md, TOOLS.md.
- **`wiki/` (new vault of atomic notes)** — the memory graph. Suggested soft-folders (or flat + tags):
  - `wiki/index/` — the MOCs: `HOME.md` (lean top-level, bootstrap-loaded, replaces the fat MEMORY.md), plus
    `PROJECTS.md`, `WORK.md`, `PERSONAL.md`, `ENVIRONMENT.md`, `HOW-WE-WORK.md`.
  - `wiki/projects/` — **one note per project** (status, domain, key files, resume pointer, **Applies:** links to its
    standards). This is the "projects sorted out" fix.
  - `wiki/reference/` — standards & look-it-up notes (style guide, metric standards, schema, access) — each `[[linked]]`
    from the projects that use them.
  - `wiki/facts/` — durable atomic facts (env/infra, people, decisions), migrated out of the MEMORY.md monolith.
- **`memory/` (unchanged role):** raw daily logs — the append-only journal. New rule: distilled into wiki notes, then
  **archived** monthly to `memory/archive/YYYY-MM/` so the live folder stays small.
- **`contracts/` (fold in):** the how-we-do-each-work-type docs become `type: reference` wiki notes (or stay + get linked).
- **LESSONS.md / PLAYBOOK.md:** keep as-is for now (they already work as tagged append logs); linkable later.

## How this kills the style-guide miss
A UI project note (`wiki/projects/…`) carries `Applies: [[gsts-ui-style-guide]] [[gsts-ui-spec-v1]]`. The HOW-WE-WORK
rule + the repair/UI contract say: *on UI work, open the project note first* → the style guide is one hop away, every time.
Reference notes are no longer orphans; they're pulled in by the work that needs them.

## The audit (Skipper asked for this — a discrete phase)
Inventory everything we're actually carrying so nothing is lost and the registry is real:
- Sweep `arbor-stack/`, `arbor-core/`, `steves-projects/`, `release-candidates/`, `live-in-prod/`, root — list every
  live/parked project, its status, key files, resume pointer, and which standards/reference it depends on.
- Output = the `wiki/projects/` notes + the `PROJECTS.md` MOC. Flags: duplicates, orphaned reference, stale/abandoned.

## Phased plan (multi-step — we go one phase at a time, you review between)
- **Phase 0 — this proposal + agree the schema.** (now)
- **Phase 1 — AUDIT + PROJECT REGISTRY.** Inventory projects → `wiki/projects/` notes + `PROJECTS.md`. Highest-value
  first move; directly fixes "projects sorted out" and the style-guide miss.
- **Phase 2 — Decompose MEMORY.md** into atomic `wiki/facts/` + reference notes; build the lean `HOME.md` index; shrink
  the bootstrap load.
- **Phase 3 — Wire standards** as `wiki/reference/` notes, `[[linked]]` from every project that uses them.
- **Phase 4 — Retrieval discipline** baked into AGENTS.md/ROUTING.md (load HOME index; search-before-answer; project-note-on-start).
- **Phase 5 — Hygiene loop:** weekly cron distills daily logs → wiki notes, archives old dailies, prunes/dedupes, keeps
  indexes lean. (Extends the existing weekly-self-review cron.)

## Open questions for the Skipper
1. Soft-folders (`wiki/index|projects|reference|facts/`) vs **flat `wiki/` + tags** (more Obsidian-purist)? (Lean: soft-folders — easier for me to grep by kind.)
2. Start Phase 1 (audit) next, or refine this proposal/schema first?
3. Anything you want treated as its own top-level domain beyond work / personal / env / how-we-work?
