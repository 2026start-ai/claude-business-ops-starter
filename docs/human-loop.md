# 🔧 Your Move — human-loop queue

Actions only a human can do. Claude appends items as they surface; check
them off when done. The session-start hook resurfaces open items every
session so nothing gets lost.

<!-- Format (real items start at column 0; this example is indented so
     the session-start hook doesn't surface it):
  - [ ] <action> — <why> — <when> — added <YYYY-MM-DD>
-->
