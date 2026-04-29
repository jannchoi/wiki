---
topic: _shared
created: 2026-04-28
updated: 2026-04-28
confidence: high
sources: [GN/Convention.md, GN/개요.md]
verified-by: human
verified-at: 2026-04-28
---

# 팀 컨벤션

## Git 커밋 컨벤션

### Type

| Type | 의미 |
|---|---|
| `feat` | 새로운 기능 |
| `fix` | 버그 수정 |
| `refactor` | 코드 리팩토링 (기능 변화 없음) |
| `docs` | 문서 변경 |
| `style` | 포매팅, 코드 스타일 변경 |
| `test` | 테스트 코드 |
| `build` | 빌드 시스템이나 의존성 |
| `chore` | 기타 변경 (CI, 설정 파일 등) |
| `perf` | 성능 개선 |

### 예시
```
feat(chat): implement message sending logic
fix(api): handle null userId in request
docs(readme): add setup guide
style: format code with dartfmt
refactor(chat): extract message parser
test(auth): add login unit test
build(android): update gradle version
chore(release): prepare v1.0.0
```

---

## Git 브랜치 전략 (Git Flow)

- 기반 브랜치: `develop`
- 브랜치 이름: `feature/MFP-{JIRA_ID}-{설명}`
  - 영문 소문자 및 숫자, `-`만 사용
  - Jira Issue ID는 대문자 사용
  - 예: `feature/MFP-935-landing-page`

### 작업 흐름
```
develop
  └─ feature/MFP-{ID}-{description}  ← 개발
       └─ (필요 시) feature/MFP-{ID}-{sub-task}  ← 이전 브랜치 미merge 시
```

- 팀장 코드 리뷰 + 승인 후 develop에 merge
- 이전 브랜치에 수정사항 생기면 이후 브랜치에 rebase

### 릴리즈 머지 순서
```bash
git checkout main
git pull origin main
git merge --no-ff release/x.x.x -m "Merge release/x.x.x into main"
git tag -a "myFarm+@x.x.x" -m "Release myFarm+@x.x.x"
git checkout develop
git merge --no-ff main -m "Merge main into develop after x.x.x release"
git push origin main
git push origin "myFarm+@x.x.x"
git push origin develop
git branch -d release/x.x.x
git push origin --delete release/x.x.x
```

---

## 협업 툴

| 툴 | 용도 |
|---|---|
| Jira | 티켓 관리. 작은 이슈도 생성. 현상 → 결과 형식. |
| Confluence | 주간보고 (금주 업무 / 차주 계획 + Jira 링크) |
| Slack | app-dev (개발 공유), 앱개발팀 (팀 이슈), develop (전체 개발) |
| GitHub | 브랜치 관리, PR, 코드 리뷰 |

- 주간 팀 회의: **매주 금요일 오전 11시**
- 회의 전까지 주간보고 작성

---

## 자주 쓰는 git 명령어

```bash
# 브랜치 이름 변경
git branch -m 기존이름 새이름

# 스테이징 취소
git restore --staged

# 업스트림 설정하며 push
git push --set-upstream origin feature/MFP-{ID}-{description}

# amend (커밋 메시지 유지)
git commit --amend --no-edit
```

---

## Firebase Analytics 디버그 모드 (Android)

```bash
# 디버그 모드 시작
adb shell setprop debug.firebase.analytics.app com.lsmtron.mfw.dev

# 디버그 모드 종료
adb -s {device_id} shell setprop debug.firebase.analytics.app .none.
```

---

## Gradle 캐시 삭제

```bash
rm -rf ~/.gradle/caches
rm -rf ~/.gradle/daemon
rm -rf ~/.gradle/notifications
```

---

## 관련 페이지
- [[reliable-references|공식 문서 레퍼런스]]
- [[../app/local/myfarmplus-context|마이팜플러스 프로젝트 컨텍스트]]

