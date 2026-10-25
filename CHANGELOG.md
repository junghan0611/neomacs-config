# Changelog

Snapshots of this profile, tagged `vYYYY.M.D[-suffix]`. Newest first.

## Unreleased

## v2026.10.25 — Neomacs 0.0.20, fewer workarounds

### Neomacs

- Raised the default AppImage to 0.0.20 and verified the download's SHA-256 against the GitHub release asset digest.
- Removed the EMMS MPRIS override after service registration, Player interface registration and activation completed on a private D-Bus session without the old panic. Playback and physical media keys remain manual checks.
- Removed Casual's source-only workaround. Recompiled the installed Casual and gptel sources with 0.0.20; all 127 bytecode files loaded in a separate fresh process. Old gptel-rewrite bytecode retained the lambda error until rebuilt.
- Verified named headless daemon startup with `-Q` and no display. Full-profile daemon/client integration was not tested; the startup gate still exercises the GUI path under Xvfb.
- Disabled cursor motion, cursor color cycling and window animations while keeping the normal cursor-blink behavior.
- Documented the memory-report incompatibility: 0.0.20 supplies cumulative allocation counts instead of a live-object census. An isolated allocation/release experiment confirmed heap reclamation while the reported counters stayed high; the overall figure is not comparable to GNU Emacs's estimate or process RSS.
- Kept the Org link-table alignment warning and the existing cursor diagnostic suppression. Added a detailed validation report with measurements, source references and scope limits.

### Profile

- Added `M-e` as an alias for the EWS `C-c w` prefix and a minimal gptel configuration using ChatGPT OAuth. Credentials remain in the ignored `.cache/` directory; Return in Evil normal state does not send a gptel message.
- Ignored project state and restored the standard comment key behavior.
- Updated the README with the 0.0.20 status, upgrade instructions and remaining limitations.

### Validation

- GNU Emacs 31.1 and Neomacs 0.0.20 passed `./run.sh check-all` with empty startup warnings and `<f1>` bound to `casual-editkit-main-tmenu`.
- Basic GUI operation was confirmed by the user. Detailed CJK/input, media-key and rendering checks remain open; no blanket GUI or performance claim is made.

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
