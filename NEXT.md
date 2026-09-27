# NEXT.md — neomacs-config (구 ews-config)

> 운영 baseline은 [AGENTS.md](AGENTS.md). 다음 한 걸음만 여기에.
> 문서 언어: `AGENTS.md` / `README.md`는 영어(공개 리포), 이 NEXT는 한국어.

# RAIL — 현재 좌표

- [x] **1. upstream EWS 동기화** (2026-09-26) — 머지 커밋 `66ced42`. 이후 EWS는
      **분기**: 진짜 버그 수정만 cherry-pick (GLG 2026-09-27)
- [x] **2. GNU Emacs 31.1 헤드리스 green** (2026-09-26)
- [x] **3. 리포 재건** (2026-09-26) — GLG GUI 실사용 "잘 된다"
- [x] **4. 이름 변경** (2026-09-27) — GitHub·`origin`·로컬 경로 모두 `neomacs-config`
- [ ] **5. Neomacs 커버** ← CURRENT: 헤드리스 green 양쪽. GLG GUI 판정 대기
- [ ] **6. 메인 전환 + 범용 샘플화** — GLG가 이 리포를 메인으로 쓴다(Casual 기본).
      자리잡으면 GLG 층을 영어로, 사용자 가이드. doomemacs-config는 레퍼런스일 뿐

## NOW

- **다음 한 걸음: GLG GUI 판정** — `./run.sh neo`와 `./run.sh`를 나란히 띄워 본다.
  볼 것: `<f1>` Casual 메뉴, 한글 입력(`S-SPC`), 폰트, 메뉴바(`menu-bar-mode -1`이
  Neomacs에서 먹는지), 커서.
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
| — | 패키지 설치 중 D-Bus panic 2회 관측 (1회 종료, 1회 비치명) | 첫 설치 로그 | 원인 미확정, 재설치 시 재관측 |

- Neomacs 버전을 올리면: `elpa-neomacs/` 지우고 `./run.sh neo check`, 그리고 `.elc`
  전수 점검을 다시.

## GLG가 정할 것

- **Neomacs 검수 기록의 주인.** 제안: 설정 축(ELPA·GUI·일상)은 이 리포,
  맨몸 축(빌트인·프로브)은 `doomemacs-config/neomacs/`.
- **doomemacs-config 쪽 발견 전달 여부:** 그쪽 `neomacs/init.el:37`의 `my/neomacs-p`는
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
