# Technical Requirements Document (TRD): Prayer Screen Time

## 1. System Architecture

### 1.1 High-Level Architecture
The application will be built using Flutter to provide a unified codebase for iOS and Android. It will rely heavily on native platform integrations for app blocking and background scheduling.

- **Frontend Framework**: Flutter (Dart)
- **State Management**: Riverpod (for robust, compile-safe state handling and dependency injection)
- **Local Storage**: Isar Database (for high-performance local storage of prayer times, user settings, and blocked app lists)
- **Background Processing**: `workmanager` (Flutter package) acting as a wrapper for Android's WorkManager and iOS's BackgroundTasks.

### 1.2 Data Flow
1. **Location & Timezone**: App requests location permissions -> Fetches Lat/Long using `geolocator` -> Derives timezone.
2. **Prayer Calculation**: Feeds Lat/Long and Date to local `adhan` Dart package to compute prayer times (ensures 100% offline accuracy for any global coordinate without API latency).
3. **Notification Scheduling**: UI layer pushes calculated times to the background scheduler -> Background worker sets up local push notifications using `flutter_local_notifications`.
4. **App Blocking Enforcement**:
   - **Android**: Flutter communicates via `MethodChannel` to an Android Native Service implementing `AccessibilityService` or `UsageStatsManager` to detect foreground apps and overlay a block screen if the app is on the restricted list during a prayer window.
   - **iOS**: Flutter communicates via `MethodChannel` to Swift code utilizing the `FamilyControls` and `ManagedSettings` frameworks (Screen Time API) to shield specific app categories/tokens.

## 2. Technical Stack & Dependencies

### 2.1 Core Flutter Packages
- `flutter_riverpod`: State management.
- `isar` & `isar_flutter_libs`: Local, schema-based NoSQL database.
- `geolocator`: GPS coordinate retrieval.
- `adhan`: Offline mathematical calculation of prayer times based on astronomical algorithms.
- `flutter_local_notifications`: For Adhan alerts.
- `workmanager`: For background task execution (recalculating times daily).
- `flutter_compass`: Device sensor access for Qibla direction.
- `permission_handler`: Managing complex location, notification, and accessibility permissions.

### 2.2 Native Integrations (MethodChannels)
- **Android `com.prayerscreentime.appblocker`**:
  - Handles `AccessibilityService` to detect window state changes.
  - Draws a native overlay over restricted apps using `SYSTEM_ALERT_WINDOW`.
- **iOS `com.prayerscreentime.screentime`**:
  - Requires `Family Controls` capability in Xcode.
  - Uses `DeviceActivity` and `ManagedSettings` to apply shields to `ApplicationToken`s.

## 3. Data Models (Isar Schema)

```dart
@collection
class UserSettings {
  Id id = Isar.autoIncrement;
  late double latitude;
  late double longitude;
  late String timezone;
  late int calculationMethod; // e.g., Muslim World League, ISNA
  late int blockDurationBefore; // minutes (e.g., 5)
  late int blockDurationAfter; // minutes (e.g., 10)
}

@collection
class BlockedApp {
  Id id = Isar.autoIncrement;
  late String packageName; // Android package or iOS bundle ID
  late String appName;
}
```

## 4. Implementation Plan (Phased)

### Phase 1: Core Setup & Prayer Engine (Weeks 1-2)
1. Initialize Flutter project with Riverpod and Isar.
2. Implement location fetching and permissions.
3. Integrate `adhan` package and build the mathematical engine to calculate and display the 5 daily prayer times based on location.
4. Implement the Qibla Compass UI using `flutter_compass`.

### Phase 2: Notifications & Background Tasks (Week 3)
1. Configure `flutter_local_notifications` for Android and iOS.
2. Implement audio playback for Adhan.
3. Set up `workmanager` to run a daily background task that recalculates prayer times and schedules local notifications for the next 24 hours.

### Phase 3: Android App Blocking (MVP) (Weeks 4-5)
1. Build Flutter UI to list installed apps and let users select which to block.
2. Create Android Native code (Kotlin) establishing a `MethodChannel`.
3. Implement `AccessibilityService` in Android to monitor foreground apps.
4. Trigger a native full-screen overlay if a blocked app is opened during a prayer window.

### Phase 4: iOS App Blocking (Week 6)
1. Configure iOS native side (Swift) with FamilyControls.
2. Prompt user for Screen Time permissions via Flutter-to-Swift bridge.
3. Implement logic to apply `ManagedSettingsStore.shield` to selected app tokens during prayer times.

## 5. Security, Privacy & Edge Cases
- **DST & Timezone Shifts**: Utilizing the local `adhan` package with the device's current timezone ensures 100% accuracy even during Daylight Saving Time transitions without relying on a remote server.
- **Battery Optimization**: Use `geolocator`'s significant location change streams rather than continuous GPS tracking to preserve battery.
- **Offline First**: All calculations and schedules must work completely offline after the initial location fix. No user data leaves the device.