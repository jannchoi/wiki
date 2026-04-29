---
topic: app
created: 2026-04-28
updated: 2026-04-28
confidence: high
sources:
  - raw/app/myfarmplus-tech-stack.md
  - raw/app/myfarmplus-app-architecture.md
  - raw/app/myfarmplus-appbridge-contract.md
  - code: farm_work/lib/src/
verified-by: verifier
verified-at: 2026-04-28
note: "코드 직접 검증 완료. iOS TestFlight 앱 이름만 코드 외 확인 필요."
---

# 마이팜플러스 — 프로젝트 컨텍스트

## 요약
GenesisNest 개발. Flutter + WebView 기반 농업 작업관리 앱. iOS/Android 동시 지원.

---

## 스택

### App
| 항목 | 버전 |
|---|---|
| Dart | 3.6.2 |
| Flutter Framework | 3.27.4 |
| Android 최소 지원 | API 23 (Android 6) |
| iOS 최소 지원 | iOS 15 |

### Server
| 항목 | 버전 |
|---|---|
| Language | Java Corretto 21 |
| Framework | Spring Boot 3.2.X |
| DBMS | MySQL 8.0 |
| Cache | Redis 6.X |
| Infra | Azure Cloud |

### Web
| 항목 | 버전 |
|---|---|
| Language | TypeScript 5 |
| Framework | Next.js 14 / React 18 |
| Runtime Env | Node.js 22 |
| Minimum Support | ES6 (Chrome 64+, Edge 79+, Safari 12+) |

---

## 앱 아키텍처

**핵심 구조**: 3개의 WebView를 `PageView`로 관리. `PageController.jumpToPage()`로 탭 전환, `AutomaticKeepAliveClientMixin`으로 WebView 상태 유지.

```
MainPortalPage
  └─ 하단 탭 3개 (홈 / 작업관리 / 마이페이지)
       └─ PageView (각 탭 = MFWebView, flutter_inappwebview)
            └─ AppBridge로 웹-네이티브 양방향 통신
```

> 참고: 구 "내 작업(`/my-work`)" 탭은 제거됨. 해당 경로로 들어오는 딥링크는 "작업관리(`/work-management`)"로 리다이렉트 처리.

**환경별 URL** (`configs/urls.dart`):
- Development: `https://dev-m.myfarmplus.com`
- Staging: `https://staging-m.myfarmplus.com`
- Production: `https://m.myfarmplus.com`

## 폴더 구조

App root: `farm_work/`, Lib root: `farm_work/lib/src/`

```
lib/src/
├── configs/        # URLs, env config
├── design/         # MFColor, MFTypography (design system)
├── deeplink/       # Deeplink, webview refresh state (ChangeNotifier)
├── enums/          # BottomNavigationTab, etc.
├── extension/      # BuildContext extensions
├── network/        # HTTP client, API classes
├── pages/          # Screen widgets
├── providers/      # ChangeNotifier state management
├── service/        # Business logic singleton services
├── splash/         # App init flow (AppStartUpProvider)
├── storage/        # SharedPreferences wrapper (LocalStorage)
├── utils/          # FlavorUtil, CrashlyticsLogger
├── version/        # Version parsing, update check
├── webview/        # MFWebView, AppBridge, handlers
└── widgets/        # Reusable widgets
```

## 네이밍 컨벤션

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Prefix `MF`: 앱 전용 클래스 (MFColor, MFTypography, MFWebView)
- Pages: `*_page.dart` / `*Page`
- State: `*_provider.dart` / `*Provider` (ChangeNotifier)
- Services: `*_service.dart` / `*Service` (singleton)
- Handlers: `*_handler.dart` / `*Handler` (AppBridge strategy pattern)

---

## WebView & AppBridge

### AppBridge란
웹(JavaScript)과 Flutter(Dart) 간 양방향 통신 레이어.

- **웹 → 앱**: 웹에서 `window.appBridge.{method}()` 호출 → 내부적으로 `webviewMethodChannel.postMessage()` → Flutter `WebMessageListener.onPostMessage()` 수신 → 핸들러로 라우팅
- **앱 → 웹**: Flutter에서 `controller.evaluateJavascript()` 호출 → 웹의 `window.appBridge._invoke*Listener()` 실행

### 주요 파일

| 파일 | 역할 |
|---|---|
| `webview/webview.dart` | MFWebView 위젯, AppBridge 스크립트 주입, SafeArea CSS 주입 |
| `webview/app_bridge/app_bridge_script.dart` | 웹에 주입되는 JS `window.appBridge` 클래스 및 인스턴스 |
| `webview/app_bridge/webview_app_bridge.dart` | Flutter 측 WebMessageListener, 핸들러 라우터 |
| `webview/app_bridge/app_bridge_method_handlers/` | 각 메서드 실제 구현 (strategy pattern) |

### AppBridge 메서드 목록
전체 메서드 계약 → [[myfarmplus-appbridge|AppBridge Method Contract]]

주요 그룹:
- **웹뷰**: `openWebview`, `closeWebview`
- **위치**: `getCurrentPosition`, `setLocationSharing`, `setLocationTracking`, `checkGpsState`, `checkLocationSharingState`, `stopAllLocationTask`
- **권한**: `checkPermission`, `requestPermission`, `openAppSettings`
- **UI**: `setBottomNavigationBarVisibility`, `selectBottomNavigationTab`
- **이벤트**: `addBackPressListener`, `addVisibilityChangeListener`, `notifyUserAction`, `sendLogEvent`
- **기타**: `getMobileInfo`, `getPushToken`, `getContactInfo`, `terminate`, `goTo`, `setWakeLock`

### 이벤트 수집 구조

웹에서 `window.appBridge.sendLogEvent(name, params)` 호출 → Flutter `LogEventHandler` → `FirebaseAnalytics.instance.logEvent()` 직접 기록. 이벤트는 네이티브 Firebase Analytics(GA4) SDK를 통해 수집된다.

---

## 딥링크 & 푸시 알림

- FCM push data: `path` 키로 경로 전달
- 앱에서 URL 조합: `{baseUrl}{path}` (예: `https://m.myfarmplus.com/work-management/...`)
- 딥링크로 열린 WebView가 닫힐 때 현재 탭을 refresh하여 동기화
- `deep_link_notifier.dart`: 앱 실행 시 초기 딥링크(`getInitialMessage`), FCM 딥링크(`onMessageOpenedApp`), Native 딥링크(MethodChannel `mfw_deeplink_handler`) 처리

---

## 빌드 환경

| 환경 | Android | iOS |
|---|---|---|
| dev | Firebase App Distribution (`genesisnest-dev` 그룹) | TestFlight (마이팜플러스-DEV) |
| stg | Firebase App Distribution (`genesisnest-dev`, `ls-mtron`, `hivelab` 그룹) | TestFlight (번들 ID: `com.lsmtron.mfw.dev`) |
| prd | Google Play Console (production track, draft) | TestFlight → 수동 심사 제출 |

**iOS 번들 ID**: dev/stg = `com.lsmtron.mfw.dev`, prd = `com.lsmtron.mfw`

**빌드 명령** (`farm_work/scripts/app_build.zsh` 래퍼 사용):
```bash
# APK (Android dev/stg)
zsh scripts/app_build.zsh --env=development --output=apk [--auto-upload]

# AAB (Android prd)
zsh scripts/app_build.zsh --env=production --output=aab

# IPA (iOS 전 환경)
zsh scripts/app_build.zsh --env=development --output=ipa
```

내부 flutter 실제 명령:
```bash
# Android
flutter build apk --release --flavor={env} --obfuscate --split-debug-info=./build/split-debug-info/android/

# iOS
flutter build ipa --release --flavor={env} --obfuscate --split-debug-info=./build/split-debug-info/ios/ --export-options-plist={plist}
```

---

## 전역 상태

`providers/main_app_state_provider.dart` (ChangeNotifier):
- `currentBottomNavigationTab`: 현재 선택된 하단 탭 (기본값: `home`)
- `_urlMap`: 각 탭의 URL 관리 (`Map<BottomNavigationTab, String?>`)
- `updateBottomNavigationTabUrl()`: 탭 URL 업데이트
- `resetTabUrl()`: 특정 탭 URL 초기값으로 리셋
- `reset()`: 전체 상태 초기화

---

## 관련 페이지
- [[myfarmplus-appbridge|AppBridge Method Contract]]
- [[ci-cd-github-actions|GitHub Actions CI/CD]]
- [[_shared/team-conventions|팀 컨벤션]]

## References
- [flutter_inappwebview Docs](https://inappwebview.dev/docs)
- [Flutter Docs](https://flutter.dev/docs)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [FCM — Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/client)
