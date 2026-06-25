# Contract: TRIM IT repair / modification
**When:** any fix or change to a GSTS/TRIM IT page, query, proc, or data.

## UI vs DB (decide first)
- **UI** = the page's query/logic is wrong, data is fine → **we fix it ourselves** (`.cfm/.css/.js`); persists on play.
- **DB** = the rows/proc/schema themselves are wrong (revert on nightly refresh) → build+test on play, then **devs deploy to prod** (see db-repair-contract).

## Steps (every repair)
1. **Root-cause, not bandaid** — trace symptom → originating data/logic/schema. Ask "is this the cause, or another layer on a workaround?" Fix the cause.
2. **Map the blast radius** — triggers on the table (`sys.triggers`), procs/views that call it (`sys.sql_modules`), other pages/queries reading the same data. Verify assumptions, don't assert them.
   - **🔁 PROPAGATE THE FIX (Skipper, Jun 25 2026 — a base rule):** whenever you fix a bug, **check every page that links to / is linked from / shares the same query or pattern as the one you fixed, and repair the same fault there too — in the same session.** A fix isn't done until its siblings are clean. Find them: grep the web root for the same table/proc/query/function, and walk the in/out links (a page that opens another, a child drill, a shared include). *Origin: the `GoalSettings` crash guard went into `ZTest-SiteMap.cfm` (#78) but not its child `ZTest-Drill.cfm`, which still had the identical unguarded query — same latent crash, one click deeper.*
3. **Backup-first → `\GSTS\Jasonsrepairs\` on PLAY** (timestamped `.bak` of every `.cfm`/proc/rows touched). Never overwrite/delete originals. *(Jasonsrepairs is PLAY-ONLY — never tell devs to use it on prod.)*
4. **Build + verify on play** — render-verify the *served* output (not just the file on disk). Check the **dual-webroot shadow copy** (`C:\ColdFusion2023\…` can override `D:\…`).
5. **Log it** — add a row to `gsts-ship-log.md` + a `ship-log/YYYY-MM-DD-slug.md` detail file (**with the actual code mods**), AND update the `repairRows` array on `Reference-RepairsAndScheme.cfm` + redeploy it. **If a NEW page was built (not just repaired), ALSO add it to the `buildRows` (Pages Built) array** on the same reference page so the on-play index of built pages stays current. *(Skipper, Jun 24 2026: keep Pages Built in sync as you create new pages — he caught the Arborist Workbench missing.)*

## Acceptance
Renders clean (0 CF errors) · reconciled to source-of-truth · blast-radius checked · **same fault repaired in every linked/sibling page** · backed up · logged + live Reference page current.
