---
topic: app
created: 2026-04-28
updated: 2026-04-28
confidence: high
sources: [raw/app/myfarmplus-appbridge-contract.md]
verified-by: human
verified-at: 2026-04-28
---

# AppBridge Method Contract — MyFarm Plus

## 요약
웹(JS) ↔ Flutter(Dart) 양방향 통신 레이어. 웹은 `window.appBridge.{method}()`로 호출.

Canonical source of truth: `ls-farmwork-web/common/src/types/appBridge.d.ts`

---

## iOS/Android 초기화 차이

| 플랫폼 | appBridge 주입 시점 |
|---|---|
| Android | 페이지 로드 전 |
| iOS | `DOMContentLoaded` 후, `load` 전 → 웹에서는 `load` 이벤트 후 접근 |

---

## 메서드 계약

| Method | Params | Return |
|---|---|---|
| `openWebview` | `url: string, allowGestureNavigation?: boolean` | `Promise<string?>` |
| `closeWebview` | `result?: string` | `Promise<void>` |
| `getCurrentPosition` | `options?: PositionOptions` | `Promise<GeolocationPosition>` |
| `checkPermission` | `permission: AppPermission` | `Promise<AppPermissionStatus>` |
| `requestPermission` | `permission: AppPermission` | `Promise<AppPermissionStatus>` |
| `openAppSettings` | — | `Promise<void>` |
| `getMobileInfo` | — | `Promise<MobileInfo>` |
| `getPushToken` | — | `Promise<string?>` |
| `setBottomNavigationBarVisibility` | `visibility: boolean` | `Promise<void>` |
| `selectBottomNavigationTab` | `tab: BottomNavigationTab, newUrl?: string` | `Promise<void>` |
| `addBackPressListener` | `listener: () => void` | `void` |
| `removeBackPressListener` | `listener: () => void` | `void` |
| `terminate` | — | `void` |
| `goTo` | `screen: AppScreen` | `void` |
| `openDevSetting` | — | `void` |
| `openAppLicensePage` | — | `void` |
| `addVisibilityChangeListener` | `listener: (v: WebViewVisibleState) => void` | `void` |
| `removeVisibilityChangeListener` | `listener: (v: WebViewVisibleState) => void` | `void` |
| `notifyUserAction` | `action: UserAction, memberId?: string` | `Promise<void>` |
| `getContactInfo` | — | `Promise<AppContactInfo?>` |
| `sendLogEvent` | `eventName: string, parameters?: Record<string, any>` | `Promise<void>` |
| `setWakeLock` | `enable: boolean` | `void` |
| `setLocationSharing` | `enable: boolean, token: string, interval?: number` | `void` |
| `setLocationTracking` | `enable: boolean` | `Promise<boolean>` |
| `stopAllLocationTask` | — | `Promise<void>` |
| `checkLocationSharingState` | — | `Promise<boolean>` |
| `checkGpsState` | — | `Promise<boolean>` |
| `addLocationTrackingListener` | `listener: (location: AppLocation) => void` | `void` |
| `removeLocationTrackingListener` | `listener: (location: AppLocation) => void` | `void` |
| `addLocationSharingStoppedListener` | `listener: () => void` | `void` |
| `removeLocationSharingStoppedListener` | `listener: () => void` | `void` |

---

## Key Types

```typescript
type AppPermission = "notification" | "location" | "camera" | "contacts"
type AppPermissionStatus = "granted" | "denied" | "permanentlyDenied" | "limited"
type BottomNavigationTab = "home" | "workManagement" | "myPage"
type AppScreen = "main" | "login"
type WebViewVisibleState = "visible" | "hidden"
type UserAction = "SIGN_IN" | "SIGN_OUT" | "DELETE_ACCOUNT"

interface AppLocation { latitude, longitude, accuracy, speed, timestamp (ms) }
interface AppContactInfo { name: string, phoneNumber: string }
interface MobileInfo { deviceInfo: DeviceInfo, packageInfo: PackageInfo }
```

---

## 핸들러 구조

Handler registry: `webview/app_bridge/webview_app_bridge.dart`
Handler interface: `app_bridge_method_handlers/base/app_bridge_method_handler.dart`

새 핸들러 추가 절차:
1. `app_bridge_method_handlers/` 하위에 `*_handler.dart` 생성
2. `AppBridgeMethodHandler` 구현
3. `WebviewAppBridge._handlers` 리스트에 등록 ← **누락 시 동작 안 함**
4. `app_bridge_d_ts/src/appBridge.d.ts`에 타입 정의 추가
5. `app_bridge_d_ts/src/index.ts`에 웹 사전테스트용 구현 추가

---

## 관련 페이지
- [[myfarmplus-context|마이팜플러스 프로젝트 컨텍스트]]
