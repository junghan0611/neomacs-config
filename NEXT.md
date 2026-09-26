# NEXT.md — neomacs-config (구 ews-config)

> 운영 baseline은 [AGENTS.md](AGENTS.md). 다음 한 걸음만 여기에.
> 문서 언어: `AGENTS.md` / `README.md`는 영어(공개 리포), 이 NEXT는 한국어.

# RAIL — 현재 좌표

- [x] **1. upstream EWS 동기화** (2026-09-26) — `upstream` 리모트 추가, 79 behind / 3 ahead
      실측, `git merge --no-commit upstream/master`, `init.el` 충돌 1건 해결
- [x] **2. GNU Emacs 31.1 헤드리스 green** (2026-09-26) — `./bin/ews.sh --check`:
      `user-init-file` = 이 리포 `init.el`, `*Warnings*` 비어 있음, rc=0
- [ ] **3. 리포 재건** ← CURRENT: GLG GUI 실사용 → 다듬기 → 머지 커밋 → 문서 정리
- [~] **4. 이름 변경 `ews-config` → `neomacs-config`** — GitHub rename 완료, `origin`
      갱신(2026-09-26). 로컬 디렉토리 이동과 런처 이름은 남음
- [ ] **5. Neomacs 커버**

## NOW

- **다음 한 걸음: 로컬 경로 `~/repos/gh/ews-config` → `~/repos/gh/neomacs-config`.**
  GLG가 실행. Emacs 종료 → `mv` → `elpa/` 지우고 `./bin/ews.sh --check`로 재설치·green 확인.
- GUI 실사용 판정: "잘 된다"(GLG, 2026-09-26). upstream 머지 + 재건은 머지 커밋으로 푸시됨.
- 이번 세션에서 바뀐 것: `evil.el` 재정리(`hs-minor-mode-map nil` 제거 — Emacs 31 설치
  파괴 원인, 중복 setq 정리, Doom `defadvice!` → `advice-add`, undo-fu → 내장
  `undo-redo`), `extra.el` 재정리(GLG가 webpaste·google-translate·UI 덮어쓰기 제거,
  `line-spacing` 중복 제거, `lisp/` load-path), `lisp/casual-config.el` Doom → 순정
  이식(`<f1>` = `casual-editkit-main-tmenu` 실측). 신규 `early-init.el` / `user-info.el` /
  `bin/ews.sh` / `AGENTS.md` / `CLAUDE.md`, `README.md` 재작성.
- 마지막 `--check`: rc=0, `*Warnings*` 비어 있음 (2026-09-26).

## 다듬을 후보 (GLG 실사용 피드백 대기)

- `elpa/undo-fu-*`, `elpa/casual-suite-*`, webpaste, google-translate 는 더 안 쓴다.
  `elpa/` 정리는 이름 변경 때 재설치로 같이.
- 맞춤법: `ews-hunspell-dictionaries` = `ko_KR` (기기에 설치된 유일한 사전). 영문 사전을
  원하면 `nixos-config` 레인에서 `en_US` 추가가 먼저.
- EWS 외부 도구 누락: `ddjvu`, `pdftotext` (기동 로그 `Missing executable files`).
- 리포 루트에 생기는 상태 파일(`emms/`, `history`, `bookmarks` 등)이 `.gitignore`에
  다 걸리는지 GUI 사용 후 `git status`로 확인.
- `origin/master`, `origin/oldwin` 옛 브랜치 정리 여부.

## 4단계 — 이름 변경 시 주의

- GitHub rename은 끝. 로컬 디렉토리 이동은 GLG가 실행 시점을 정한다.
- 실행 중인 Emacs가 이 디렉토리를 `--init-directory`로 쓰고 있으면 이동 전에 종료.
- `elpa/` 안 `.elc` / autoload는 절대경로를 품으므로 이동 후 `elpa/` 재설치가 안전.
- `README.md` / `AGENTS.md` 이름은 갱신됨. `bin/ews.sh` 런처 이름은 남음.

## 5단계 — Neomacs (지금은 보류, 재건 후)

- 출발점: `~/repos/gh/doomemacs-config/neomacs/` 프로파일과 `bin/neomacs.sh`.
  그쪽 로직(AppImage 러너 해석, 폰트 명시 설정, 배치 프로브)을 이 리포로 가져오는 방향.
  측정 SSOT는 `doomemacs-config/neomacs/README.md`. 문의는 doomemacs-config 담당자.
- `elpa/`를 런타임별로 분리할지 결정 (GNU/Neomacs가 같은 `.elc`를 공유하면 안 될 수 있음).
- GNU에서 green인 것만 Neomacs로 넘긴다 — 갈라짐 귀속을 위해.
