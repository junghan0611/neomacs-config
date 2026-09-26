#!/usr/bin/env bash
# Emacs Writing Studio + GLG layer launcher.
#
# Runs this repository as an isolated Emacs profile via --init-directory,
# separate from Doom (~/.emacs.d).  The runtime is swappable: EMACS_BIN
# selects the binary, so the same profile runs on GNU Emacs and Neomacs.
#
# Usage:
#   ./bin/ews.sh                 # GUI
#   ./bin/ews.sh --nw            # terminal
#   ./bin/ews.sh --check         # headless boot check (daemon, isolated HOME)
#   ./bin/ews.sh --debug         # GUI with --debug-init
#   ./bin/ews.sh [emacs args]    # anything else is passed through
#
#   EMACS_BIN=neomacs ./bin/ews.sh --check
#
# --check boots the real startup path (early-init.el, init.el) as a daemon
# under a throwaway HOME and prints user-init-file first.  If it is not this
# repository's init.el, every other result of that run is void.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$(dirname "$SCRIPT_DIR")"
EMACS_BIN="${EMACS_BIN:-emacs}"
SERVER_NAME="${EWS_SERVER_NAME:-ews}"

die() { echo "[ews] $*" >&2; exit 1; }

# ~/.emacs and friends take precedence over <init-directory>/init.el, so
# their presence means this profile would silently not load.
guard_dot_emacs() {
	local home="$1" f
	for f in .emacs .emacs.el .emacs.elc; do
		[[ -e "${home}/${f}" ]] && die "${home}/${f} exists and would shadow ${PROFILE_DIR}/init.el; move it away first"
	done
	return 0
}

TMP_HOME=""
cleanup() { [[ -n "${TMP_HOME}" ]] && rm -rf "${TMP_HOME}"; return 0; }
trap cleanup EXIT

check_boot() {
	local tmp_home rc=0
	tmp_home="$(mktemp -d -t ews-home.XXXXXX)"
	TMP_HOME="${tmp_home}"
	guard_dot_emacs "${tmp_home}"
	local server="${SERVER_NAME}-check-$$"

	echo "[ews] runtime: $("${EMACS_BIN}" --version | head -1)"
	echo "[ews] profile: ${PROFILE_DIR}"
	echo "[ews] HOME:    ${tmp_home}"

	HOME="${tmp_home}" XDG_CONFIG_HOME="${tmp_home}/.config" \
		XDG_CACHE_HOME="${tmp_home}/.cache" XDG_DATA_HOME="${tmp_home}/.local/share" \
		"${EMACS_BIN}" --init-directory "${PROFILE_DIR}" --daemon="${server}" \
		>"${tmp_home}/daemon.log" 2>&1 || rc=$?
	if (( rc != 0 )); then
		cat "${tmp_home}/daemon.log"
		die "daemon failed to start (rc=${rc})"
	fi

	HOME="${tmp_home}" "${EMACS_BIN}" --batch --eval "
(progn
  (require 'server)
  (let ((r (server-eval-at \"${server}\"
             '(list user-init-file custom-file
                    (bound-and-true-p evil-mode)
                    (featurep 'denote) (featurep 'citar)
                    (with-current-buffer (get-buffer-create \"*Warnings*\")
                      (buffer-substring-no-properties (point-min) (point-max)))))))
    (princ (format \"user-init-file: %s\ncustom-file:    %s\nevil-mode:      %s\ndenote:         %s\ncitar:          %s\n--- *Warnings* ---\n%s\n\"
                   (nth 0 r) (nth 1 r) (nth 2 r) (nth 3 r) (nth 4 r) (nth 5 r)))
    (server-eval-at \"${server}\" '(kill-emacs))
    (unless (equal (nth 0 r) \"${PROFILE_DIR}/init.el\")
      (kill-emacs 3))))" || rc=$?

	echo "--- daemon log ---"
	cat "${tmp_home}/daemon.log"
	(( rc == 3 )) && die "user-init-file is not ${PROFILE_DIR}/init.el; run is void"
	return "${rc}"
}

case "${1:-}" in
	--check)
		check_boot
		;;
	--nw|--tty)
		guard_dot_emacs "${HOME}"
		exec "${EMACS_BIN}" --init-directory "${PROFILE_DIR}" -nw
		;;
	--debug)
		guard_dot_emacs "${HOME}"
		exec "${EMACS_BIN}" --init-directory "${PROFILE_DIR}" --debug-init
		;;
	*)
		guard_dot_emacs "${HOME}"
		exec "${EMACS_BIN}" --init-directory "${PROFILE_DIR}" "$@"
		;;
esac
