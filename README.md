# neomacs-config

A simple, portable Emacs profile: [Emacs Writing Studio][ews] by Peter Prevos, plus a
thin personal layer — Evil, Korean input and fonts, Denote / Org / BibTeX paths.

It runs beside any existing Emacs setup through `--init-directory`, so it does not
touch `~/.emacs.d` or `~/.config/emacs`.

> Status: rebuilt in September 2026 on top of current upstream EWS and GNU Emacs 31.1.
> Formerly `ews-config`. Next direction is covering [Neomacs][neomacs].

## Requirements

- GNU Emacs 29 or later (tested on 31.1)
- Network access to GNU ELPA, NonGNU ELPA and MELPA on first start
- Optional external tools that EWS checks for at startup: `gs`/`mutool`, `pdftotext`,
  `soffice`, `zip`, `ddjvu`, `curl`, `mpv`, `ripgrep`, `convert`, `dvipng`, `latex`,
  `hunspell`, `git`

## Usage

```bash
git clone https://github.com/junghan0611/neomacs-config.git
cd neomacs-config
./bin/ews.sh             # GUI
./bin/ews.sh --nw        # terminal
./bin/ews.sh --check     # headless boot check under a throwaway HOME
```

The first start installs packages into `elpa/` inside the repo and takes a few
minutes. Customizations are saved to `custom.el` in the repo.

If `~/.emacs` exists, Emacs loads it instead of this profile; `bin/ews.sh` refuses to
start in that case.

## Making it yours

| File | What to change |
|---|---|
| `user-info.el` | name, mail, font families, org / Denote / BibTeX directories, spelling dictionary |
| `evil.el` | remove the `load-file` line in `init.el` if you do not want Evil |
| `extra.el` | language environment, fonts, extra packages |
| `lisp/` | longer package configs, loaded from `extra.el` (e.g. `casual-config.el`: Casual menus on `<f1>`) |

`init.el` and `ews.el` are kept as close to upstream EWS as possible so upstream
updates can be merged. For EWS itself, see [readme.org](readme.org) and the
[EWS book][ews].

## License

GPL-3.0, as upstream. See [LICENSE](LICENSE).

[ews]: https://github.com/pprevos/emacs-writing-studio
[neomacs]: https://github.com/eval-exec/neomacs
