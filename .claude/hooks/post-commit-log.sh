#!/bin/bash
# Post-Bash hook: append new commits to today's session log.
#
# Fires after every Bash call. If git HEAD has a commit not yet
# recorded in today's session file, appends it. Idempotent —
# no-op if the latest hash is already in the file.
#
# Worktree-aware: resolves the repo root of the tree the session is
# actually running in via $CLAUDE_PROJECT_DIR. Sessions in a linked
# worktree write docs/sessions/<today>_<branch>.md (in that worktree)
# so parallel sessions never entangle in one file; the main tree keeps
# the plain <today>.md name.
#
# Triggered from .claude/settings.json PostToolUse → matcher: Bash.

set -e

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -z "$ROOT" ] && exit 0
cd "$ROOT" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Linked worktree? (git-dir diverges from git-common-dir there.)
SUFFIX=""
BRANCH=""
if [ "$(git rev-parse --git-dir)" != "$(git rev-parse --git-common-dir)" ]; then
  BRANCH=$(git branch --show-current 2>/dev/null | tr '/' '-')
  [ -z "$BRANCH" ] && BRANCH=$(basename "$ROOT")
  SUFFIX="_$BRANCH"
fi

TODAY=$(date +%Y-%m-%d)
SESSION_FILE="docs/sessions/$TODAY$SUFFIX.md"

LAST_HASH=$(git log -1 --format='%H' 2>/dev/null || echo "")
[ -z "$LAST_HASH" ] && exit 0
SHORT_HASH=${LAST_HASH:0:7}

# Self-reference guard: a commit that touches ONLY session logs is
# bookkeeping about this file, not work worth reporting. Logging it
# appends an entry -> that entry gets committed -> the hook logs THAT
# commit -> forever. A commit mixing session logs with real changes
# still logs normally; merge commits (diff-tree prints nothing) are
# unaffected.
#
# Deliberately grep-free: `grep -qv` disagrees across implementations,
# and a wrong answer here fails SILENTLY by never logging real work.
# `case` is shell-builtin and cannot drift.
CHANGED=$(git diff-tree --no-commit-id --name-only -r "$LAST_HASH" 2>/dev/null || true)
if [ -n "$CHANGED" ]; then
  ONLY_SESSION_LOGS=1
  while IFS= read -r changed_file; do
    [ -z "$changed_file" ] && continue
    case "$changed_file" in
      docs/sessions/*) ;;
      *) ONLY_SESSION_LOGS=0; break ;;
    esac
  done <<EOF
$CHANGED
EOF
  [ "$ONLY_SESSION_LOGS" -eq 1 ] && exit 0
fi

# Already logged? Bail quickly.
if [ -f "$SESSION_FILE" ] && grep -qF "$SHORT_HASH" "$SESSION_FILE"; then
  exit 0
fi

mkdir -p docs/sessions

# Seed the file with a header on first write of the day.
if [ ! -f "$SESSION_FILE" ]; then
  cat > "$SESSION_FILE" <<'HEADER'
# Session log — DATE_PLACEHOLDER

Append-only daily log. Commits stream in automatically via the
post-Bash hook in `.claude/hooks/post-commit-log.sh`. Inline notes
("decided / tried / abandoned") written by Claude as work happens.

---

HEADER
  # Replace the date placeholder in-place (avoids heredoc-substitution
  # weirdness with sed on macOS).
  if [ -n "$SUFFIX" ]; then
    sed -i '' "s/DATE_PLACEHOLDER/$TODAY ($BRANCH worktree)/" "$SESSION_FILE"
  else
    sed -i '' "s/DATE_PLACEHOLDER/$TODAY/" "$SESSION_FILE"
  fi
fi

# Format the commit. Subject + first 20 lines of body, indented.
SUBJECT=$(git log -1 --format='%s')
BODY=$(git log -1 --format='%b' | head -20)

{
  echo
  echo "### \`$SHORT_HASH\` $SUBJECT"
  echo
  if [ -n "$BODY" ]; then
    echo "$BODY" | sed 's/^/  /'
  fi
} >> "$SESSION_FILE"

exit 0
