# CREW-ACCESS.md — my on-demand crew + Codex heavy lifting (Hermes pilot)

> Kept in `_pilot-own/` because that folder is PROTECTED from the 10-min workspace mirror
> (`rsync --delete` from OpenClaw-Gilligan). Loose files in the workspace root get wiped; this survives.

I run on **gpt-5.6-sol** (my main brain, via Hermes). Anthropic-as-brain was abandoned. But I have the
**same crew Gilligan-on-OpenClaw has** — single-shot cross-model helpers I can spin up mid-task for a second
opinion, a blind cross-lab check, or parallel work. Plain Python scripts (stdlib only), prompt on **stdin**.

**Location:** `/opt/data/arbor-core/crew/`  ·  **Keys:** `/opt/data/.secrets/*.json` (already wired in).

## Spin up a crew member
```sh
echo "your prompt / paste evidence inline" | python3 /opt/data/arbor-core/crew/<member>-ask.py
```

| Member | Command | What it is | Notes |
|---|---|---|---|
| **Fable 5** | `fable-ask.py` | `claude-fable-5` (Anthropic API, own key) | thinking always on; no temperature |
| **Gemini** | `gemini-ask.py` | Google Gemini 3.1-pro | free-tier TESTING key — not for prod |
| **GLM** | `glm-ask.py` | Zhipu GLM-5.2 (z.ai) | cheap; `glm-worker.py` for file edits |
| **Kimi** | `kimi-ask.py` | Moonshot Kimi K3 | ~7× slower — background long calls |
| **gpt-5.6-sol** | (native) | my own brain — more via Hermes **sub-agents** | agentic; no script |
| **Codex (heavy lifting)** | `codex-worker.sh <repo> "task"` — or `--new <name> "task"` to build from scratch | full agentic Codex that writes/refactors AND runs/tests code | ISOLATED sibling container — see below |

## Codex heavy lifting — isolated sibling worker
For real code work (write / refactor / fix / review a repo):
```sh
bash /opt/data/arbor-core/crew/codex-worker.sh <repo> "task text"
# repo = basename (arbor-stack, workspace) or full path; must be host-allowlisted
echo "task..." | bash /opt/data/arbor-core/crew/codex-worker.sh <repo>

# GREENFIELD — build something NEW from a prompt, no existing repo needed:
bash /opt/data/arbor-core/crew/codex-worker.sh --new <name> "build task text"
#   -> Codex builds in a fresh isolated scratch repo; output lands in
#      /opt/data/codex-jobs/builds/<id>-<name>/  (path is echoed as 'build output dir: ...')
```
- **How it works:** I write a job into `/opt/data/codex-jobs/inbox/`; a HOST watcher runs Codex in a
  **throwaway container that mounts ONLY the target repo + Codex auth** — no `.secrets`, no `.ssh`, no memory,
  no other repos. Codex runs full-access but is externally sandboxed by that minimal container, so it
  physically cannot reach anything sensitive. Results land in `/opt/data/codex-jobs/outbox/` and stream back.
- **Why not run Codex in my own container:** its kernel sandbox can't run here (userns mount-lock), and
  running it here full-access would expose all of `/opt/data`. The sibling worker is the safe path.
- **Allowed repos** enforced host-side (`~/codex-worker/allowlist.txt`) — ask the Skipper to add one if needed.
  (Greenfield/`--new` needs NO allowlist entry — it builds in a throwaway scratch repo.)
- **Model is LOCKED to gpt-5.6-sol + HIGH reasoning** for every job (Skipper: no weaker model does coding
  work) — enforced host-side, can't be overridden per-job.
- **The worker can EXECUTE code** (python3 + node/npm in the image), so Codex can run/test what it writes —
  ask it to verify its own output, not just author it.

## Rules of use
- **Feed evidence inline** — single-shot helpers don't browse or hold context.
- Run crew gates **foreground / in-turn** so the Skipper and I both see the result.
- Different lab = different blind spots — that's the point.
- Crew wired + live-tested 2026-08-01; Codex sibling worker built + tested (read + write) 2026-08-01.

_Full build detail → wiki `gilligan-hermes-migration` note._
