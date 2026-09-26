> **What belongs here**: only things that do not change often — structure, conventions,
> contracts, and traps that keep recurring. The next concrete move lives in `NEXT.md`.
> If this file contradicts the code, the code is right and this file is a bug.

# AGENTS.md — neomacs-config Agent Guide

You are the **담당자** (agent-in-charge) for this repository.

## What This Repo Is

A small, distributable Emacs profile: **upstream Emacs Writing Studio (EWS) plus a thin
GLG layer**, run with `--init-directory` so it never touches the main setup.

- **Main setup** is `~/repos/gh/doomemacs-config` (20K-line Doom). It must not break,
  so experiments that could break it happen here instead.
- **This repo** is the simple dotfile: readable in one sitting, installable by anyone,
  and — next — the profile that covers **Neomacs** (Rust reimplementation of the Emacs
  core). Formerly `ews-config`; GitHub is now
  <https://github.com/junghan0611/neomacs-config>. The local directory may still be
  `~/repos/gh/ews-config` — see `NEXT.md`.
- Upstream: <https://github.com/pprevos/emacs-writing-studio> (remote `upstream`,
  branch `master`). Our branch is `main`.

## Layout — upstream vs GLG layer

| File | Owner | Role |
|---|---|---|
| `init.el` | upstream | EWS config. Differs from `upstream/master` only by the two `load-file` lines for `evil.el` / `extra.el`. |
| `ews.el` | upstream | EWS helper functions and `defcustom`s. Do not edit. |
| `documents/`, `readme.org`, images | upstream | EWS book sources and upstream readme. |
| `early-init.el` | GLG | Pins `custom-file`, then loads `user-info.el`. |
| `user-info.el` | GLG | Identity, font names, org / denote / bib paths, spelling, calendar. Plain variables only. |
| `evil.el` | GLG | Evil and its companions, cursor-per-input-method. |
| `extra.el` | GLG | Korean environment, fonts, one-theme-at-a-time, small packages; adds `lisp/` to `load-path`. |
| `lisp/*.el` | GLG | Longer package configs, one file per concern, `provide`d and `require`d from `extra.el`. Ported from `doomemacs-config/lisp/` — replace `use-package!` / `after!` / `map!` with plain `use-package` / `with-eval-after-load` / `keymap-set`. |
| `bin/ews.sh` | GLG | Launcher and headless boot check. |

**Contract: keep `init.el` and `ews.el` as close to upstream as possible.** Anything
GLG-specific goes into the GLG files. That keeps `git merge upstream/master` down to
one small conflict at most, and keeps "is this upstream or us?" answerable.

Load order: `early-init.el` → `user-info.el` → `init.el` (→ `ews.el` … → `evil.el` →
`extra.el` → `lisp/*`) → `custom.el`.

`user-info.el` mirrors a subset of `doomemacs-config/+user-info.el`. That file is the
source of truth; copy values from it rather than inventing new ones.

## Running

```bash
./bin/ews.sh             # GUI
./bin/ews.sh --nw        # terminal
./bin/ews.sh --check     # headless boot check: daemon under a throwaway HOME
EMACS_BIN=<binary> ./bin/ews.sh --check   # same profile on another runtime
```

Packages install into `elpa/` inside this repo (gitignored). The first run installs
~80 packages and takes a few minutes.

**`--check` is the green gate.** It must print `user-init-file:` equal to this repo's
`init.el` and an empty `*Warnings*` section. A run whose `user-init-file` is anything
else is void — the profile did not load.

## Recurring traps

- **`~/.emacs` shadows `<init-directory>/init.el`.** If `~/.emacs`, `~/.emacs.el` or
  `~/.emacs.elc` exists, Emacs loads it instead of this repo's `init.el`. It does not
  error, so the profile just isn't there. `bin/ews.sh` refuses to start when one exists.
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

## Syncing with upstream

```bash
git fetch upstream
git rev-list --count HEAD..upstream/master      # how far behind
git merge --no-commit --no-ff upstream/master   # then resolve, --check, show GLG
```

Resolve `init.el` by taking upstream and re-adding the two GLG `load-file` lines after
the `custom-file` block. Run `--check` before proposing the merge commit.

## Rules

- Commits and pushes are GLG's decision. Do not commit unasked.
- Public repo: repo documents (`AGENTS.md`, `README.md`) are in English; `NEXT.md` is an
  internal handoff and stays in Korean.
- Do not touch `~/repos/gh/doomemacs-config` from here. Ask its agent-in-charge.
