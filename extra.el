;;; extra.el --- Korean environment, fonts and small additions -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025-2026 Junghan Kim
;;
;; Author: Junghan Kim <junghanacs@gmail.com>
;; URL: https://github.com/junghan0611/neomacs-config
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Loaded last from init.el.  Values (fonts, paths) come from user-info.el;
;; longer package configs live in lisp/.
;;
;;; Code:

;;;; Korean environment

(set-language-environment "Korean")
(prefer-coding-system 'utf-8)
(set-charset-priority 'unicode)
(set-default-coding-systems 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(setq-default buffer-file-coding-system 'utf-8-unix)

;; Clipboard: UTF-8 first, then compound text.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; English day names in Org timestamps.
(setq system-time-locale "C")

(setq default-input-method "korean-hangul"
      input-method-verbose-flag nil
      input-method-highlight-flag nil)
(keymap-global-set "S-SPC" #'toggle-input-method)
(keymap-global-set "<Hangul>" #'toggle-input-method)

;;;; Fonts

;; Column check — both halves must line up:
;; +------------+------------+
;; | 일이삼사오 | 일이삼사오 |
;; | ABCDEFGHIJ | ABCDEFGHIJ |
;; | 1234567890 | 1234567890 |
;; +------------+------------+

;; Applied per frame so a daemon's later GUI frames get them too; a no-op on
;; TTY frames.
(defun my/setup-fonts (&optional frame)
  (when (display-graphic-p (or frame (selected-frame)))
    (set-face-attribute 'default frame
                        :family user-font-family :height user-font-height)
    (set-fontset-font t 'hangul (font-spec :family user-font-family) frame)
    (set-fontset-font t 'emoji (font-spec :family user-emoji-family) frame)
    (set-fontset-font t 'symbol (font-spec :family "Symbola") frame)
    (set-fontset-font t 'symbol (font-spec :family "Noto Sans Symbols 2") frame 'prepend)
    (set-fontset-font t 'symbol (font-spec :family "Noto Sans Symbols") frame 'prepend)))

(my/setup-fonts)
(add-hook 'after-make-frame-functions #'my/setup-fonts)

;;;; Themes

;; One theme at a time: disable the rest before loading another.
(defun +load-theme-disable-others-a (&rest _)
  (mapc #'disable-theme custom-enabled-themes))
(advice-add 'load-theme :before #'+load-theme-disable-others-a)

;;;; Packages

(use-package yasnippet :defer t)
(use-package wgrep :defer t)
(use-package transpose-frame :defer t)

;;;; Neomacs

;; Runtime-specific additions; GNU Emacs never loads them.  Loaded before
;; lisp/ so its workarounds are in place when those packages load.
(when my/neomacs-p
  (load (expand-file-name "neomacs.el" user-emacs-directory) nil 'nomessage))

;;;; Package configs

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'casual-config)

;;;; Theme

;; Last, so every face defined during startup gets it: loads the first of
;; `modus-themes-to-toggle' (set in init.el).
(modus-themes-toggle)

;;; extra.el ends here
