---
title: OpenClaw — the plugin install TRUST GATE (why plugins die after a core update)
type: reference
domain: environment
updated: 2026-07-30
tags: [openclaw, plugins, codex, discord, gateway, troubleshooting, sqlite, trust]
links: ["[[env-host-and-tooling]]", "[[gilligan-session-settings]]", "[[config-clobber-guard]]"]
---

# OpenClaw — the plugin install TRUST GATE

**Diagnosed and fixed 2026-07-30 02:42 UTC**, after the Skipper updated OpenClaw and had to restart several times. This note exists so I never re-run the two hours of diagnosis.

## 🩺 The symptom cluster (all ONE bug)
After the update to core `2026.7.1-2`, the gateway logged on **every boot**:

```
[plugins] codex failed during register from .../@openclaw/codex/dist/index.js:
TypeError: Cannot read properties of undefined (reading 'openSyncKeyedStore')
```

Downstream, this is what the Skipper actually experienced:
- `Error: codex app-server client closed before turn completed` — killed a 230-second turn
- `EPIPE` on `turn/interrupt` (writing to a dead app-server)
- `marked interrupted main session failed ... (transcript tail is not resumable)` → the user-facing
  **"I was interrupted by a gateway restart and couldn't safely resume"** message
- `Session "..." changed while starting work. Retry.` storms on the Discord lane

## ❌ The wrong theory (cost the most time)
Plugin was `2026.7.1-1`, core was `2026.7.1-2` → "obvious" version skew.
**It was not.** `npm view @openclaw/codex version` → **`2026.7.1-1` IS latest**; there is no `-2`
plugin build. `openclaw plugins update codex` correctly answered *"codex is up to date."*
> **Verify the version story before acting on it, or you'll "fix" a mismatch that doesn't exist.**

## ✅ The real chain (read bottom-up from the throw)
1. Core `-2` wraps `runtime.state` in a Proxy and gates `openKeyedStore` / `openSyncKeyedStore`
   behind `assertPluginStateAllowed()` → in `dist/registry-*.js`:
   `if (record?.origin !== "bundled" && record?.trustedOfficialInstall !== true) throw`
2. `trustedOfficialInstall` is computed by **`isTrustedOfficialPluginInstall()`** →
   **`matchesInstalledPluginRecord()`** in `dist/manifest-registry-*.js`, which requires an
   **install record whose `installPath` equals / contains / is contained by the path the plugin
   actually loaded from** (realpath-resolved).
3. **Codex had no install record at all** → not trusted → `state` API undefined → register throws.
4. The record was missing because `~/.openclaw/plugins/installs.json` **could not regenerate**: it
   held a **stale `discord` entry — v2026.5.27 at `~/.openclaw/npm/node_modules/@openclaw/discord`,
   a path that no longer exists.**

## 🚨 The tell I ignored for an hour
Every single command printed:

```
Left plugin install index in place because shared SQLite state has
conflicting plugin install metadata for: discord
```

I read it as cosmetic noise. **That notice WAS the bug** — it named the exact blocking plugin and
said in plain words that it was refusing to rewrite the index.
> **Read the doctor notice as a finding, not decoration.**

## 🔧 The fix (repeatable)
```bash
cp -a ~/.openclaw/plugins/installs.json ~/.openclaw/plugins/installs.json.bak-$(date +%Y%m%d-%H%M%S)
mv ~/.openclaw/plugins/installs.json ~/.openclaw/plugins/installs.json.stale-$(date +%Y%m%d-%H%M%S)
openclaw plugins registry --refresh
openclaw gateway restart
```
`installs.json` **correctly does not come back** — it is a *legacy* file. The authoritative store is
the **`installed_plugin_index` table in `~/.openclaw/state/openclaw.sqlite`** (single row, key
`installed-plugin-index`, records in `install_records_json`).

## 🔍 Inspect the real records (no sqlite3 binary on this box — use node)
```bash
node -e '
const {DatabaseSync}=require("node:sqlite");
const db=new DatabaseSync(process.env.HOME+"/.openclaw/state/openclaw.sqlite",{readOnly:true});
const r=db.prepare("select * from installed_plugin_index").get();
const recs=JSON.parse(r.install_records_json), fs=require("fs");
console.log("host_contract:",r.host_contract_version);
for(const [k,v] of Object.entries(recs))
  console.log(k,"| v"+v.version,"| pathExists:",fs.existsSync(v.installPath),"\n   ",v.installPath);
'
```
**`pathExists: false` on any row = the bug.** That single check would have found this in 2 minutes.

## 🧭 Debug recipe for "plugin API is undefined"
1. `grep -rl "<symbol>" ~/.npm-global/lib/node_modules/openclaw/dist/` — find where core defines it.
2. Print the ~2KB **around** it — the permission guard sits right there and names its own condition.
3. Then check whether *this install* satisfies that condition. Beats any amount of reinstalling.

## ✅ Verified after the fix (this session, not from notes)
- Codex register failures since 02:42Z: **0** (was throwing every boot)
- **All** ERROR-level log lines since 02:42Z: **none**
- `openclaw plugins doctor` → *"No plugin issues detected"* (discord notice gone too)
- `openclaw plugins inspect codex` → **Status: loaded**
- Both SQLite records now resolve to **paths that exist**
- Gateway running, connectivity probe ok; `openclaw config validate` → valid

## ⚠️ Related gotchas
- **Two codex project dirs are normal**: `openclaw-codex-<hash>` and
  `openclaw-codex-<hash>__openclaw-generation__g-<id>`. The loader recreates the generation dir
  seconds after an install — do **not** "clean up" the sibling; the trust check does path
  *containment*, not equality.
- **`openclaw plugins doctor` can say "no issues" while the gateway crashes on load** — doctor runs
  in CLI context, the trust gate only bites in gateway runtime. Trust the **log**, not doctor, when
  diagnosing a register failure.
- Never hand-edit `installs.json` (it self-declares *DO NOT EDIT*); move it aside and let the
  refresh rebuild from manifests.
