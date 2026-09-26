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

;; Identity and paths, needed before ews.el computes its defaults.
(load (expand-file-name "user-info.el" user-emacs-directory) nil 'nomessage)

;;; early-init.el ends here
