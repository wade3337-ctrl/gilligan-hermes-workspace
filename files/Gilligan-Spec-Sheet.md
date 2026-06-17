# 🏝️ Gilligan — Spec Sheet

*AI assistant for Jason Wade (the Skipper), COO of Great Scott Tree Care. Last updated: June 10, 2026.*

---

## Identity
| | |
|---|---|
| **Name** | Gilligan |
| **Role** | Personal AI assistant / automation engine for Great Scott Tree Care + Arbor AI |
| **Interface** | Discord (direct + voice-ready), email reports |
| **Platform** | OpenClaw **2026.6.1** (build 2e08f0f) |

## Brains (AI models)
| Model | ID | Use |
|---|---|---|
| **Anthropic Claude Opus 4.8** | `claude-opus-4-8` | **Primary** — me. Reasoning, writing, code, analysis. |
| **OpenAI Codex** | (ChatGPT/Codex OAuth) | Server-side SQL + file tasks on TrimIT (backup-first, read-only). |
| **Ollama llama3.2:3b** | local, 2.0 GB | Lightweight local model; backs web search. Runs on the host. |

## Host Hardware
| Component | Spec |
|---|---|
| **Machine** | `jdog1` (laptop-class server) |
| **OS** | Ubuntu **26.04 LTS** (Resolute) · kernel 7.0.0-22 · x86-64 |
| **CPU** | Intel Core **i7-7700HQ** @ 2.8 GHz — 8 logical cores |
| **RAM** | **14 GB** |
| **Storage** | **914 GB** SSD (848 GB free, ~4% used) |
| **GPU** | NVIDIA **GeForce GTX 1050 Ti Mobile** (4 GB VRAM) + Intel HD 630 iGPU *(NVIDIA driver not currently loaded)* |
| **Uptime** | continuous (multi-day) |

## Runtimes & Tooling
- **Node.js 24.16.0** / npm 11.13 — primary scripting path
- **Python 3.14.4** — *no package manager (no pip/uv), no passwordless sudo* → can't self-install system/Python packages
- File reading: PDF (`pdf-parse`), Excel (`xlsx`), docx/pptx (raw XML), csv/md/txt/html
- Email: Gmail SMTP via `nodemailer` (sender `gilligan.gsts@gmail.com`)
- Web: authenticated HTTP fetch + web search *(no headless browser — no Chromium for Ubuntu 26.04)*

## What Gilligan Can Do
- **Automated reporting** — daily COO email (TPH, overtime, revenue pace, contract burn-down); per-salesperson + manager job emails
- **TrimIT (ERP) access** — dedicated **read-only** account, authenticated HTML/JSON pulls; never mutates data
- **Research & analysis** — web research, document parsing, data verification, business intel
- **Scheduling** — cron jobs, reminders, recurring tasks
- **Memory** — persistent across sessions via local memory files (continuity between chats)

## Guardrails
- **Read-only by default** on TrimIT; all DB/code changes go through backup-first Codex prompts the Skipper runs — Gilligan drafts, never executes directly
- **Backup-first** on config & data; never clobber files
- **Private bot** — only the Skipper can talk to it
- **Asks before external actions** (emails, posts, anything leaving the machine)
- **No independent goals** — operates only on the Skipper's requests

## Known Limits
- No headless browser (reads pages via HTTP fetch, can't click through JS apps)
- 4 GB VRAM + no NVIDIA driver loaded → can't run large local models today
- Python package installs require the Skipper (no self-install)
- Hands-free realtime voice needs an OpenAI platform API key (not yet configured)

---
*Prepared by Gilligan 🏝️ · Great Scott Tree Care / Arbor AI*
