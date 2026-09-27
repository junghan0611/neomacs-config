# NEXT.md — neomacs-config (구 ews-config)

> 운영 baseline은 [AGENTS.md](AGENTS.md). 다음 한 걸음만 여기에.
> 문서 언어: `AGENTS.md` / `README.md`는 영어(공개 리포), 이 NEXT는 한국어.

# RAIL — 현재 좌표

- [x] **1. upstream EWS 동기화** (2026-09-26) — 머지 커밋 `66ced42`. 이후 EWS는
      **분기**: 진짜 버그 수정만 cherry-pick (GLG 2026-09-27)
- [x] **2. GNU Emacs 31.1 헤드리스 green** (2026-09-26)
- [x] **3. 리포 재건** (2026-09-26) — GLG GUI 실사용 "잘 된다"
- [x] **4. 이름 변경** (2026-09-27) — GitHub·`origin`·로컬 경로 모두 `neomacs-config`
- [x] **5. Neomacs 커버** (2026-09-27) — 헤드리스 green 양쪽, GLG GUI 판정 "둘 다
      동작은 잘 된다". **Neomacs 검수의 주인은 이 리포** (GLG)
- [ ] **6. 메인 전환 + 범용 샘플화** — GLG가 이 리포를 메인으로 쓴다(Casual 기본).
      자리잡으면 GLG 층을 영어로, 사용자 가이드. doomemacs-config는 레퍼런스일 뿐

## NOW

- `./run.sh neo` 터미널 소음 제거 — `RUST_LOG`로 커서 진단(갈라짐 7) 끄기, AppImage일 때
  `GIO_EXTRA_MODULES` 해제. GLG 실화면 확인 "좋다".
- **덜어내기 (GLG 방침: 어설프게 화려한 것·폰트 이것저것은 여기서 안 한다):**
  org의 `mixed-pitch-mode`·`org-modern-mode` 자동 켜기 제거(`init.el`, 패키지는 남김),
  `extra.el` 마지막에 `(modus-themes-toggle)` → `modus-operandi-tinted`. 양쪽 실측 일치.
- 마지막 `./run.sh check-all` (2026-09-27): gnu rc=0 / neo rc=0. 둘 다 `<f1>` =
  `casual-editkit-main-tmenu`, `*Warnings*` 비어 있음. init-time gnu 3.87s / neo 1.32s
  (neo는 native-comp 없음, 같은 비교 아님). 실행 뒤 `recentf.eld`·`history` 동일.
- 이번에 바뀐 것: `run.sh`(Xvfb 기반 check, 상태 파일 보호), `my/neomacs-p`,
  `elpa-neomacs/`, `neomacs.el`, eln-cache를 프로파일 안으로, Casual 즉시 로드,
  EWS 분기 방침을 AGENTS/README에.

## Neomacs 갈라짐 (이 리포 실측, Neomacs 0.0.19 vs GNU 31.1)

upstream 보고는 하지 않는다 (GLG). 우회는 `neomacs.el`에만.

| # | 무엇 | 재현 | 상태 |
|---|---|---|---|
| 1 | `emacs-version`이 `"GNU Emacs 31.1 …"` — 식별 불가 (0.0.13도 동일) | `--batch --eval '(princ (emacs-version))'` | `(fboundp 'neomacs-core-backend)` |
| 2 | org 표 안 링크를 원시 폭으로 정렬 | `-Q`, org 9.8.7: 둘째 행 GNU 13자 / Neomacs 38자 | 버퍼당 1회 경고 |
| 3 | EMMS MPRIS Player 인터페이스 D-Bus 등록 → panic, 프로세스 종료 (`dbus-0.9.11 strings.rs:187 "Unknown typecode"`) | `-Q -L <emms>`로 `(emms-mpris-register-iface emms-mpris-player-iface-spec)` | `emms-mpris-enable` 무력화 |
| 4 | `dbus-register-service` → `"Not a valid D-Bus event"` | `(dbus-register-service :session "org.mpris.MediaPlayer2.x")` | 기록만 |
| 5 | `--daemon=NAME` → `Unknown option`, GUI로 계속. 디스플레이 없으면 기동 불가 | 기동 로그 | `check`를 Xvfb로 |
| 6 | Neomacs가 컴파일한 casual `.elc` 7개 로드 실패 `(void-variable lambda)`, `.el`은 정상. 전수 점검: 다른 `.elc` 337개는 정상 | `elpa-neomacs/`의 모든 `.elc` `require` | casual만 컴파일 생략 + `.elc` 삭제 |
| 7 | 렌더러 진단 `cursor_glyph_mismatch`가 다시 그릴 때마다 ERROR — `line-spacing`이 있으면 커서(글자 높이)와 cell(줄 간격 포함)이 어긋남. 화면상 문제 없음 | `-Q`, 문자 위 커서: `line-spacing` nil 0건 / 3 → 5초에 7건, `cursor=…9.0x22.0 cell=…9.0x25.0` | `run.sh`가 `RUST_LOG=…glyphs=off` |
| — | 패키지 설치 중 D-Bus panic 2회 관측 (1회 종료, 1회 비치명) | 첫 설치 로그 | 원인 미확정, 재설치 시 재관측 |

- Neomacs 버전을 올리면: `elpa-neomacs/` 지우고 `./run.sh neo check`, 그리고 `.elc`
  전수 점검을 다시.

## GLG가 정할 것

- **doomemacs-config 쪽에 알릴지:** Neomacs 주인이 이 리포가 됐다는 것(그쪽
  `neomacs/README.md`가 아직 측정 SSOT를 자처). 그리고 그쪽 `neomacs/init.el:37`의 `my/neomacs-p`는
  `(emacs-version)`에서 "neomacs"를 찾는데 0.0.13·0.0.19 모두 없어 항상 nil.
  담당자 `20260926T171827-7d0a7f`. 이 리포에서는 손대지 않는다.

## 다듬을 후보

- **EWS 불필요 패키지 정리** — GLG가 보고 있음, 아직 손대지 않는다.
- 이 프로파일이 예전에 native-compile한 `.eln`이 `~/.config/emacs/eln-cache/`(Doom 쪽)에
  남아 있다. 해는 없고, Doom 것과 섞여 있어 지우지 않았다.
- `.ignore`(GLG): rg 실측 — 리포 안·부모 디렉토리 검색 모두 `.gitignore`가 이미
  `elpa/`·`elfeed/`를 거른다. `.ignore`는 `--no-ignore-vcs`나 git 밖 복사본에서만
  효과가 있고, 그땐 `backups/`·`custom.el`·`elpa-neomacs/`·`eln-cache/`가 샌다.
- `check`는 idle 2초에 보고 — 지연 로드는 안 본다. Casual은 이제 즉시 로드라 잡힌다.
- 맞춤법: `ews-hunspell-dictionaries` = `ko_KR`. 영문 사전은 `nixos-config` 레인 먼저.
- EWS 외부 도구 누락: `ddjvu`, `pdftotext`. `ews.el`의 `if-let` obsolete(31.1).
- `custom.el`의 `package-selected-packages`에 안 쓰는 패키지(undo-fu, webpaste,
  google-translate, casual-suite) 잔존.
- `origin/master`, `origin/oldwin` 옛 브랜치 정리 여부.
