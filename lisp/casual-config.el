;;; casual-config.el --- Casual Transient UI -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Junghan Kim

;; Author: Junghan Kim <junghanacs@gmail.com>
;; URL: https://github.com/junghan0611/neomacs-config

;;; Commentary:

;; Casual: per-mode Transient menus.  https://github.com/kickingvegas/casual
;; Ported from doomemacs-config/lisp/casual-config.el.
;;
;; `casual-init' binds every Casual module; no per-mode list to maintain.
;;
;; <f1> is global: `casual-editkit-init' sets the primary key with
;; `keymap-global-set', so the default <f1> help prefix is gone — help stays
;; on C-h.  Modes with their own menu open it; elsewhere
;; `casual-editkit-main-tmenu' opens.
;;
;; M-<f1> exists only where upstream uses the secondary key — bibtex,
;; elisp, css, csv, html.
;;
;; Cost: `casual-init' pulls in calc, bibtex, eww, man, esh-mode, ediff,
;; re-builder and cus-edit through the module autoloads (measured in Doom
;; 2026-08-22: 2.6-3.6s, +239 features), so it loads 5s after startup, on
;; idle.  <f1> works from then on.

;;; Code:

(use-package casual
  :defer 5
  :init
  ;; Upstream defaults are C-o / M-m; C-o is evil's jump-back.
  (setq casual-keybinding-primary "<f1>"
        casual-keybinding-secondary "M-<f1>")
  :config
  (casual-init))

(provide 'casual-config)
;;; casual-config.el ends here
