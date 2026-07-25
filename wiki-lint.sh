#!/usr/bin/env bash
# wiki-lint.sh — health check for the atomic wiki. READ-ONLY: reports, never edits.
# Usage:  bash wiki-lint.sh          # human report
#         bash wiki-lint.sh --quiet  # print only if problems (for cron)
# Exit 0 = clean, 1 = problems found.
exec /usr/bin/python3 "$(dirname "$0")/wiki-lint.py" "$@"
