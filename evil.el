;;; evil.el --- Evil layer on top of EWS -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2024-2026 Junghan Kim
;;
;; Author: Junghan Kim <junghanacs@gmail.com>
;; URL: https://github.com/junghan0611/neomacs-config
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Vim keys over upstream Emacs Writing Studio.  Loaded from init.el after
;; the upstream configuration, so upstream bindings stay reachable in Emacs
;; state and under C-c w.
;;
;;; Code:

;;;; Evil

(use-package evil
  :demand t
  :hook ((after-init . evil-mode)
         (prog-mode . hs-minor-mode))
  :init
  ;; Must be set before evil loads.  evil-collection provides the
  ;; per-mode bindings instead.
  (setq evil-want-keybinding nil
        evil-want-C-g-bindings t
        evil-want-C-i-jump nil
        evil-want-C-u-delete t
        evil-want-C-u-scroll t
        evil-want-C-w-delete t
        evil-want-Y-yank-to-eol t
        evil-want-fine-undo t
        evil-undo-system 'undo-redo)
  ;; Do not set `hs-minor-mode-map' to nil: since Emacs 31 hideshow calls
  ;; `keymap-set' on it when the mode turns on, and with the prog-mode hook
  ;; above every package install fails in autoload generation.
  (setq evil-symbol-word-search t
        evil-ex-search-vim-style-regexp t
        evil-search-module 'evil-search
        evil-ex-substitute-global t     ; implicit /g on :s
        evil-cross-lines t
        evil-move-beyond-eol nil
        evil-move-cursor-back nil       ; keep the block cursor put on ESC
        evil-kill-on-visual-paste nil   ; overwritten text stays out of the kill ring
        evil-v$-excludes-newline nil
        evil-split-window-below t       ; focus the new window after splitting
        evil-vsplit-window-right t
        evil-visual-update-x-selection-p nil)
  (setq evil-default-cursor '+evil-default-cursor-fn
        evil-normal-state-cursor 'box
        evil-emacs-state-cursor '(box +evil-emacs-cursor-fn)
        evil-insert-state-cursor 'bar
        evil-visual-state-cursor 'hollow)
  :config
  (defun +evil-default-cursor-fn ()
    (evil-set-cursor-color (get 'cursor 'evil-normal-color)))
  (defun +evil-emacs-cursor-fn ()
    (evil-set-cursor-color (get 'cursor 'evil-emacs-color)))

  ;; Don't create a kill entry on every visual movement.
  ;; https://emacs.stackexchange.com/a/15054
  (fset 'evil-visual-update-x-selection 'ignore))

(use-package evil-collection
  :after evil
  :hook (after-init . evil-collection-init)
  :init
  (add-hook 'org-agenda-mode-hook
            (lambda () (evil-collection-unimpaired-mode -1))))

(use-package evil-nerd-commenter
  :after evil
  :config
  (evilnc-default-hotkeys))

(use-package evil-escape
  :after evil
  :hook (after-init . evil-escape-mode)
  :init
  (setq evil-escape-key-sequence ",."
        evil-escape-unordered-key-sequence nil
        evil-escape-delay 1.0))

(use-package evil-org
  :after evil
  :hook (org-mode . evil-org-mode)
  :init
  (setq evil-org-key-theme '(navigation textobjects additional calendar todo))
  (with-eval-after-load 'org-agenda
    (require 'evil-org-agenda)
    (evil-org-agenda-set-keys))
  (with-eval-after-load 'org-capture
    (add-hook 'org-capture-mode-hook #'evil-insert-state)
    (add-hook 'org-capture-after-finalize-hook #'evil-normal-state)
    (evil-define-key 'normal org-capture-mode-map
      "ZZ" #'org-capture-finalize
      "ZQ" #'org-capture-kill
      "ZR" #'org-capture-refile)))

;;;; Undo

;; Built-in undo-redo (Emacs 28+) instead of undo-fu: u / C-r work the same
;; and it is one package fewer.  Larger limits reduce the chance of losing
;; history.
(setq undo-limit 400000           ; 400kb (default 160kb)
      undo-strong-limit 3000000   ; 3mb   (default 240kb)
      undo-outer-limit 48000000)  ; 48mb  (default 24mb)

;;;; Keys

(keymap-global-set "<escape>" #'keyboard-escape-quit)

(with-eval-after-load 'vertico
  (keymap-set vertico-map "C-j" #'vertico-next)
  (keymap-set vertico-map "C-k" #'vertico-previous)
  (keymap-set vertico-map "M-h" #'vertico-directory-up))

(with-eval-after-load 'evil
  (with-eval-after-load 'org
    (evil-define-key '(normal insert visual) org-mode-map
      (kbd "C-n") #'org-next-visible-heading
      (kbd "C-p") #'org-previous-visible-heading))

  (evil-define-key '(normal motion) 'global "gc" #'evilnc-comment-operator)

  ;; "." searches with consult-line; "/" stays evil search.
  (evil-global-set-key 'normal "." #'consult-line)
  (evil-global-set-key 'normal (kbd "DEL") #'evil-switch-to-windows-last-buffer)

  (keymap-set evil-motion-state-map "L" nil)
  (keymap-set evil-motion-state-map "M" nil)

  ;; Macros live on Q; q is free.
  (keymap-set evil-normal-state-map "q" nil)
  (keymap-set evil-normal-state-map "Q" #'evil-record-macro)

  ;; Emacs-style line keys in normal and insert state.
  (dolist (map (list evil-normal-state-map evil-insert-state-map))
    (keymap-set map "C-a" #'evil-beginning-of-line)
    (keymap-set map "C-e" #'evil-end-of-line-or-visual-line))
  (keymap-set evil-insert-state-map "C-]" #'forward-char)
  (keymap-set evil-insert-state-map "C-k" #'kill-line))

;;;; Input method follows the cursor

;; Hangul toggles only in insert state, and the insert cursor shows which
;; input method is on: bar = off, hbar = korean-hangul.  The cursor type is
;; buffer-local, so it survives window switches.

(defun +evil-input-method-cursor ()
  (setq-local evil-insert-state-cursor
              (if (equal current-input-method "korean-hangul") 'hbar 'bar)))

(defun +evil-block-toggle-input-method ()
  (interactive)
  (message "Input method is disabled in <%s> state." evil-state))

(defun +evil-input-method-cursor-a (fn &rest args)
  (apply fn args)
  (+evil-input-method-cursor))

(with-eval-after-load 'evil
  (dolist (map (list evil-motion-state-map evil-normal-state-map
                     evil-visual-state-map))
    (keymap-set map "<Hangul>" #'+evil-block-toggle-input-method)
    (keymap-set map "S-SPC" #'+evil-block-toggle-input-method))
  (add-hook 'evil-insert-state-entry-hook #'+evil-input-method-cursor)
  (advice-add 'toggle-input-method :around #'+evil-input-method-cursor-a)
  (advice-add 'set-input-method :around #'+evil-input-method-cursor-a))

;;; evil.el ends here
