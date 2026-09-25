#!/bin/bash
# SessionStart hook: surface open "🔧 Your Move" (human-loop) items so
# actions only the user can do don't get lost between sessions, and open
# "🔨 fix-it" items (defects noticed in travels) so they get knocked out
# when a session brushes against them. Reads docs/human-loop.md +
# docs/fix-it.md and prints unchecked items as session-start context.
#
# Registered in .claude/settings.json → SessionStart.
# Protocols: CLAUDE.md → "🔧 Your Move — human-loop actions" + "🔨 Fix-it".

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0

surface() {
  local file="$1" header="$2"
  [ -f "$file" ] || return 0
  local open
  open=$(grep -E '^- \[ \] ' "$file" 2>/dev/null)
  [ -z "$open" ] && return 0
  echo "$header"
  echo "$open" | sed -E 's/^- \[ \] /  • /'
  echo ""
}

surface "docs/human-loop.md" "🔧 Open human-loop (Your Move) items in docs/human-loop.md — remind the user if a trigger is due:"
surface "docs/fix-it.md" "🔨 Open fix-it items in docs/fix-it.md (defects noticed in travels — knock out any that fit the session):"
exit 0
