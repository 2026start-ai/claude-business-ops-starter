#!/bin/bash
# SessionStart hook: surface files dropped into the _inbox/ drop folder.
#
# The point is that "I dropped the screenshot in _inbox" should Just
# Work — Claude sees the file at session start without the user having
# to paste a path, and without Claude having to go hunting through
# Desktop/Downloads/temp dirs.
#
# Contents are gitignored (transient hand-off, not source). Once a
# dropped file has been used, move it to its permanent home or delete
# it — a stale _inbox nags every session, same as the human-loop queue.
#
# Registered in .claude/settings.json → SessionStart.

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
[ -d "_inbox" ] || exit 0

files=$(find "_inbox" -maxdepth 1 -type f \
  ! -name '.gitkeep' ! -name 'README.md' ! -name '.DS_Store' ! -name '.gitignore' 2>/dev/null | sort)
[ -z "$files" ] && exit 0

echo "📥 Files waiting in _inbox/ — the user dropped these for you:"
while IFS= read -r f; do
  [ -n "$f" ] || continue
  printf '  • %s  (%s, dropped %s)\n' \
    "$(basename "$f")" \
    "$(du -h "$f" 2>/dev/null | cut -f1 | tr -d ' \t')" \
    "$(date -r "$f" '+%b %-d %-I:%M%p' 2>/dev/null)"
  printf '      %s\n' "$PWD/$f"
done <<< "$files"
echo ""
exit 0
