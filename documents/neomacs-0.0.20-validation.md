# Neomacs 0.0.20 validation — 2026-10-25

## Artifact and scope

- Release: <https://github.com/eval-exec/neomacs/releases/tag/v0.0.20>, published 2026-10-24 21:57:55 UTC.
- Linux x86_64 AppImage SHA-256: `d703aa8eb68e4ae84a4664234abbd1f5ca85abe62624d0464d22c00761d26336`; local download matched GitHub's asset digest.
- Host: NixOS, GNU Emacs 31.1. Neomacs still reports `emacs-version` as `31.1`; `(fboundp 'neomacs-core-backend)` is non-nil.
- Existing pinned-by-install package sources were retained. No archive refresh, full package reinstall, or GNU package changes. Casual and gptel were rebuilt with 0.0.20 after isolated verification.
- GUI startup uses Xvfb, not the user's display. Ad-hoc probes use `-Q`, disposable HOME, `timeout --signal=KILL`, and exit with `kill-emacs-hook` nil. D-Bus probes use `dbus-run-session`.

## Measurements

### Startup

Before workaround removal, GNU and Neomacs both passed `check`: correct `user-init-file`, empty warnings, no minibuffer prompt, Evil/Denote/Citar loaded, `<f1>` bound to `casual-editkit-main-tmenu`. Init times were 4.65s and 1.31s respectively (one run, not a benchmark).

After removing both workarounds and rebuilding the local Casual/gptel bytecode, `./run.sh check-all` passed again:

```text
GNU 31.1: init-time 3.917173s, warnings empty, <f1> casual-editkit-main-tmenu
Neomacs 0.0.20: init-time 1.125848s, warnings empty, <f1> casual-editkit-main-tmenu
summary: gnu: rc=0 / neo: rc=0
```

These times are single startup observations, not comparative performance claims. Xvfb emits XRandR/DRI3 warnings outside Emacs's `*Warnings*`; these do not establish a real-display rendering failure.

### Org table: still divergent

With Org loaded, insert and align:

```org
| a | [[https://example.com][설명]] |
| bb | x |
```

Neomacs 0.0.20 still produces a second row of 38 characters. Keep the once-per-buffer warning. The GNU 13-character comparison is inherited from the 0.0.19 investigation, not freshly remeasured here.

### D-Bus / EMMS: workaround retired

Without loading `neomacs.el`, with EMMS 20260414.1505 on a private bus:

```elisp
(require 'emms-mpris)
(dbus-register-service :session "org.mpris.MediaPlayer2.neo020probe")
;; => :primary-owner
(emms-mpris-register-iface emms-mpris-player-iface-spec)
;; => nil, without panic
(emms-mpris-enable)
;; completed without error
```

Removed the `emms-mpris-enable` override. Relevant upstream changes: PRs [444](https://github.com/eval-exec/neomacs/pull/444) and [513](https://github.com/eval-exec/neomacs/pull/513). This verifies registration, not physical desktop media keys or playback.

### Bytecode: rebuild required, source-only workaround retired

Copied the complete Neomacs package directory into a disposable HOME. Recompiled Casual 20260831.2129: 109 files. A broad load audit then reported 586 successes and five failures:

- Four optional Evil Collection integrations lacked their target packages/API (`lispy`, `magit`, two `mu4e` integrations); these are not established runtime regressions.
- Existing `gptel-rewrite.elc` failed with `(void-variable lambda)`.

Next, recompiled both Casual (109 files) and gptel 20260925.357 (18 files) in the copy, then launched a **separate fresh process** against that copy:

```text
FRESH-BYTECODE-AUDIT ok=127 failures=0
```

Removed Casual's package compilation skip and automatic `.elc` deletion. Rebuilt those same two packages locally. Do not reuse 0.0.19 bytecode as evidence about the new compiler. The remainder of the package directory was not freshly recompiled; the broad load audit is not a claim of full package functionality.

### Headless named daemon: supported

With `DISPLAY` and `WAYLAND_DISPLAY` unset, disposable HOME, and no profile:

```text
-Q --fg-daemon=neo020-probe
```

A one-second Lisp timer wrote this receipt and exited normally:

```elisp
(:daemon "neo020-probe" :display nil)
```

This retires the old blanket statement that a named daemon cannot start headlessly. It does not test client attachment, full-profile daemon startup, or GUI frame attachment. Keep `check` on Xvfb: it intentionally exercises GUI startup.

## Memory reporting: allocation counters mistaken for live storage

The user reported `memory-report` showing 622 MiB overall (400 MiB strings, 145 MiB conses, 61 MiB symbols), versus 127 MiB in the main GNU Emacs setup. Those two reports are not directly comparable.

Source at tag v0.0.20:

- `lisp/emacs-lisp/memory-report.el:111-142` calculates overall storage by multiplying the sizes and used counts returned by `garbage-collect`; it already invokes GC.
- `crates/neovm-core/src/emacs_core/lisp/native/builtins_extra/mod.rs:802-823` builds that response from `Value::memory_use_counts_snapshot()`, uses fixed GNU-style size constants, hardcodes unused counts to zero, and reports zero buffer objects.
- `crates/neovm-core/src/tagged/gc.rs:1413-1434` identifies these as Lisp-visible allocation counters, incremented as objects are handed out, not a live-object census.
- The separate `neomacs--heap-layout-stats` primitive reports arena occupancy and known payload capacities; its own documentation says to pair it with OS RSS/PSS because it does not cover all process memory.

Measured in isolated `-Q` processes: hold 100,000 conses and a 10,000,000-byte string, clear the sole global reference, then collect again.

| Observation | Held | Released + GC |
|---|---:|---:|
| GNU `garbage-collect` string-bytes | 10,048,636 | 48,640 |
| Neomacs `garbage-collect` string-bytes, first run | 10,072,197 | 10,072,313 |
| Neomacs heap known payload capacity, second run | 10,319,535 | 319,543 |
| Neomacs heap cons live slots, second run | 102,340 | 2,380 |

Thus actual test allocations were reclaimed while compatibility reporting kept their allocation counts. Repeated reporting also allocates objects and can increase these counters. This establishes a reporting-semantics mismatch, not a leak or proof that a 622 MiB live heap is structurally necessary. `0 B` unused storage / buffer objects is a placeholder here, not a measured absence. Image cache coverage was not investigated.

Actual memory overhead remains a separate question: compare RSS/PSS and heap-layout stats after equivalent workloads on this profile under both runtimes. GPU, JIT, font caches, allocator retention and other Rust-side structures are not established causes of the reported number by this experiment. No live user-session process was queried or modified. Scratch source and probe: `/tmp/neo020-memory/`.

## Release gate

On 2026-10-25, `./run.sh check-all` was rerun before v2026.10.25: GNU 31.1 rc=0, Neomacs 0.0.20 rc=0, empty startup warnings and the expected Casual `<f1>` binding. Basic GUI operation was confirmed by the user; this does not certify each item below.

## Remaining manual checks

- Real GUI: Korean composition, CJK font widths/fallback, cursor and disabled effects, menu/tool bars, Casual navigation.
- EMMS playback and physical media keys.
- Cursor glyph diagnostic suppression was not re-audited and remains unchanged.

## Local receipts

Host-local scratch (not portable evidence): `/tmp/agent-tmux-neo020-check.log`, `/tmp/agent-tmux-neo020-probes.log`, `/tmp/agent-tmux-neo020-bytecode.log`, `/tmp/agent-tmux-neo020-recompile.log`, `/tmp/neo020-daemon.eld`, `/tmp/agent-tmux-neo020-final.log`. Decisive results are copied above so the report survives scratch cleanup.
