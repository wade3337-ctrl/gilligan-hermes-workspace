---
title: Wiki — Vault Conventions
type: index
domain: how-we-work
updated: 2026-07-02
tags: [wiki, conventions, obsidian]
links: ["[[PROJECTS]]", "[[PROPOSAL]]"]
---

# 🧭 Wiki vault — how it works

Atomic, `[[linked]]` markdown notes. LLM-agnostic (plain files in the OpenClaw workspace); opens as an Obsidian vault.
Folders: `index/` (MOCs), `projects/` (one note per project), `reference/` (standards & look-it-up), `facts/` (durable atomic facts).

**Link names = filenames without `.md`, kebab-case.** e.g. `[[gsts-ui-style-guide]]` → `reference/gsts-ui-style-guide.md`.
Link liberally; a `[[link]]` with no file yet just marks a note worth writing.

## Project note template
```
---
title: <Name>
type: project
domain: work | work-arbor-core
track: 1 | 2
status: shipped | active | parked | blocked | proposal | archived   # + emoji 🟢🔵⏸️🔴📝🗄️ in body
tags: [..]
applies: ["[[gsts-ui-style-guide]]", ..]   # standards/contracts this work MUST follow
links: ["[[related-note]]", ..]
updated: YYYY-MM-DD
---
# <Name>
**One-liner:** …
**Status:** 🔵 active — <short state>
**📁 Location:** `path`
**▶️ Resume:** `path/to/checkpoint-or-spec`

## Applies / uses
- [[gsts-ui-style-guide]] — why it applies

## State & flags
- … (open items, blockers, gotchas)

## Related
- [[other-project]]
```

## Reference note template
```
---
title: <Standard>
type: reference
domain: how-we-work | work
tags: [..]
links: [..]
updated: YYYY-MM-DD
---
# <Standard>
**What it is:** …
**📁 Source:** `path`
**Used by:** [[project-a]], [[project-b]]
## Key rules
- …
```

See exemplars: `projects/rc-03-city-budgets.md` · `reference/gsts-ui-style-guide.md`. Index: `index/PROJECTS.md`.
