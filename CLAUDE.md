# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get           # Install dependencies
flutter run               # Run on connected device/emulator
flutter test              # Run all tests
flutter test test/<file>  # Run a single test file
flutter analyze           # Lint analysis
flutter format lib/       # Format code
flutter build apk         # Android APK
flutter build ios         # iOS build
```

## Architecture

**Prayer Screen Time** is a Flutter app that blocks distracting apps during Islamic prayer windows. It calculates prayer times offline, schedules adhan notifications, and enforces app blocking through platform-native APIs.

### State Management

Riverpod (`flutter_riverpod`) with a three-layer pattern:
- **Repository layer**: domain logic (`PrayerRepository`, `SettingsRepository`, `BlockingRepository`)
- **Provider layer**: Riverpod FutureProviders/StateNotifierProviders wrapping repositories
- **UI layer**: widgets consume providers via `ref.watch()`/`ref.read()`

No code generation — all providers are hand-written.

### Folder Structure

```
lib/
├── main.dart            # Init order: StorageService → NotificationService → BackgroundWorker → ProviderScope
├── app.dart             # MaterialApp.router root
├── core/
│   ├── constants/       # Colors, prayer methods, strings
│   ├── database/        # SharedPreferences wrapper
│   ├── location/        # Geolocator provider/service
│   ├── permissions/     # Unified permission service
│   ├── router/          # GoRouter config (4-tab shell)
│   └── theme/           # Material 3 light/dark theme
└── features/
    ├── prayer/          # Offline prayer time calculation (adhan package)
    ├── qibla/           # Compass bearing to Mecca (flutter_compass)
    ├── notification/    # Local push notifications + background worker
    ├── blocking/        # Platform app blocking via MethodChannel
    ├── onboarding/      # First-run UX
    ├── reflect/         # Daily reflection/journal
    └── settings/        # User preferences (StateNotifier)
```

### Routing

GoRouter with a 4-tab shell (`AppScaffold`): `/prayer`, `/focus` (qibla), `/reflect`, `/settings`. Initial route is `/onboarding` on first run.

### Platform: App Blocking

This is the most platform-specific part of the app:

**Android**: `AppBlockerService` (AccessibilityService) monitors foreground apps and launches `BlockOverlayActivity`. MethodChannel: `com.prayerscreentime.appblocker`. Registered in `MainActivity.configureFlutterEngine()`.

**iOS**: FamilyControls + ScreenTime API via SwiftUI bridge. MethodChannel: `com.prayerscreentime.screentime`. Requires `FamilyControls` entitlement from Apple (pending approval) — iOS blocking is implemented but not yet active.

### Background Tasks

`workmanager` schedules a 12-hour periodic task to recalculate prayer times and reschedule notifications. The callback dispatcher must be annotated `@pragma('vm:entry-point')`. iOS execution is limited to ~30 seconds per workmanager constraints.

### Persistence

SharedPreferences only (JSON serialization). No SQLite or embedded DB.

### Key Dependencies

| Purpose | Package |
|---------|---------|
| State management | `flutter_riverpod ^2.6.1` |
| Routing | `go_router ^14.8.1` |
| Prayer calculation | `adhan ^2.0.0` |
| Notifications | `flutter_local_notifications ^18.0.1` |
| Background tasks | `workmanager ^0.9.0` |
| Location | `geolocator ^13.0.2` |
| Compass | `flutter_compass ^0.8.1` |

### Platform Requirements

- **Android**: Min SDK 26 (Android 8.0), Java 17, core library desugaring enabled
- **iOS**: iOS 16+ (required for Screen Time API)
