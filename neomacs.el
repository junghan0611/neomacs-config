;;; neomacs.el --- Additions for the Neomacs runtime -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Junghan Kim
;;
;; Author: Junghan Kim <junghanacs@gmail.com>
;; URL: https://github.com/junghan0611/neomacs-config
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Loaded from extra.el before the package configs in lisp/, and only
;; when `my/neomacs-p' is non-nil (see early-init.el).  Everything here answers a difference
;; between Neomacs and GNU Emacs; a setting both runtimes need belongs in
;; extra.el instead, so GNU Emacs stays the baseline Neomacs is compared to.
;;
;; Known differences, Neomacs 0.0.20 vs GNU Emacs 31.1:
;;
;; - Org tables size a link by its raw [[...][...]] text, not its
;;   description, so `org-table-align' pads the column (below).
;; - No native compilation.  Packages live in elpa-neomacs/, see
;;   early-init.el.
;; - With no font set, Neomacs uses Adwaita Mono instead of fontconfig's
;;   monospace.  extra.el's `my/setup-fonts' sets the font explicitly on
;;   both runtimes, so nothing is needed here.
;;
;; Still to check in a GUI session: the menu bar (doomemacs-config saw
;; Neomacs ignore `menu-bar-lines' 0 in `default-frame-alist'; this
;; profile turns it off with `menu-bar-mode' instead) and cursor rendering.
;;
;;; Code:

;;;; Org tables with links

;; Measured with -Q and Org 9.8.7 on both runtimes:
;;
;;   | a | [[https://example.com][설명]] |
;;   | bb | x |
;;
;; After `org-table-align' the second row is 13 characters on GNU Emacs
;; and 38 on Neomacs.  Nothing is lost, but aligning such a table in a real
;; note rewrites it wider and pollutes the diff.  Say so, once per buffer,
;; before it happens.

(defvar-local my/neomacs-org-table-link-warned nil
  "Non-nil once this buffer has been warned about link-width alignment.")

(defun my/neomacs-org-table-link-warn-a (&rest _)
  "Warn once per buffer before aligning an Org table that contains a link."
  (when (and (not my/neomacs-org-table-link-warned)
             (org-at-table-p)
             (save-excursion
               (let ((end (org-table-end)))
                 (goto-char (org-table-begin))
                 (re-search-forward org-link-bracket-re end t))))
    (setq my/neomacs-org-table-link-warned t)
    (message "Neomacs: this table has links; aligning pads columns by raw link width (see neomacs.el)")))

(with-eval-after-load 'org-table
  (advice-add 'org-table-align :before #'my/neomacs-org-table-link-warn-a))

;; The 0.0.19 EMMS MPRIS panic workaround was removed after testing
;; 0.0.20 on a private D-Bus session: service registration returned
;; :primary-owner, Player interface registration and `emms-mpris-enable'
;; completed without error (2026-10-25, EMMS 20260414).

;; Casual's 0.0.19 source-only workaround was also removed: 0.0.20
;; freshly compiled all 109 Casual and 18 gptel files, and a separate
;; process loaded all 127 without error (2026-10-25).  Old .elc files
;; still need recompilation; gptel-rewrite.elc from 0.0.19 retained the
;; (void-variable lambda) failure until rebuilt.

;;;; Renderer effects off

;; Of the 159 renderer effects `neomacs-effect-names' lists, six are on
;; by default (measured with -Q under Xvfb, `neomacs-effect-get'):
;; cursor-blink, cursor-motion (a sliding cursor with a trail),
;; cursor-color-cycle (a cursor whose colour keeps changing), and the
;; window-open / -resize / -movement animations.  This profile wants a
;; plain editor, so all but cursor-blink go.  cursor-blink follows
;; `blink-cursor-mode', as on GNU Emacs.
;;
;; `setopt', not `setq': each option pushes its value to the renderer
;; from its :set function, which `setq' skips.  The window-animation
;; master switch also frees the offscreen frames the animations need;
;; turning the slots off one by one would not.

(when (require 'neomacs-effects nil t)
  (setopt neomacs-cursor-motion-enabled nil
          neomacs-window-animations-off t)
  (when (boundp 'neomacs-effect-cursor-color-cycle)
    (setopt neomacs-effect-cursor-color-cycle
            (plist-put (copy-sequence neomacs-effect-cursor-color-cycle)
                       :enabled nil))))

;;; neomacs.el ends here
