# Crew Review — Steve dashboard prod package (2026-07-21)

**Round 1 verdict: DO-NOT-SHIP** (all 3 labs — Kimi K3, Gemini 3.1 Pro, gpt-5.6-sol). Full outputs: crew-review-*.txt.

## Blockers they caught → how each was resolved
1. **Non-atomic reseed** (partial seed = silently wrong CFO numbers) → wrapped in `SET XACT_ABORT ON` + single transaction.
2. **RAISERROR didn't halt the batch** → replaced with `THROW` (precondition + count assert) = fail-closed.
3. **No unique key on ProposalID** (double-count risk via LEFT JOIN) → verified 0 dups, added `UNIQUE` index.
4. **No hard count assert** → `THROW` if row count != 563 → rolls back.
5. **`UNDEFINED` override excluded proposal 396441** (sol caught) → dropped that bad row from the seed (564→563).
6. **Missing GRANT for the CF datasource login** → added STEP 4 (explicit GRANT template + note; Jordan supplies prod login).
7. **Rollback order / backup** → script backs up any pre-existing table; instructions fix rollback order (files first, then DB).
8. **Play==prod ID assumption** → play is a ~24h replica of prod (shared identity); documented, snapshot dated.
9. **Env-literals / Export write-path** (Kimi) → checked: cflocations are relative self-redirects; Export streams via `cfcontent` (no disk write). Clean.

## Re-validation
Hardened SQL dry-run against a throwaway `Workbench.dbo.POR_deploytest` table on play: executed clean, count assert
passed, landed 563 rows, dropped the test tables. Files byte-identical to play-live (drift check passed).

## Still Jordan's to confirm on prod (can't verify from here — read-only prod)
- GRANT the prod GSTS CF datasource login SELECT on the new table (STEP 4).
- Deploy to all served webroot(s) if prod is multi-root/multi-node.
