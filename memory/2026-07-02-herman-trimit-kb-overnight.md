# 2026-07-02 (overnight) — Boss Herman TRIM IT brain: DB access + knowledge vaults

Skipper's autonomous overnight mandate: build Herman a TRIM IT knowledge base + give Herman read-only DB access, crew-verify in a loop until right, email a report to wade3337@gmail.com. **DONE + emailed.**

## Herman read-only DB access (approved "A" = his own)
- **HermanRO** SQL login (db_datareader on play GSTS) — verified reads work, writes DENIED. Password in `~/.secrets-herman/hermanro.txt`.
- **Read-only query gateway on gilligan** (`~/herman-gateway/trimit-ro-query.sh`) — forced-command SSH key so Herman's key can ONLY run read queries as HermanRO (tested: arbitrary commands rejected). Chose gilligan (recoverable) over the DB server for the forced-command, to avoid spreading admin keys / risking my own DB access.
- **Persistence:** hourly `schtasks HermanRO-ReGrant` on the DB box re-applies the GSTS user+role (survives nightly refresh).
- **Last mile (NOT done — can't SSH into Herman, his sync is push-only):** key + helper + installer staged at `~/herman-gateway/` and `~/herman-store/gilligan-outbox/`; `HERMAN-SETUP.md` tells Herman to self-install (~30s).

## Two knowledge vaults (git repos under wade3337-ctrl)
- **trimit-knowledge** (78 notes, shareable) — live-pulled schema (923-table index, 16 core-table columns, 1096 FKs, 403 status codes, muni=11, 516 service types) + query playbook (vetted SQL, executed against live DB) + per-table/page/concept/data-flow/SOP + Herman operating model (map vs. live-lookup). Repo `wade3337-ctrl/trimit-knowledge`, local `~/trimit-knowledge/`.
- **arbor-knowledge** (16 notes, BLACK/confidential) — arbor-core strategy/foundation/one-stop-UI/pricing/RFP/schema v1.7. Repo `wade3337-ctrl/arbor-knowledge`, local `~/arbor-knowledge/`.

## Crew verification loop
- **2 rounds.** Round 1 (GLM + Gemini): ~10 concrete issues (concept↔SQL contradictions, aging buckets, city-budget gaps, stale benchmarks). Kimi's helper SIGKILLed both attempts (known). Fix pass = 13 files. **My live-DB execution of every recipe caught a fix-introduced reserved-word bug (`AS Current`) the review missed** → fixed. Round 2 (GLM + Gemini): CLEAN, "ready for deployment."
- Verified benchmarks: Scott 74.8% close, 2025 treatment $433,361/89 exact, 2026 revenue $10.69M YTD.

## Deliverables
- Both repos pushed to GitHub (created via API — no `gh`). Email report sent (port 465). Cowork prompt for the Skipper's Obsidian access is in the email. Herman self-setup staged.
- Reusable techniques → `PLAYBOOK.md`; the `&`-jobs-die / execute-don't-just-review / kimi-timeout gotchas → `LESSONS.md`.
