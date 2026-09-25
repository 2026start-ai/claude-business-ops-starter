---
name: close-out
description: Run the session close-out gate. Use when the user says "wrap up", "wrap the session", "end clean", "close out", "safe to close?", or similar end-of-session phrasing. Verifies the session log, durable memory, and Your Move queue, runs the release-blocking clean-tree/pushed check, then emits the explicit "safe to close" confirmation.
---

# Session close-out

The standing end-of-session gate. Run every step in order and report the
result of each. Step 4 (clean tree + everything pushed) is
**release-blocking** — never declare safe to close until it passes on
verified output. End with the explicit confirmation.

## Steps

1. **`## Next move` pointer.** If a task ended mid-flight, or there's a
   clear next step that isn't already a backlog item, append a short
   `## Next move` section to the bottom of today's
   `docs/sessions/<YYYY-MM-DD>.md` (one or two sentences). If
   everything's clean-ended, say so and skip.

2. **Memory.** If anything from the session belongs in durable memory (a
   new user preference, a feedback rule, a project fact that persists
   across sessions), write the memory file now and add its one-line
   pointer to `MEMORY.md`. Memory = forever rules; session log = today's
   work.

3. **🔧 Your Move queue.** Check `docs/human-loop.md`: if any open
   `- [ ]` items were completed this session, check them off; if new
   human-loop actions surfaced, make sure they were recorded. Mention any
   still-open items whose trigger is now due.

4. **🔴 Clean tree + everything pushed — ALWAYS, and release-blocking.**
   Run this **last**, after every other step has finished writing, and
   **never assert it from memory** — "I committed as I went" is exactly
   the belief that hides the failure (pushing `main` says nothing about
   the branch you're actually on, and the post-commit session-log hook
   routinely re-dirties the tree *after* your last commit). Run:

   ```sh
   for wt in $(git worktree list --porcelain | awk '/^worktree /{print $2}'); do
     b=$(git -C "$wt" branch --show-current)
     d=$(git -C "$wt" status --porcelain | wc -l | tr -d ' ')
     u=$(git -C "$wt" log --oneline "origin/$b..$b" 2>/dev/null | wc -l | tr -d ' ')
     printf "%-52s %-22s dirty=%-4s unpushed=%s\n" "$wt" "$b" "$d" "$u"
   done
   ```

   For **the tree this session worked in**: dirty must be 0 and unpushed
   must be 0 before you declare safe to close. Commit anything
   outstanding, then `git push origin <branch>`. If the session also
   merged to `main`, push `main` too — they are two separate pushes. Then
   **re-run the loop and paste the result**; the gate is the verified
   output, not the intent.

   Other worktrees may legitimately be dirty (parallel sessions). Don't
   touch them — just name any you see so the user knows they're
   outstanding.

## Project-specific gates

As this project grows real stakes, add release-blocking checks here —
each one earns its place by a class of failure it prevents. Examples from
the framework this template descends from: a database security-advisor
check that runs only when the session changed schema; an in-flight
physical-process check before closing a session that started one.

## Finish

Reply with an explicit confirmation, e.g.:

> Session log up to date, memory written, Your Move queue current, tree
> clean and pushed. **Safe to close.**

The user waits for "safe to close" before closing the window. Don't end
ambiguously after a wrap-up request.
