# PRD: Prayer Screen Time

## 1. Executive Summary

- **Problem Statement**: Muslims frequently get distracted by digital notifications and app usage during prayer windows, leading to delayed or rushed prayers.
- **Proposed Solution**: A hybrid Flutter application that automatically calculates prayer times based on global timezones and enforces a "focus mode" by blocking distracting apps during these sacred windows.
- **Success Criteria**:
  - **Uptime**: 99.9% accuracy in prayer time calculations for any global coordinate.
  - **Adherence**: Users reduce time spent on "distracting" apps by 80% during the 15-minute window surrounding each prayer.
  - **Reliability**: 0% failure rate for scheduled push notifications (Adhan alerts).
  - **Usability**: Users can find Qibla direction within 5 seconds of opening the feature.

## 2. User Experience & Functionality

- **User Personas**: 
  - **The Busy Professional**: Working across timezones, needs automated reminders and a hard "block" to step away from the screen.
  - **The Student**: Prone to social media distractions; needs a tool to enforce discipline during prayer times.
  - **The Traveler**: Needs seamless timezone adjustments and a reliable Qibla finder.

- **User Stories**:
  - **Story 1**: As a user, I want the app to automatically detect my timezone and location so that I don't have to manually update prayer times when I travel.
  - **Story 2**: As a user, I want to select specific "distracting apps" (e.g., Instagram, TikTok) to be blocked 5 minutes before and 10 minutes after prayer time so I can focus.
  - **Story 3**: As a user, I want to receive a notification (Adhan) at the start of each prayer time so I never miss a prayer.
  - **Story 4**: As a user, I want a Qibla compass to find the direction of the Kaaba regardless of where I am in the world.

- **Acceptance Criteria**:
  - App must request and handle Location and Notification permissions on first launch.
  - Prayer times must be recalculated immediately upon significant location/timezone change.
  - The "Block" feature must effectively prevent the opening of selected apps during the defined window (using platform-specific APIs like Screen Time API for iOS and Accessibility Services for Android).
  - Qibla compass must provide accuracy within +/- 3 degrees.

- **Non-Goals**:
  - Building a full social media platform for Muslims.
  - Providing a full Quran reading experience (MVP focus is Screen Time & Prayer).
  - Implementing an e-commerce store for prayer mats/accessories.

## 3. Technical Specifications

- **Architecture Overview**:
  - **Frontend**: Flutter (Hybrid) for cross-platform consistency.
  - **State Management**: Provider or Riverpod for handling real-time prayer countdowns.
  - **Local Storage**: Hive or SQLite for storing user preferences and blocked app lists.
  - **Background Tasks**: WorkManager (Android) and Background Tasks (iOS) for scheduling blocks and notifications.

- **Integration Points**:
  - **Prayer API**: Aladhan API or a local library like `adhan` for offline calculations.
  - **Geo-Location**: `geolocator` Flutter package.
  - **Sensors**: `flutter_compass` for Qibla direction.
  - **Native Bridges**: MethodChannels for iOS Screen Time API (FamilyControls) and Android Accessibility/UsageStats.

- **Security & Privacy**:
  - Location data must be processed locally whenever possible.
  - No user browsing data or "blocked app" usage data should be uploaded to external servers.
  - Strict adherence to Apple's App Tracking Transparency and Google's Privacy policies.

## 4. Risks & Roadmap

- **Phased Rollout**:
  - **MVP**: Prayer time calculation, Adhan notifications, Qibla finder, and basic app blocking for Android.
  - **v1.1**: iOS Screen Time API integration (requires Apple approval for Family Controls).
  - **v2.0**: Gamification (badges for prayer consistency), "Community Mode" to sync focus windows with friends.

- **Technical Risks**:
  - **iOS Restrictions**: Apple's Screen Time API is highly restricted; getting approval for "Managed Settings" can be difficult for non-parental-control apps.
  - **Battery Drain**: Constant background location tracking can drain battery; need to use "Significant Location Change" triggers.
  - **API Latency**: Dependency on external Prayer APIs for initial setup.

## 5. Evaluation Strategy

- **Accuracy Audit**: Compare app-calculated times against standard mosque timings in 5 major global cities.
- **Beta Testing**: 30-day trial with 50 users to monitor "Block" effectiveness and battery impact.
- **Crash Reporting**: Sentry or Firebase Crashlytics integration to track stability across different Android OEM skins.
