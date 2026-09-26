;;; user-info.el --- GLG identity and paths -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Junghan Kim
;;
;; Loaded from early-init.el, before upstream init.el and ews.el.  Only
;; plain variables live here: ews.el computes `ews-bibtex-files' from
;; `ews-bibtex-directory' at load time, so paths must be set first.
;;
;; Source of truth for these values is doomemacs-config/+user-info.el.
;; Doom-only settings (silo, ten, forge, LLM prompt) are left out.
;;
;;; Code:

;;;; Identity

(setq user-full-name "junghanacs"
      user-mail-address "junghanacs@gmail.com")
(setq-default epa-file-encrypt-to '("B5ADD9F47612A9DB"))
(setq auth-source-cache-expiry nil)

;;;; Fonts — applied in extra.el

(defvar user-font-family "GLG Nerd Font Mono"
  "Default and Hangul family.  It carries Hangul glyphs itself, so one
family covers both scripts.")

(defvar user-font-height 151
  "Default face height (1/10 pt).  Doom uses :size 15.1.")

(defvar user-emoji-family "Noto Emoji"
  "Monochrome emoji only.  Mixing in Noto Color Emoji makes VS-16 emoji
fall back to color glyphs of uneven size.")

;;;; Directories

(defconst user-org-directory (or (getenv "ORG_DIRECTORY") "~/org/"))

(setq org-directory user-org-directory
      org-default-notes-file
      (expand-file-name "meta/20230202T020200--now__aprj_meta.org" user-org-directory))

;; Must match the resolved path for org-store-link to work.
(setq denote-directory (file-truename user-org-directory))

;; ews-bibtex-files collects every *.bib in this directory.
(setq ews-bibtex-directory (expand-file-name "resources/bib" user-org-directory))
(setq citar-notes-paths (list (expand-file-name "bib/" user-org-directory)))

;;;; Spelling

;; Upstream default is en_AU; this machine only ships ko_KR, which is also
;; what Doom's jinx uses.
(setq ews-hunspell-dictionaries "ko_KR")

;;;; Calendar

(setq calendar-latitude 37.26
      calendar-longitude 127.01
      calendar-location-name "Suwon, KR")

;;; user-info.el ends here
