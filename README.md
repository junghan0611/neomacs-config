# neomacs-config

A simple, portable Emacs profile grown from [Emacs Writing Studio][ews] by Peter
Prevos, plus a thin personal layer — Evil, [Casual][casual] menus on `<f1>`, Korean
input and fonts, Denote / Org / BibTeX paths.

It runs beside any existing Emacs setup through `--init-directory`, so it does not
touch `~/.emacs.d` or `~/.config/emacs`. The same profile runs on GNU Emacs and on
[Neomacs][neomacs], a Rust reimplementation of the Emacs core, so the two can be
compared side by side.

> Status: rebuilt in September 2026 on EWS and GNU Emacs 31.1, and forked from EWS since;
> upstream fixes are taken one by one. Formerly `ews-config`. Neomacs support is being validated; the personal layer is
> still Korean-first and will be generalized into a sample profile.

## Requirements

- GNU Emacs 29 or later (tested on 31.1), and optionally Neomacs (tested on 0.0.19)
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
without `NEOMACS_BIN`, `run.sh` uses `neomacs` on `PATH` or the release AppImage.

The first start on each runtime installs packages inside the repo — `elpa/` for GNU
Emacs, `elpa-neomacs/` for Neomacs — and takes a few minutes. Customizations are saved
to `custom.el` in the repo.

If `~/.emacs` exists, Emacs loads it instead of this profile; `run.sh` refuses to
start in that case.

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
