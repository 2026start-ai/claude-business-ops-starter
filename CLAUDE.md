# <Project Name>

<One-sentence purpose: what this repo is and who it serves.>

## Repo map

- `<dir>/` — <what lives here>
- `docs/` — session logs, backlog, decisions, human-loop and fix-it queues (see Session rhythm)
- `_inbox/` — drop zone for files handed to Claude (gitignored; surfaced automatically at session start)

## Session rhythm

- **Start:** read the most recent `docs/sessions/` log (its `## Next move` section is the resume point) and `docs/backlog.md` "Next up". Search `docs/decisions.md` before re-litigating a settled decision.
- **Session log** (`docs/sessions/<YYYY-MM-DD>.md`): the post-commit hook auto-appends commits. Append inline notes yourself for decisions that don't produce commits — rejected approaches, discovered constraints — as they happen, not at session end.
- **Wrap-up:** when I say "wrap up" / "close out" / similar, run the `close-out` skill and end with its explicit "safe to close" confirmation — never ambiguously.

## Gates

### 🔧 Your Move — human-loop actions

When completion depends on my hands (account signups, credential steps, decisions only I can make): flag it in chat under a scannable `🔧 Your Move` heading with numbered steps and a deadline, AND append it to `docs/human-loop.md` (`- [ ] <action> — <why> — <when> — added <YYYY-MM-DD>`). The SessionStart hook resurfaces open items — nudge when one is due, check it off when I confirm it's done.

### 🔨 Fix-it — defects noticed in passing

Out-of-scope defects never pass silently: quick and low-risk → fix now as its own commit per root cause; otherwise log to `docs/fix-it.md` in the moment. Knock out open items when a session's work brushes them; weighty ones graduate to `docs/backlog.md`.

## Judgment defaults

- **Review cost matches reversibility.** Heavy review only for hard-to-reverse changes (money math, auth, data migrations); everything else gets inline self-review.
- **Instrument on the second failed fix** against an opaque external system — stop the guess-then-commit loop and probe the actual response (`superpowers:systematic-debugging`) instead of trying a third guess.

## Conventions

- **Secrets:** env vars only, never committed. Document every key in `.env.example`.
- <build / test / run commands — run `/init` and merge what it generates here>
