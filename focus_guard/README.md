# FocusGuard 🛡️
### Flutter Android App — Focus Timer + App Blocker

---

## Features

- **Pomodoro Timer** — Customizable focus/break durations with auto-start
- **App Blocker** — Select any app (Instagram, YouTube, TikTok, etc.) to block during focus sessions
- **In-App Blocking** — Accessibility service intercepts blocked apps and shows a lock screen
- **Session Tracking** — Stats screen with session counter and total focus time
- **Daily Goal** — Track progress toward your daily session goal
- **Beautiful Dark UI** — Sleek dark theme with animated timer ring

---

## Setup Instructions

### Prerequisites
- Flutter SDK 3.x installed → https://flutter.dev/docs/get-started/install
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 23+)

### 1. Open the project
```bash
cd focus_guard
flutter pub get
```

### 2. Run the app
```bash
flutter run
```

### 3. Enable App Blocking (Required for real blocking)

The app needs two special Android permissions to actually block apps:

#### A. Accessibility Service
1. Open your Android **Settings**
2. Go to **Accessibility** → **Downloaded Apps** (or Installed Services)
3. Find **FocusGuard App Blocker** → Toggle **ON**

#### B. Usage Access
1. Open Android **Settings**
2. Go to **Apps** → **Special App Access** → **Usage Access**
3. Find **FocusGuard** → Toggle **ON**

#### C. Display Over Other Apps (optional overlay)
1. Open Android **Settings**
2. Go to **Apps** → **Special App Access** → **Display Over Other Apps**
3. Find **FocusGuard** → Toggle **ON**

---

## How to Use

### Pomodoro Timer
1. Tap the **Focus** tab
2. Press the **▶ Play** button to start a focus session
3. Timer counts down — orange ring fills as you progress
4. After focus ends, a short/long break starts automatically (if auto-start is on)
5. Session dots at the top track your progress toward a long break

### App Blocking
1. Tap the **Block** tab
2. Select the apps you want to block (Instagram, YouTube, etc.)
3. Tap **Block Now** and choose a duration
4. Selected apps will be blocked for that duration
5. When you start a Pomodoro session, selected apps are automatically blocked

### Settings
- Adjust focus duration (5–90 min)
- Adjust short break (1–30 min)
- Adjust long break (5–60 min)
- Set sessions before long break (2–8)
- Toggle auto-start next session

---

## Project Structure

```
lib/
  main.dart                  # App entry point
  screens/
    home_screen.dart         # Bottom nav shell
    pomodoro_screen.dart     # Timer UI
    block_screen.dart        # App selection & blocking
    stats_screen.dart        # Stats & daily goal
    settings_screen.dart     # Timer settings
  services/
    pomodoro_service.dart    # Timer logic & state
    app_block_service.dart   # Blocking logic & state

android/app/src/main/kotlin/com/focusguard/
  MainActivity.kt                      # Flutter ↔ Android bridge
  AppBlockerAccessibilityService.kt    # Detects & intercepts blocked apps
  BlockOverlayActivity.kt             # Lock screen shown over blocked app
```

---

## Building a Release APK

```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Notes

- App blocking requires the **Accessibility Service** to be enabled manually by the user (Android security requirement — no app can enable this programmatically)
- The blocker detects when a blocked app is launched and immediately replaces it with a lock screen
- All settings and session data persist across app restarts via SharedPreferences
