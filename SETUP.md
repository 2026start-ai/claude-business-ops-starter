# Setting up Claude Code for business ops

This is the same scaffolding Bruce uses to run Dr Dumpster's day-to-day
decisions through Claude Code in Terminal — pricing, invoicing checks,
vendor emails, compliance follow-ups, all of it tracked in plain text
files that live in a folder on your Mac. None of it is seafood-specific
or dumpster-specific; it's just a way of organizing how Claude
remembers things between sessions. Follow these steps once and you're
running.

## 1. Install Claude Code

If you haven't already:

```
npm install -g @anthropic-ai/claude-code
```

(Needs Node.js installed first — if you don't have it, install Node
from nodejs.org, then run the line above.) Then run `claude` once from
any folder and follow the login prompt to sign in with your Anthropic
account.

## 2. Make a folder for the business

Pick where this lives — Documents, Desktop, wherever. This folder is
going to be your "business brain": everything Claude tracks for you
lives here as plain text files, plus a `.claude/` folder of automation
that runs quietly in the background.

```
mkdir ~/my-business-ops
cd ~/my-business-ops
```

Copy every file and folder from this template into that new folder,
keeping the same structure:

```
my-business-ops/
├── CLAUDE.md
├── .claude/
│   ├── settings.json
│   ├── hooks/
│   │   ├── post-commit-log.sh
│   │   ├── session-start-pull.sh
│   │   ├── human-loop-surface.sh
│   │   └── inbox-surface.sh
│   └── skills/
│       └── close-out/
│           └── SKILL.md
├── docs/
│   ├── backlog.md
│   ├── decisions.md
│   ├── fix-it.md
│   ├── human-loop.md
│   └── sessions/
│       └── README.md
└── _inbox/
    ├── .gitignore
    └── README.md
```

Make the hook scripts executable (this sometimes gets lost when files
are copied/zipped/emailed):

```
chmod +x .claude/hooks/*.sh
```

## 3. Turn it into a git repo

This is what makes the automation work (the hooks log commits, track a
clean/dirty tree, etc.) and gives you a backup/history of every
decision.

```
git init
git add -A
git commit -m "Initial setup"
```

Optional but recommended: create a private repo on GitHub and push
this there too, so you can pick up the same "business brain" from
another computer or phone later:

```
git remote add origin <your-github-repo-url>
git push -u origin main
```

## 4. Fill in CLAUDE.md

Open `CLAUDE.md` and replace the bracketed placeholders:

- `<Project Name>` → your business name
- The one-sentence purpose line
- `<dir>/ — <what lives here>` → any folders specific to your business
  (e.g. a `_recipes/` or `_suppliers/` folder, whatever fits)
- The last line about build/test/run commands only matters if you end
  up with actual code in here (probably not, for pure business-ops
  use) — safe to delete if not needed

Everything else in CLAUDE.md (Session rhythm, the two Gates sections,
Judgment defaults) is the actual operating model — leave it as-is
unless you want to change how it behaves.

## 5. Start using it

From inside the folder, just run:

```
claude
```

Talk to it like you would any assistant — "what's on my worklist
today", "draft an email to this supplier", "check our pricing against
what competitors charge", whatever the actual work is. A few things
that happen automatically once you're set up:

- **Session start**: it pulls the latest from git, and tells you about
  any open "Your Move" items or files you've dropped in `_inbox/`.
- **`_inbox/`**: drop any file in here (a screenshot, a PDF, a CSV) and
  the next session will see it waiting, no need to paste a path.
- **Session log**: every git commit gets logged automatically to
  `docs/sessions/<today>.md`. Claude also writes inline notes there for
  decisions that don't produce a commit.
- **"wrap up" / "close out"**: say this at the end of a session and it
  runs a checklist (session log current, memory saved, nothing left
  uncommitted/unpushed) and tells you explicitly when it's safe to
  close the window.
- **Memory**: Claude Code has a built-in persistent memory feature —
  it will start noticing durable facts (your preferences, standing
  decisions, project facts) and saving them on its own, in a place
  outside this git repo (so it stays private to your machine/account).
  No setup needed for this, it just starts happening.

## Two things worth knowing

- **`docs/backlog.md`, `docs/decisions.md`, `docs/fix-it.md`,
  `docs/human-loop.md`** all start basically empty — that's normal.
  They fill in as you actually use it. Don't try to pre-populate them.
- **Optional extra pattern**: Bruce also keeps a `docs/worklist.md`
  synced from recurring business-meeting minutes (stored in Google
  Drive). That's not included here since it depends on how you run
  meetings — if you want that pattern, describe your meeting rhythm to
  Claude once you're set up and it can build the equivalent file and
  convention for you.

That's it — the rest is just using it.
