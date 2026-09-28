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
;; Known differences, Neomacs 0.0.19 vs GNU Emacs 31.1:
;;
;; - Org tables size a link by its raw [[...][...]] text, not its
;;   description, so `org-table-align' pads the column (below).
;; - Registering EMMS's MPRIS interface on D-Bus crashes Neomacs (below).
;; - Byte code Neomacs compiles for some of casual's files fails to load;
;;   casual is loaded from source instead (below).
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

;;;; EMMS without MPRIS

;; Registering the MPRIS Player interface on D-Bus panics Neomacs
;; (dbus-0.9.11 strings.rs:187, "Unknown typecode") and takes the whole
;; process down.  Measured with -Q and EMMS 20260414:
;;
;;   (require 'emms-mpris)
;;   (emms-mpris-register-iface emms-mpris-player-iface-spec)
;;
;; init.el calls `emms-mpris-enable' when EMMS first loads, so skip it.
;; EMMS itself works; only desktop media keys via MPRIS are lost.

(advice-add 'emms-mpris-enable :override #'ignore)

;;;; Casual from source

;; Byte code Neomacs compiles for 7 of casual's files fails to load with
;; (void-variable lambda), at `transient-define-prefix' forms; the same
;; files load fine from source.  Loading every .elc in elpa-neomacs/ found
;; no other package affected (337 files load).  So casual is never byte
;; compiled here: skip it on install, and delete .elc an earlier install
;; left behind.  This has to run before lisp/casual-config.el.

(define-advice package--compile (:around (fn pkg-desc) neomacs-skip-casual)
  (unless (eq (package-desc-name pkg-desc) 'casual)
    (funcall fn pkg-desc)))

(dolist (dir (file-expand-wildcards
              (expand-file-name "casual-[0-9]*" package-user-dir)))
  (mapc #'delete-file (directory-files dir t "\\.elc\\'")))

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
