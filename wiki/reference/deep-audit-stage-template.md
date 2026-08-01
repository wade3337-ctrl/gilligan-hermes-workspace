---
title: Deep Audit — stage-note template
type: reference
domain: work
tags: [trimit, audit, template, workflow]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]"]
links: ["[[trimit-deep-audit]]"]
updated: 2026-08-01
---

# Deep Audit — stage-note template

Copy this for each workflow stage → `wiki/projects/trimit-audit-NN-<stage>.md`. Every figure comes from a
command run THIS session (name it). Flag cleanup candidates; don't drop anything until rehearsed + approved.

```markdown
---
title: TRIM IT Audit NN — <Stage Name>
type: project
domain: work
track: 1
status: <in-progress | done>
tags: [trimit, audit, <stage>]
applies: ["[[repair-contract]]", "[[db-repair-contract]]", "[[only-trustworthy-data]]"]
links: ["[[trimit-deep-audit]]"]
updated: YYYY-MM-DD
---

# TRIM IT Audit NN — <Stage Name>

## 1. Entry points (code)
- `.cfm` page(s): <path(s)>  (pulled from play webroot: <where>)
- proc(s) / query(ies): <names>
- who uses it / when in the workflow: <>

## 2. Data model (verified live)
- Reads: <tables.columns>
- Writes: <tables.columns> + FKs
- Views / procs involved: <>
- (query used to verify: `<cmd>`)

## 3. Used vs. dead
- Exercised: <>
- Orphaned / legacy / never-called: <>  (evidence: <cmd/grep>)

## 4. Works vs. broken
- Defects / dead paths / integrity gaps: <>
- Severity + blast radius: <>

## 5. Cleanup candidates (FLAG only — do not drop yet)
- Stale rows / dupes / dead columns/tables: <count + query>
- Reversible plan: `_graveyard` quarantine → soak → drop, rehearsed on frozen copy
- Risk / dependencies: <>

## 6. Knowledge delta
- Already knew (link): <[[notes]] / trimit-knowledge paths>
- NEW this pass: <>
```
