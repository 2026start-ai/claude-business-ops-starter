#!/bin/bash
# Session-start hook: keep working tree current with origin.
#
# - Runs git pull --ff-only at the start of every Claude Code session.
# - --ff-only: never auto-merges; preserves local/uncommitted work if
#   the branch can't fast-forward (you'll see a heads-up in context).
# - Hook-level `timeout: 15` in settings.json handles slow/offline
#   networks (Claude Code kills the hook; session continues).
# - Output is piped back to Claude via SessionStart additionalContext
#   so the model sees what changed (or didn't) coming into the session.
#
# Triggered from .claude/settings.json SessionStart hook.

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
RESULT=$(git -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=5 pull --ff-only 2>&1)
PULL_EXIT=$?

if [ $PULL_EXIT -ne 0 ]; then
  RESULT="git pull skipped (offline, non-FF, or branch has no upstream): $RESULT"
fi

# Trim to first 8 lines — keeps the SessionStart context snippet tight.
TRIMMED=$(printf '%s' "$RESULT" | head -8)

jq -n --arg c "Session-start git pull on $BRANCH: $TRIMMED" \
  '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
