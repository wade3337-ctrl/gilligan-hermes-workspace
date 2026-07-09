# Gilligan -> Boss Hermes direct line — STAGED (apply when Hermes is free)

**Goal:** let Gilligan send Hermes messages directly (to run tests / relay), without copy-paste.

## Findings (2026-07-07 PT)
- Port **18789 is Gilligan's OWN gateway** (node openclaw), NOT Hermes. Do not configure the line there.
- Other local ports (8791/8099/8077) = arbor-core services (importer, static), not Hermes.
- **Hermes = separate Python agent** in docker (`hermes`, `hermes-dashboard`), config `/home/wade3337/.hermes/config.yaml`.
  Reaches the user via **chat channels (Discord/Telegram)**; has a `gateway.api_server` block but no HTTP hook port currently exposed.

## Token (ready)
- Generated + stored: `~/.secrets/hermes-hook-token.env` (chmod 600, `HERMES_HOOK_TOKEN=…`).

## Go-live steps (need ~10s Hermes restart — do when he's NOT mid-conversation)
1. Back up Hermes config: `cp ~/.hermes/config.yaml ~/.hermes/config.yaml.bak-<ts>`.
2. Enable a loopback hook endpoint on Hermes' gateway with `hooks.enabled=true`, `hooks.token=$HERMES_HOOK_TOKEN`,
   `hooks.path=/hooks`, bound to loopback/tailnet only, `hooks.allowedAgentIds` scoped to Hermes.
   (Confirm exact key paths against Hermes' gateway build first — its config is OpenClaw-flavored but the image is
   `hermes-agent`/Nous; verify the hook schema before editing.)
3. Merge-patch only (no clobber). Restart Hermes gateway. Verify: `curl -H "Authorization: Bearer $HERMES_HOOK_TOKEN"
   -d '{"message":"ping"}' http://127.0.0.1:<hermes-port>/hooks/agent` returns a real Hermes turn.
4. Then Gilligan can run test batteries against Hermes directly.

## Status: TOKEN READY, config change + restart DEFERRED (don't disrupt live Hermes).
