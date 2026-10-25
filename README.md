# neomacs-config

A simple, portable Emacs profile grown from [Emacs Writing Studio][ews] by Peter
Prevos, plus a thin personal layer — Evil, [Casual][casual] menus on `<f1>`, Korean
input and fonts, Denote / Org / BibTeX paths.

It runs beside any existing Emacs setup through `--init-directory`, so it does not
touch `~/.emacs.d` or `~/.config/emacs`. The same profile runs on GNU Emacs and on
[Neomacs][neomacs], a Rust reimplementation of the Emacs core, so the two can be
compared side by side.

> Status: GNU Emacs 31.1 and Neomacs 0.0.20 passed the GUI-startup checks;
> basic Neomacs GUI operation was also confirmed by the user. Forked from EWS
> (formerly `ews-config`); upstream fixes are taken one by one. The personal layer
> remains Korean-first while this grows into a reusable sample profile.

## Requirements

- GNU Emacs 29 or later (tested on 31.1), and optionally Neomacs (tested on 0.0.20)
- Network access to GNU ELPA, NonGNU ELPA and MELPA on first start
- Optional external tools that EWS checks for at startup: `gs`/`mutool`, `pdftotext`,
  `soffice`, `zip`, `ddjvu`, `curl`, `mpv`, `ripgrep`, `convert`, `dvipng`, `latex`,
  `hunspell`, `git`

## Usage

```bash
git clone https://github.com/junghan0611/neomacs-config.git
cd neomacs-config
./run.sh                # GUI on GNU Emacs
./run.sh nw             # terminal
./run.sh check          # headless boot check under a throwaway HOME
./run.sh neo            # GUI on Neomacs
./run.sh neo check      # headless boot check on Neomacs
./run.sh check-all      # both runtimes, then a summary
./run.sh fetch          # download the Neomacs release AppImage (needs gh)
```

`./run.sh help` lists every option. `EMACS_BIN` and `NEOMACS_BIN` select the binaries;
without `NEOMACS_BIN`, `run.sh` uses `neomacs` on `PATH` or the release AppImage
(default: 0.0.20; override with `NEOMACS_VERSION`). Upgrade measurements and remaining
manual checks are in [the 0.0.20 validation report](documents/neomacs-0.0.20-validation.md).

The first start on each runtime installs packages inside the repo — `elpa/` for GNU
Emacs, `elpa-neomacs/` for Neomacs — and takes a few minutes. Customizations are saved
to `custom.el` in the repo.

If `~/.emacs` exists, Emacs loads it instead of this profile; `run.sh` refuses to
start in that case.

## Neomacs 0.0.20 snapshot

- The default AppImage is 0.0.20. Its D-Bus fixes let this profile stop blocking
  EMMS MPRIS registration; actual playback and desktop media keys remain manual checks.
- Casual no longer needs source-only loading. Freshly compiled Casual and gptel
  bytecode passed a separate-process load check (127 files).
- Named headless daemon startup works with `-Q`; full-profile/client integration
  has not been validated. `check` deliberately still tests GUI startup on Xvfb.
- Cursor motion, color cycling and window animations are disabled for a plain editor.
- `M-e` opens the same EWS prefix map as `C-c w`. The optional gptel integration
  uses ChatGPT OAuth; credentials stay in the ignored `.cache/` directory.

**Known limitations:** Org tables containing links still align by raw link width.
Neomacs 0.0.20 also feeds cumulative allocation counts into `memory-report`, so
its overall object memory figure is not comparable to GNU Emacs's live-object
estimate and is not process RSS. Use OS RSS/PSS and Neomacs heap diagnostics for
actual memory investigation. See the [validation report](documents/neomacs-0.0.20-validation.md)
for source references, measurements and remaining manual checks.

When upgrading from 0.0.19, recompile existing Casual/gptel bytecode rather than
reusing it as a test of the new runtime. From the running Neomacs profile:

```elisp
(require 'bytecomp)
(dolist (name '("casual" "gptel"))
  (dolist (dir (file-expand-wildcards
                (expand-file-name (concat name "-[0-9]*") package-user-dir)))
    (byte-recompile-directory dir 0 t)))
```

Restart Neomacs afterwards. This rebuilds installed sources without updating packages.

## Making it yours

| File | What to change |
|---|---|
| `user-info.el` | name, mail, font families, org / Denote / BibTeX directories, spelling dictionary |
| `evil.el` | remove the `load-file` line in `init.el` if you do not want Evil |
| `extra.el` | language environment, fonts, extra packages |
| `neomacs.el` | loaded only on Neomacs: workarounds for known differences from GNU Emacs |
| `lisp/` | longer package configs, loaded from `extra.el` (e.g. `casual-config.el`: Casual menus on `<f1>`, loaded at startup) |

`init.el` and `ews.el` come from EWS; personal changes live in the files above. For
EWS itself, see [readme.org](readme.org) and the [EWS book][ews].

## License

GPL-3.0, as upstream. See [LICENSE](LICENSE).

[ews]: https://github.com/pprevos/emacs-writing-studio
[neomacs]: https://github.com/eval-exec/neomacs
[casual]: https://github.com/kickingvegas/casual
