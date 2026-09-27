# Changelog

Snapshots of this profile, tagged `vYYYY.M.D[-suffix]`. Newest first.

## Unreleased

## v2026.9.27 — first cut as neomacs-config

One Emacs profile, grown from Emacs Writing Studio, that runs on GNU Emacs 31.1 and on Neomacs 0.0.19. Checked headless on both runtimes and by hand in a GUI on both.

### Profile

- Rebuilt on current upstream Emacs Writing Studio, then forked: upstream fixes are cherry-picked from now on, and `init.el` is ours to change.
- Renamed from `ews-config` to `neomacs-config`.
- Casual is the main interface: it loads at startup and `<f1>` opens a Casual menu on both runtimes.
- Evil layer tidied: built-in `undo-redo` instead of undo-fu, Doom-only macros replaced with plain Emacs.
- Org no longer turns on `mixed-pitch-mode` or `org-modern-mode`; the profile ends by loading one Modus theme (`modus-operandi-tinted`) so every face matches.
- Identity, fonts and paths live in `user-info.el`; `early-init.el` pins `custom-file` so a stray `~/.emacs` can no longer shadow the profile.

### Neomacs

- `early-init.el` detects Neomacs by a Neomacs-only primitive (`emacs-version` reads "GNU Emacs 31.1" there) and gives it its own `elpa-neomacs/`.
- `neomacs.el`, loaded only on Neomacs, holds workarounds for measured differences: a warning before aligning Org tables that contain links, EMMS without its MPRIS D-Bus service (registering it crashes Neomacs), and Casual loaded from source (7 of its Neomacs-compiled files fail to load).
- `./run.sh neo` hides the renderer's per-redraw cursor/cell diagnostic and the AppImage's GIO module errors.

### Tooling

- `run.sh` replaces `bin/ews.sh`: `gnu|neo` × `gui|nw|debug|check|version`, plus `check-all` and `fetch`.
- `check` boots the real GUI on Xvfb under a throwaway HOME, reports once startup is idle, and exits without `kill-emacs-hook`, restoring the profile's state files. It never opens a window on the user's screen and never rewrites `recentf` or `history`.
- GNU Emacs's native-compilation cache stays inside the profile instead of `~/.config/emacs/eln-cache/`.
