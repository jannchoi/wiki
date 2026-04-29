---
topic: app
created: 2026-04-28
updated: 2026-04-28
confidence: high
sources:
  - GN/Myfarm+/action_flow.md
  - GN/Myfarm+/Github Action.md
  - code: .github/workflows/
verified-by: human, verifier
verified-at: 2026-04-28
---

# GitHub Actions CI/CD — 마이팜플러스

## 요약
수동 트리거(`workflow_dispatch`)로 환경/브랜치/CHANGELOG 입력 → Android + iOS 동시 빌드 및 배포.

---

## 워크플로우 구조

```
workflow_dispatch
  입력: 환경(dev/stg/prd), 브랜치, CHANGELOG
  │
  ├─ build_android.yml
  │   ├─ dev/stg: APK → Firebase App Distribution
  │   │   tester: dev(genesisnest-dev)
  │   │           stg(genesisnest-dev, ls-mtron, hivelab)
  │   └─ prd: AAB → Google Play Console (draft)
  │
  └─ build_ios.yml
      └─ all envs: IPA → TestFlight (업로드만, 심사 제출은 수동)
```

---

## CI Runner

- **macos-26-intel** 사용
- 이유: NHN AppGuard CLI가 x86_64 바이너리이기 때문
  ```
  farm_work/scripts/nhn_appguard_cli/android/AppGuard: Mach-O 64-bit executable x86_64
  ```

---

## GitHub Secrets

| Secret                              | 용도                                |
| ----------------------------------- | --------------------------------- |
| `ANDROID_KEYSTORE_BASE64`           | Android 서명 keystore               |
| `ANDROID_KEYSTORE_PASSWORD`         | Keystore 비밀번호 (Key password와 동일값) |
| `ANDROID_KEY_ALIAS`                 | Key alias                         |
| `APP_STORE_CONNECT_API_KEY_P8`      | App Store Connect API 인증          |
| `APP_STORE_CONNECT_ISSUER_ID`       | App Store Connect Issuer          |
| `APP_STORE_CONNECT_KEY_ID`          | App Store Connect Key ID          |
| `DIST_CERT_P12_BASE64`              | iOS 배포 인증서                        |
| `DIST_CERT_P12_PASSWORD`            | 인증서 비밀번호                          |
| `FIREBASE_DEV_SERVICE_ACCOUNT_JSON` | Firebase dev/stg 배포 계정            |
| `FIREBASE_PRD_SERVICE_ACCOUNT_JSON` | Firebase prd Crashlytics 계정       |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`  | Google Play 업로드 계정                |
| `NHN_APPGUARD_APP_KEY`              | NHN AppGuard                      |
| `PROVISION_DEV_BASE64`              | iOS 개발 프로비저닝 프로필                  |
| `PROVISION_PRD_BASE64`              | iOS 배포 프로비저닝 프로필                  |

---

## iOS 코드사이닝 주요 포인트

- **Keychain 사용 이유**: Xcode codesign 도구가 개인키를 파일이 아닌 Keychain에서 찾음
- **dev + prd 프로필 둘 다 설치하는 이유**: `workflow_dispatch` 실행 시 environment 입력값에 관계없이 동일한 step이 실행되기 때문

---

## 미구현 항목 (추후 고려)

- iOS TestFlight 테스터 그룹 자동 배포 (현재 업로드만, 그룹 지정은 App Store Connect API 폴링 필요)
- iOS TestFlight 릴리즈 노트
- Build number 자동 증가

---

## 주의: workflow 파일 위치

실제 수동 배포처럼 `workflow_dispatch`로 실행하려면 workflow 파일이 **default branch(develop)**에 있어야 함.
테스트 시에는 trigger를 `push`로 변경 후 사용.

---

## 관련 페이지
- [[myfarmplus-context|마이팜플러스 프로젝트 컨텍스트]]

## References
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Generating Tokens for API Requests](https://developer.apple.com/documentation/appstoreconnectapi/generating-tokens-for-api-requests)
- [apple-actions/upload-testflight-build](https://github.com/Apple-Actions/upload-testflight-build)
- [r0adkll/upload-google-play](https://github.com/r0adkll/upload-google-play)
- [Firebase App Distribution — Service Account](https://firebase.google.com/docs/app-distribution/authenticate-service-account)
- [Google Play Developer API](https://developers.google.com/android-publisher/getting_started)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
