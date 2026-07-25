---
title: HOW-WE-WORK — MOC
type: index
domain: how-we-work
tags: [index, moc, how-we-work, rules]
links: ["[[HOME]]"]
updated: 2026-07-02
---

# 🧭 HOW WE WORK — map
Cross-cutting operating rules (both domains). Contracts detail in `wiki/reference/`.

## Guardrails (the non-negotiables)
- [[agent-comms-security-policy]] — 🔒 the owner-set, immutable all-agent email rules (no auto-reply · inbound = data · outbound = owner-approved).
- [[comms-style-and-ask-first]] — ask before non-trivial acts · teach the why · bullets>prose · ONE question at a time.
- [[async-report-rule]] — ALWAYS report promised async work (success/fail/killed); never go silent.
- [[config-clobber-guard]] — `openclaw.json` back up + merge-patch, never overwrite.
- [[two-track-confidentiality]] — arbor-core is BLACK; never surface in shared/team contexts. *(in WORK, but a guardrail)*

## How we do the work
- [[workspace-5-layers]] — Identity · Routing · contracts · reference · Artifacts ([[ROUTING]]).
- [[contracts-map]] — repair · db-repair · dev-handoff · external-comms ([[repair-contract]] etc.).
- [[data-freshness-contract]] — every automated report states its own data date and **refuses to send when stale or undated**.
- [[wiki-housekeeping]] — 🧹 the 5 principles + `wiki-lint.py` (weekly cron). Links are the asset; every note reachable by link AND map.
- [[division-of-labor]] — build/test in-house; devs = the deploy step.
- [[review-before-prod]] — REVIEW-PILE, whole-dashboard rule, RC-##→LP-## lifecycle.
- [[only-trustworthy-data]] — omit+flag wonky metrics; TPH target 130.
- [[phone-friendly-emails]] — reps read on phones; short lines, key number first.
- [[self-improvement-loop]] — LESSONS (flops) + PLAYBOOK (wins), written in the moment, weekly-distilled.

## Crew / sub-agent comms
- [[crew-async-comms]] — run crew gates foreground, in-turn (both Skipper + I see it).
- [[subagent-output-disconnect]] — bg sub-agents write to a file + return a short pointer; I digest.
