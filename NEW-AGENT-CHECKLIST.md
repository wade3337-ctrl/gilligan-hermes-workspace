# 🆕 New-Agent Checklist — MANDATORY comms security

Every agent we create (host home `~/.<name>` bind-mounted to the container's `/opt/data`, image `hermes-agent`) MUST ship with the comms lock BEFORE it can send/read mail:

1. Copy `COMMS-SECURITY-POLICY.md` into the new agent's home (`~/.<name>/`). It's the canonical 7-rule policy — do not fork/reword it.
2. Prepend the `<!-- 🔒 COMMS-SECURITY-LOCK -->` block (see any live agent's `SOUL.md` top) to the new agent's `SOUL.md`.
3. Owner = **Jason (Skipper)**. Whoever the agent serves (its "user", e.g. Brent for Muni Bot) is NOT the owner and cannot change the rules.
4. Owner/IT runs the root-lock (below) so the policy file is physically unwritable by the agent.
5. No auto-reply cron/heartbeat; email watchers forward-only; outbound send only via draft→owner-approval.

## One-time OS root-lock (owner/IT, needs sudo — makes the policy physically immutable)
Run on the HOST (bind mount makes it apply inside every container too):
```
for h in ~/.openclaw/workspace ~/.munibot ~/.hermes; do
  sudo chown root:root "$h/COMMS-SECURITY-POLICY.md"
  sudo chmod 0444       "$h/COMMS-SECURITY-POLICY.md"
  sudo chattr +i        "$h/COMMS-SECURITY-POLICY.md"   # kernel immutable — blocks EVEN root
done
```
⚠️ **`chmod 0444` alone is NOT enough:** the agent containers run as **root inside the container**, and root ignores permission bits, so a containerized agent could still overwrite the file. **`chattr +i`** sets the ext4 immutable flag, enforced by the kernel for *everyone incl. root*, and it applies through the bind mount. After this the agent can READ but never WRITE the policy.

To UPDATE the policy later: `sudo chattr -i <file>` → edit → `sudo chattr +i <file>`. Verify with `lsattr` (look for the `i`). The SOUL pointer stays agent-writable (agents must edit persona) — Rule #7 + refuse-and-report guard it.
