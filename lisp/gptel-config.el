;;; gptel-config.el --- gptel on a ChatGPT subscription -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Junghan Kim

;; Author: Junghan Kim <junghanacs@gmail.com>
;; URL: https://github.com/junghan0611/neomacs-config

;;; Commentary:

;; gptel with one backend: a ChatGPT Plus/Pro subscription over OAuth, not
;; an API key.  https://github.com/karthink/gptel
;; A small subset of doomemacs-config/lisp/ai-gptel.el — no quick lookups,
;; buffer summaries, tools or presets.
;;
;; Log in once with M-x gptel-openai-oauth-login.  The token is cached in
;; .cache/gptel-openai/ under this profile (gitignored); Doom keeps its own.
;; `gptel-make-openai-oauth' is in gptel since 56e5b06 (MELPA has it).
;;
;; Sending, in a gptel buffer:
;;   C-c RET   send (gptel's own binding)
;;   S-RET     `gptel-menu' in normal state (evil-collection)
;;   RET       never sends — see below

;;; Code:

;;;; Evil

;; evil-collection binds its REPL-wide `repl-submit' to RET in normal
;; state, which makes RET in a gptel buffer send the prompt.  Keep it for
;; other REPLs, drop it for gptel.  Must be set before
;; `evil-collection-init' runs on `after-init-hook'.
(setq evil-collection-binding-overrides
      (cons (list 'repl-submit
                  :enabled (lambda (map-sym &rest _)
                             (not (eq map-sym 'gptel-mode-map))))
            (bound-and-true-p evil-collection-binding-overrides)))

;;;; gptel

(use-package gptel
  :defer t
  :config
  ;; Without :models the menu lists every model upstream knows.
  (setq gptel-backend (gptel-make-openai-oauth "OpenAI-sub"
                        :models '(gpt-6-sol gpt-6-luna))
        gptel-model 'gpt-6-sol))

(provide 'gptel-config)

;;; gptel-config.el ends here
