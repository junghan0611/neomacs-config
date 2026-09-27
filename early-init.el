;;; early-init.el --- GLG layer, loaded before upstream EWS init.el -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Junghan Kim
;;
;; This file is not part of Emacs Writing Studio upstream.  Keep upstream
;; init.el as close to pprevos/emacs-writing-studio as possible and put
;; anything that must happen earlier here.
;;
;;; Code:

;; Pin custom-file inside this profile before anything can write Custom
;; state.  Upstream sets it at the very end of init.el, but package
;; installation (package-selected-packages) and local-variable approvals
;; run earlier and would otherwise land in init.el or ~/.emacs.  A stray
;; ~/.emacs silently shadows --init-directory's init.el.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Runtime.  Neomacs (a Rust reimplementation of the Emacs core) reports a
;; GNU-compatible version string -- `emacs-version' reads "GNU Emacs 31.1"
;; on Neomacs 0.0.19 -- so only a Neomacs-only primitive tells the two
;; apart.  `neomacs-core-backend' exists in 0.0.13 and 0.0.19.
(defconst my/neomacs-p (fboundp 'neomacs-core-backend)
  "Non-nil when running on Neomacs rather than GNU Emacs.")

;; One package directory per runtime.  GNU Emacs natively compiles
;; packages and Neomacs has no native compilation, and a shared directory
;; would make "is the package broken or the runtime?" unanswerable.
(when my/neomacs-p
  (setq package-user-dir (expand-file-name "elpa-neomacs" user-emacs-directory)))

;; Native compilation (GNU Emacs only).  --init-directory does not move the
;; eln cache: it stays under the default Emacs directory, which is
;; ~/.config/emacs -- another setup's directory -- on a machine that has
;; one.  Keep it inside this profile.  Compiler warnings from the async
;; jobs are about third-party package code; show them only with
;; --debug-init.
(when (and (fboundp 'native-comp-available-p) (native-comp-available-p))
  (startup-redirect-eln-cache (expand-file-name "eln-cache/" user-emacs-directory))
  (setq native-comp-async-report-warnings-errors init-file-debug))

;; Identity and paths, needed before ews.el computes its defaults.
(load (expand-file-name "user-info.el" user-emacs-directory) nil 'nomessage)

;;; early-init.el ends here
