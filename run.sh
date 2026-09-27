#!/usr/bin/env bash
# run.sh — launch and check this profile on GNU Emacs or Neomacs.
#
# The profile is run as an isolated --init-directory, so it never touches
# ~/.emacs.d or any other Emacs setup.  The same profile runs on two
# runtimes; comparing them is how a problem gets attributed to Neomacs
# rather than to this config.
#
# Usage:
#   ./run.sh [RUNTIME] [ACTION] [emacs args...]
#
#   RUNTIME   gnu (default) | neo
#   ACTION    gui (default) | nw | debug | check | version
#
#   ./run.sh                   # GUI on GNU Emacs
#   ./run.sh nw                # terminal on GNU Emacs
#   ./run.sh neo               # GUI on Neomacs
#   ./run.sh neo check         # boot check on Neomacs
#   ./run.sh check-all         # boot check on both runtimes, then a summary
#   ./run.sh fetch [TAG]       # download a Neomacs release AppImage (needs gh)
#
# Runtime binaries:
#   EMACS_BIN=<path>           GNU Emacs binary (default: emacs on PATH)
#   NEOMACS_BIN=<path>         Neomacs binary; otherwise `neomacs` on PATH,
#                              otherwise the release AppImage via appimage-run
#   NEOMACS_VERSION=0.0.19     AppImage version to look for / fetch
#   CHECK_TIMEOUT=900          seconds before a check is declared hung
#
# check boots the real GUI startup path (early-init.el, init.el) on a
# virtual display (Xvfb) under a throwaway HOME, writes a report once
# startup has gone idle, and exits without running kill-emacs-hook.  It is
# green only when user-init-file is this repository's init.el and
# *Warnings* is empty.  A run whose user-init-file is anything else is void.

set -euo pipefail

PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EMACS_BIN="${EMACS_BIN:-emacs}"
NEOMACS_VERSION="${NEOMACS_VERSION:-0.0.19}"
APPIMAGE_DIR="${NEOMACS_APPIMAGE_DIR:-$HOME/.local/bin}"
APPIMAGE="${APPIMAGE_DIR}/neomacs-${NEOMACS_VERSION}-x86_64-unknown-linux-gnu.AppImage"
CHECK_TIMEOUT="${CHECK_TIMEOUT:-900}"

# Profile state that a check must leave exactly as it found it.
STATE_FILES=(recentf.eld history bookmarks)

die() { echo "[run] $*" >&2; exit 1; }

usage() { sed -n '2,33p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

# ~/.emacs and friends take precedence over <init-directory>/init.el, so
# their presence means this profile would silently not load.
guard_dot_emacs() {
	local home="$1" f
	for f in .emacs .emacs.el .emacs.elc; do
		[[ -e "${home}/${f}" ]] && die "${home}/${f} exists and would shadow ${PROFILE_DIR}/init.el; move it away first"
	done
	return 0
}

# Sets RUNNER (array) and RUNTIME_LABEL for the requested runtime.
resolve_runner() {
	case "$1" in
		gnu)
			RUNNER=("${EMACS_BIN}")
			RUNTIME_LABEL="gnu"
			;;
		neo)
			RUNTIME_LABEL="neo"
			if [[ -n "${NEOMACS_BIN:-}" ]]; then
				RUNNER=("${NEOMACS_BIN}")
			elif command -v neomacs >/dev/null 2>&1; then
				RUNNER=(neomacs)
			elif [[ -x "${APPIMAGE}" ]]; then
				# The release AppImage links libfontconfig et al. at paths NixOS
				# does not provide; appimage-run supplies an FHS environment.
				if command -v appimage-run >/dev/null 2>&1; then
					RUNNER=(appimage-run "${APPIMAGE}")
				else
					RUNNER=(nix run nixpkgs#appimage-run -- "${APPIMAGE}")
				fi
			else
				die "no Neomacs found (NEOMACS_BIN, neomacs on PATH, ${APPIMAGE}). Run: $0 fetch"
			fi
			# Bypass the toolkit IME (fcitx5 etc.) so Korean input is Neomacs'
			# own builtin Hangul composition; a finding is then never
			# confounded by the IME bridge.
			export GTK_IM_MODULE=emacs XMODIFIERS=@im=emacs
			;;
		*)
			die "unknown runtime: $1 (gnu | neo)"
			;;
	esac
}

fetch_appimage() {
	local tag="${1:-v${NEOMACS_VERSION}}"
	command -v gh >/dev/null 2>&1 || die "gh CLI required for fetch"
	mkdir -p "${APPIMAGE_DIR}"
	echo "[run] downloading Neomacs ${tag} AppImage to ${APPIMAGE_DIR}"
	(cd "${APPIMAGE_DIR}" &&
		gh release download "${tag}" --repo eval-exec/neomacs \
			--pattern "*x86_64-unknown-linux-gnu.AppImage" --clobber)
	chmod +x "${APPIMAGE_DIR}"/neomacs-*.AppImage
	ls -lh "${APPIMAGE_DIR}"/neomacs-*.AppImage
}

TMP_HOME=""
XVFB_PID=""
cleanup() {
	[[ -n "${XVFB_PID}" ]] && kill "${XVFB_PID}" 2>/dev/null
	[[ -n "${TMP_HOME}" ]] && rm -rf "${TMP_HOME}"
	return 0
}
trap cleanup EXIT

# Start Xvfb on a free display and set CHECK_DISPLAY.  A check must never
# put a window on the user's screen: Neomacs 0.0.19 cannot start without a
# display at all, and rejects --daemon=NAME and carries on as a normal GUI
# session, so a daemon-based check is not headless there.
start_xvfb() {
	command -v Xvfb >/dev/null 2>&1 ||
		die "check needs Xvfb (a virtual display, so no window reaches your screen)"
	local n
	for n in $(seq 90 130); do
		[[ -e "/tmp/.X11-unix/X${n}" || -e "/tmp/.X${n}-lock" ]] || break
	done
	Xvfb ":${n}" -screen 0 1600x1000x24 -nolisten tcp >/dev/null 2>&1 &
	XVFB_PID=$!
	for _ in $(seq 50); do
		[[ -S "/tmp/.X11-unix/X${n}" ]] && break
		sleep 0.1
	done
	[[ -S "/tmp/.X11-unix/X${n}" ]] || die "Xvfb :${n} did not come up"
	CHECK_DISPLAY=":${n}"
}

# Boot check.  Exit status: 0 green, 3 user-init-file mismatch (run is
# void), 4 *Warnings* not empty, anything else = startup failed or hung.
check_boot() {
	local tmp_home rc=0 f
	tmp_home="$(mktemp -d -t neomacs-config-home.XXXXXX)"
	TMP_HOME="${tmp_home}"
	local report="${tmp_home}/report.eld" log="${tmp_home}/emacs.log"

	echo "[run] runtime: ${RUNTIME_LABEL} — $("${RUNNER[@]}" --version 2>/dev/null | grep -v 'installed in' | head -1)"
	echo "[run] profile: ${PROFILE_DIR}"
	echo "[run] HOME:    ${tmp_home}"

	# HOME is throwaway but this profile's state files are the user's real
	# ones.  Exiting without kill-emacs-hook keeps recentf and friends from
	# saving; the snapshot also covers timers (savehist autosaves every 5
	# minutes, and a first run that installs packages takes longer).
	mkdir -p "${tmp_home}/state"
	for f in "${STATE_FILES[@]}"; do
		[[ -e "${PROFILE_DIR}/${f}" ]] && cp -p "${PROFILE_DIR}/${f}" "${tmp_home}/state/"
	done

	start_xvfb

	# Runs once startup has gone idle.  Idle timers also fire inside a
	# minibuffer prompt, so a startup stuck on a question is reported with
	# that question instead of hanging until the timeout.
	local report_form="
(run-with-idle-timer
 2 nil
 (lambda ()
   (with-temp-file \"${report}\"
     (let ((print-length nil) (print-level nil))
       (prin1 (list user-init-file custom-file package-user-dir
                    (bound-and-true-p my/neomacs-p)
                    (bound-and-true-p evil-mode)
                    (featurep 'denote) (featurep 'citar)
                    (and (active-minibuffer-window)
                         (with-current-buffer (window-buffer (active-minibuffer-window))
                           (buffer-string)))
                    (with-current-buffer (get-buffer-create \"*Warnings*\")
                      (buffer-substring-no-properties (point-min) (point-max)))
                    (key-binding (kbd \"<f1>\"))
                    (emacs-init-time))
              (current-buffer))))
   (let ((kill-emacs-hook nil))
     (kill-emacs 0))))"

	DISPLAY="${CHECK_DISPLAY}" WAYLAND_DISPLAY="" \
		HOME="${tmp_home}" XDG_CONFIG_HOME="${tmp_home}/.config" \
		XDG_CACHE_HOME="${tmp_home}/.cache" XDG_DATA_HOME="${tmp_home}/.local/share" \
		timeout --signal=KILL "${CHECK_TIMEOUT}" \
		"${RUNNER[@]}" --init-directory "${PROFILE_DIR}" --eval "${report_form}" \
		>"${log}" 2>&1 || rc=$?

	kill "${XVFB_PID}" 2>/dev/null
	XVFB_PID=""
	for f in "${STATE_FILES[@]}"; do
		if [[ -e "${tmp_home}/state/${f}" ]]; then
			cmp -s "${tmp_home}/state/${f}" "${PROFILE_DIR}/${f}" ||
				cp -p "${tmp_home}/state/${f}" "${PROFILE_DIR}/${f}"
		else
			rm -f "${PROFILE_DIR}/${f}"
		fi
	done

	if [[ ! -s "${report}" ]]; then
		# Neomacs can log a line per frame; show only the tail.
		echo "--- emacs log (last 40 of $(wc -l <"${log}") lines) ---"
		tail -n 40 "${log}" | cut -c1-300
		((rc == 137)) && echo "[run] ${RUNTIME_LABEL}: no report after ${CHECK_TIMEOUT}s; killed" >&2
		echo "[run] ${RUNTIME_LABEL}: startup produced no report (rc=${rc})" >&2
		return $((rc == 0 ? 1 : rc))
	fi

	rc=0
	"${EMACS_BIN}" --batch --eval "
(let ((r (with-temp-buffer (insert-file-contents \"${report}\") (read (current-buffer)))))
  (princ (format \"user-init-file:   %s\ncustom-file:      %s\npackage-user-dir: %s\nmy/neomacs-p:     %s\nevil-mode:        %s\ndenote:           %s\ncitar:            %s\n<f1>:             %s\ninit-time:        %s\nminibuffer:       %s\n--- *Warnings* ---\n%s\n\"
                 (nth 0 r) (nth 1 r) (nth 2 r) (nth 3 r) (nth 4 r) (nth 5 r) (nth 6 r)
                 (nth 9 r) (nth 10 r) (or (nth 7 r) \"(none)\") (nth 8 r)))
  (cond ((not (equal (nth 0 r) \"${PROFILE_DIR}/init.el\")) (kill-emacs 3))
        ((not (string-empty-p (string-trim (nth 8 r)))) (kill-emacs 4))))" 2>/dev/null || rc=$?

	echo "--- emacs log ($(wc -l <"${log}") lines; first 30 without GTK/gio noise) ---"
	grep -avE 'gio/modules|Failed to load module|cursor_glyph_mismatch' "${log}" | head -n 30 | cut -c1-300 || true
	case "${rc}" in
		0) echo "[run] ${RUNTIME_LABEL}: green" ;;
		3) echo "[run] ${RUNTIME_LABEL}: user-init-file is not ${PROFILE_DIR}/init.el; run is void" >&2 ;;
		4) echo "[run] ${RUNTIME_LABEL}: *Warnings* is not empty" >&2 ;;
		*) echo "[run] ${RUNTIME_LABEL}: could not read the report (rc=${rc})" >&2 ;;
	esac
	rm -rf "${tmp_home}"
	TMP_HOME=""
	return "${rc}"
}

check_all() {
	local rt rc summary=()
	for rt in gnu neo; do
		echo
		echo "########## ${rt} ##########"
		rc=0
		(resolve_runner "${rt}" && check_boot) || rc=$?
		summary+=("${rt}: rc=${rc}")
	done
	echo
	echo "########## summary ##########"
	printf '  %s\n' "${summary[@]}"
	[[ "${summary[*]}" == "gnu: rc=0 neo: rc=0" ]]
}

RUNTIME="gnu"
case "${1:-}" in
	gnu | neo)
		RUNTIME="$1"
		shift
		;;
esac
ACTION="${1:-gui}"
[[ $# -gt 0 ]] && shift

case "${ACTION}" in
	-h | --help | help)
		usage
		exit 0
		;;
	fetch)
		fetch_appimage "${1:-}"
		exit 0
		;;
	check-all)
		check_all
		exit $?
		;;
esac

resolve_runner "${RUNTIME}"

case "${ACTION}" in
	check)
		check_boot
		;;
	version)
		"${RUNNER[@]}" --version 2>/dev/null | grep -v 'installed in'
		;;
	nw | tty)
		guard_dot_emacs "${HOME}"
		exec "${RUNNER[@]}" --init-directory "${PROFILE_DIR}" -nw "$@"
		;;
	debug)
		guard_dot_emacs "${HOME}"
		exec "${RUNNER[@]}" --init-directory "${PROFILE_DIR}" --debug-init "$@"
		;;
	gui)
		guard_dot_emacs "${HOME}"
		exec "${RUNNER[@]}" --init-directory "${PROFILE_DIR}" "$@"
		;;
	*)
		die "unknown action: ${ACTION} (see $0 help)"
		;;
esac
