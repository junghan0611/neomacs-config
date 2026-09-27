> **What belongs here**: only things that do not change often — structure, conventions,
> contracts, and traps that keep recurring. The next concrete move lives in `NEXT.md`.
> If this file contradicts the code, the code is right and this file is a bug.

# AGENTS.md — neomacs-config Agent Guide

You are the **담당자** (agent-in-charge) for this repository.

## What This Repo Is

A small, distributable Emacs profile, **grown from Emacs Writing Studio (EWS) plus a
thin GLG layer**, run with `--init-directory` so it never touches another setup. It is
on its way to being GLG's main Emacs.

- **Main setup** is `~/repos/gh/doomemacs-config` (20K-line Doom). It must not break,
  so experiments that could break it happen here instead.
- **This repo** is the simple dotfile: readable in one sitting, installable by anyone,
  and the profile that covers **Neomacs** (Rust reimplementation of the Emacs core).
  The same profile runs on GNU Emacs 31 and on Neomacs; GNU is the baseline.
  Formerly `ews-config`; GitHub is <https://github.com/junghan0611/neomacs-config>,
  local directory `~/repos/gh/neomacs-config`.
- **doomemacs-config is a reference, not a template.** Borrow values and ideas from it,
  but keep this repo's structure generic: the goal is a sample profile other people can
  adopt. The GLG layer is Korean-first while Neomacs is being validated; once it
  settles, it becomes English with a guide for users.
- **Forked from EWS, not tracking it.** Upstream is
  <https://github.com/pprevos/emacs-writing-studio> (remote `upstream`, branch
  `master`); our branch is `main`. Since 2026-09-27 upstream changes come in only as
  real bug fixes, picked one by one. This repo may drop EWS packages it does not need.
- **Casual is the main interface.** Near-vanilla Emacs plus Evil is hard to use without
  it, so `lisp/casual-config.el` loads it at startup and `<f1>` must open a Casual menu
  on both runtimes. `check` reports the `<f1>` binding.

## Layout — EWS-derived vs GLG layer

| File | Owner | Role |
|---|---|---|
| `init.el` | EWS-derived | EWS config plus the two `load-file` lines for `evil.el` / `extra.el`. Ours to change now; keep edits deliberate. |
| `ews.el` | EWS-derived | EWS helper functions and `defcustom`s. |
| `documents/`, `readme.org`, images | upstream | EWS book sources and upstream readme. |
| `early-init.el` | GLG | Pins `custom-file`, detects the runtime (`my/neomacs-p`), splits `package-user-dir` per runtime, keeps the eln cache in the profile, then loads `user-info.el`. |
| `user-info.el` | GLG | Identity, font names, org / denote / bib paths, spelling, calendar. Plain variables only. |
| `evil.el` | GLG | Evil and its companions, cursor-per-input-method. |
| `extra.el` | GLG | Korean environment, fonts, one-theme-at-a-time, small packages; loads `neomacs.el` on Neomacs, then `lisp/` configs. |
| `neomacs.el` | GLG | Neomacs only. Each entry answers a measured difference from GNU Emacs. |
| `lisp/*.el` | GLG | Longer package configs, one file per concern, `provide`d and `require`d from `extra.el`. Ported from `doomemacs-config/lisp/` — replace `use-package!` / `after!` / `map!` with plain `use-package` / `with-eval-after-load` / `keymap-set`. |
| `run.sh` | GLG | Launcher and headless boot check for both runtimes. |

Personal values and additions still go into the GLG files rather than `init.el`, so
"what is EWS and what is ours?" stays answerable while the two drift apart.

Load order: `early-init.el` → `user-info.el` → `init.el` (→ `ews.el` … → `evil.el` →
`extra.el` → `neomacs.el` on Neomacs → `lisp/*`) → `custom.el`.

`user-info.el` mirrors a subset of `doomemacs-config/+user-info.el`. That file is the
source of truth; copy values from it rather than inventing new ones.

## Running

```bash
./run.sh [gnu|neo] [gui|nw|debug|check|version]   # runtime defaults to gnu
./run.sh check-all                                 # check on both, then a summary
./run.sh fetch [TAG]                               # Neomacs release AppImage
```

Packages install into `elpa/` (GNU) or `elpa-neomacs/` (Neomacs) inside this repo, both
gitignored. The first run on each runtime installs ~80 packages and takes minutes.

**`check` is the green gate.** It boots the real GUI startup on a virtual display
(Xvfb) under a throwaway HOME, writes a report once startup goes idle, and exits. It
exits 0 only when `user-init-file` equals this repo's `init.el` (else 3: the run is void,
the profile did not load) and `*Warnings*` is empty (else 4). A startup stuck on a
prompt reports the prompt text under `minibuffer:`.

**Order between runtimes: GNU green first.** Only what is green on GNU Emacs moves to
Neomacs, so a divergence is attributable to the runtime and not to this config.
Workarounds for Neomacs go into `neomacs.el`, never into the shared files.

## Recurring traps

- **`~/.emacs` shadows `<init-directory>/init.el`.** If `~/.emacs`, `~/.emacs.el` or
  `~/.emacs.elc` exists, Emacs loads it instead of this repo's `init.el`. It does not
  error, so the profile just isn't there. `run.sh` refuses to start when one exists.
  A stray `~/.emacs` usually appears when Custom saves state (for example a
  local-variables approval) with no `custom-file` set — which is why `early-init.el`
  pins `custom-file` before anything else runs.
- **`ews.el` computes `ews-bibtex-files` at load time.** Path variables must be set
  before `init.el` runs, i.e. in `user-info.el`, not afterwards.
- **Never set `hs-minor-mode-map` to nil.** Since Emacs 31, hideshow calls
  `keymap-set` on it when the mode turns on. With `hs-minor-mode` on `prog-mode-hook`,
  autoload generation (which enters `emacs-lisp-mode`) fails with
  `keymapp nil` and every package install after `evil` breaks.
- **A failed install leaves a half package** (directory without `*-autoloads.el`),
  and later starts report `Cannot load <pkg>`. Delete that `elpa/<pkg>-*` directory and
  start again.
- **Headless check does not see GUI.** Fonts, frames and input method must be checked
  by GLG in a real GUI session.
- **`check` isolates HOME, not the profile.** State files (`recentf.eld`, `history`,
  bookmarks) live in this repo and are GLG's real ones. `check` exits with
  `kill-emacs-hook` unbound (recentf would otherwise prune every `~/` path) and restores
  a snapshot afterwards (savehist also saves on a 5-minute timer). Keep both.
- **A check must never open a window on GLG's screen.** Neomacs 0.0.19 needs a display
  even for `--daemon`, and rejects `--daemon=NAME` as an unknown option, then carries on
  as a normal GUI session. That is why `check` uses Xvfb, not a daemon.
- **`emacs-version` does not identify Neomacs.** Neomacs 0.0.19 reports
  `GNU Emacs 31.1`. Detect it with `(fboundp 'neomacs-core-backend)` (`my/neomacs-p`).
- **`--init-directory` does not move GNU's eln cache.** Without
  `startup-redirect-eln-cache` in `early-init.el`, native-compiled packages land in
  `~/.config/emacs/eln-cache/` — the Doom directory on GLG's machines.
- **Neomacs-compiled byte code can be broken.** 7 of casual's `.elc` files fail with
  `(void-variable lambda)`; `neomacs.el` keeps casual uncompiled on Neomacs. After a
  Neomacs version bump, re-audit by loading every `.elc` in `elpa-neomacs/`.
- **Org tables with links diverge on Neomacs.** `org-table-align` sizes a link by its
  raw `[[...][...]]` text, so aligning rewrites the table wider (see `neomacs.el`).

## Taking a fix from upstream

No more whole merges. When an upstream EWS commit fixes a real bug:

```bash
git fetch upstream
git log --oneline HEAD..upstream/master   # read, pick
git cherry-pick <sha>                     # then ./run.sh check-all, show GLG
```

## Rules

- Commits and pushes are GLG's decision. Do not commit unasked.
- Public repo: repo documents (`AGENTS.md`, `README.md`) are in English; `NEXT.md` is an
  internal handoff and stays in Korean.
- Do not touch `~/repos/gh/doomemacs-config` from here. Ask its agent-in-charge.
