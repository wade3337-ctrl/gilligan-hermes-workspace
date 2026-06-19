# Contract: DATABASE repair (proc / data / schema)
**Why separate:** play DB reverts on the nightly prod→play refresh, so DB fixes must be deployed to prod by devs to stick.

## Steps
1. **Build + TEST on PLAY first** to prove it's right (play reverts nightly — fine for testing). Use `gsql.sh`.
2. **Back up prod-appropriately** (NOT Jasonsrepairs — that's play-only): `SELECT * INTO dbo.zBak_<thing>_<date>` for affected rows, and/or script out the current proc definition to a file. Let IT use their own restore process.
3. **Hand devs exact, scoped steps** — name every object (`dbo.<Proc>`), which server/env it lives on and deploys TO, and the exact action/params (run this proc with these params / regenerate these IDs). No "the files we changed."
4. **Devs deploy to PROD.**
5. **Verify on prod** against a stated acceptance check (e.g., "Long Beach 26/27 now ~$97K, not $0").
