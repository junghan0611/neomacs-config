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

- **`v2026.9.27` 컷** — 닫힌 일은 [CHANGELOG.md](CHANGELOG.md)로 옮겼다.
- **다음 한 걸음: RAIL 6 준비** — EWS 불필요 패키지 정리(GLG가 목록을 본다). 방침:
  어설프게 화려한 것·폰트 이것저것은 이 리포에서 하지 않는다.
- baseline: `./run.sh check-all` gnu rc=0 / neo rc=0, `<f1>` = `casual-editkit-main-tmenu`,
  테마 `modus-operandi-tinted`, org에 mixed-pitch·org-modern 없음 (2026-09-27).

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

## 이웃과의 경계 (2026-09-27)

- doomemacs-config 담당자(`20260927T150410-da86cf`)에게 전달 완료: 검수 주인 이관,
  `my/neomacs-p` 항상 nil, `--daemon=NAME` 거부, `~/doomemacs/eln-cache/`(31M) 전부 우리 것.
  그쪽 회신: `neomacs/init.el`을 `fboundp neomacs-core-backend`로, `bin/neomacs.sh`
  `--daemon`/`--kill`은 fail-closed, AGENTS·README에 주인 이관 반영 — **그쪽 미커밋**.
  eln-cache 삭제는 그쪽 판단.
- 담당자 문서: Denote `20260529T084444` (AGENTS.md "Steward note"). 컷·경계가 바뀌면 갱신.

## 다듬을 후보

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
