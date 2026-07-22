#!/usr/bin/env bash
# Warm Arbor Helper's count-once coverage cache (ColdFusion application scope on play).
# The accrual UDF (GetPeriodAccrual) takes ~90s; caching it in-app means humans get <1s answers.
# This cron keeps both caches (accrual 4h, coverage 30min) primed so a real user never eats the cold cost.
# Track-1 figures only (no deal framing). Added 2026-07-22 with the answerCoverage() build.
LOG=/home/wade3337/.openclaw/workspace/landing-assistant/warm-coverage.log
URL="https://play.greatscotttreeservice.com/GSTS/AI-Chat.cfm?msg=path%20to%20goal%20coverage%20warm"
T=$(curl -s -k --max-time 120 -w '%{time_total}s|%{http_code}' -H 'Cookie: ZUserID=376' "$URL" -o /dev/null 2>/dev/null)
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) warm $T" >> "$LOG"
# keep the log from growing forever
tail -200 "$LOG" > "$LOG.tmp" 2>/dev/null && mv "$LOG.tmp" "$LOG"
