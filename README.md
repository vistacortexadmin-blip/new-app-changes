# VistaCortex — Healthcare Management Platform

> **Internal Engineering & Security Documentation**  
> This document tracks the complete technical architecture, Task 4 & Task 5 implementations, CISO Security Assessment remediation, DND bypass mechanics, Full-Screen Lock Screen Alarm implementation, and the PC reset toolchain recovery.  
> *(Note: This file is kept local and strictly ignored from the remote repository via `.gitignore`).*

---

## 1. Project Overview & Architecture

**VistaCortex** is an enterprise-grade patient healthcare management platform engineered around clinical safety protocols, HIPAA compliance, and medication adherence.

### Tech Stack
* **Framework**: Flutter 3.47.7 (Dart 3.13.5)
* **State Management**: `flutter_riverpod: ^2.6.1` (immutable StateNotifier architecture)
* **Backend & Auth**: Firebase Auth, Firebase Core, Firebase Analytics, Google Sign-In, Firebase App Check
* **Notifications & Background Alarms**: `flutter_local_notifications: ^18.0.1`, `timezone: ^0.9.4`, `flutter_timezone: ^3.0.1`
* **Local Security & Persistence**: `flutter_secure_storage: ^9.2.2`, Encrypted SharedPreferences, HMAC SHA-256 cryptographic hash-chain audit ledger (HIPAA §164.312(b))
* **Document Processing**: `pdfx: ^2.11.0`, Google ML Kit text recognition

---

## 2. PC Reset Recovery & Toolchain Setup (Completed)

Following a full PC reset, the entire local development toolchain was reconstructed and verified:

### Git & Branch Integrity
* Cloned repository from `https://github.com/vistacortexadmin-blip/new-app-changes.git`.
* Active working branch: **`task-4`** (Commit `36b7b4a`), which contains all Task 4 work and incorporates Task 5 (PR #1).
* Aborted in-progress merge conflicts to restore a 100% clean, verified working tree.

### Flutter SDK Installation
* Downloaded and installed the official pinned stable release archive at **`C:\src\flutter`**.
* Added `C:\src\flutter\bin` permanently to Windows User `Path`.
* Linked Android SDK (`C:\Users\ASUS\AppData\Local\Android\Sdk`) and Android Studio (`C:\Program Files\Android\Android Studio`).
* Set permanent `JAVA_HOME` to `C:\Program Files\Android\Android Studio\jbr`.
* Accepted all Android SDK licenses via `flutter doctor --android-licenses`.

### Android Studio IDE Configuration
* Resolved the Marketplace download timeout for Flutter/Dart plugins by linking the SDK paths directly in Android Studio:
  * **Flutter SDK Path**: `C:\src\flutter`
  * **Dart SDK Path**: `C:\src\flutter\bin\cache\dart-sdk`
* Enabled Dart support for the project, resolving the *"Dart SDK is not configured"* banner and enabling the Run/Debug controls.

### Android Toolchain, NDK & Gradle Fixes
* **NDK 28 Installation**: Resolved missing NDK build failures by installing **`ndk/28.2.13676358`** directly using the Android CLI tool (`android.exe sdk install ndk/28.2.13676358`).
* **Platform 36 & CMake**: Automatically configured Android SDK Platform 36 and CMake 3.22.1.
* **Syntax Error Fix**: Resolved accidental typo `);u` on line 15 in `lib/main.dart`.
* **Build Verification**: Ran `flutter build apk --debug`, which compiled cleanly with exit code 0 (`build\app\outputs\flutter-apk\app-debug.apk`).

---

## 3. Pixel 9 Emulator Setup & Performance Optimization

Configured the custom `Pixel_9` Android Virtual Device (`C:\Users\ASUS\.android\avd\Pixel_9.avd\config.ini`) with production performance tuning:

| Setting | Value | Rationale |
| :--- | :--- | :--- |
| **Hardware GPU** | `hw.gpu.enabled=yes` | Replaced slow CPU software rendering with dedicated NVIDIA GPU hardware acceleration. |
| **Physical Keyboard** | `hw.keyboard=yes` | Fixed issue where physical keyboard keystrokes were ignored inside the emulator. |
| **RAM Allocation** | `4096 MB` (4 GB) | Upgraded from 2 GB to ensure smooth Android 17 operation. |
| **CPU Cores** | `hw.cpu.ncore=8` | Upgraded from 4 cores for rapid app compilation and 60 FPS UI performance. |
| **Cameras** | `emulated` (front), `virtualscene` (back) | Provides valid camera feeds to prevent camera-based flows from crashing. |
| **Biometric Bypass** | N/A | Tapping **Cancel** on Google Account setup skips simulated Face Unlock. |

---

## 4. Task 4: Medication Adherence & Pill Inventory UI

Located in:
* `lib/features/reminders/views/reminders_screen.dart`
* `lib/features/reminders/providers/reminders_provider.dart`
* `lib/features/reminders/models/reminder_model.dart`

### Key Implementations:
1. **Gamified Daily Adherence Ring & Score**:
   * Interactive circular progress gauge calculating the daily adherence score in real time (`taken doses / total scheduled doses`).
   * Color-coded progress thresholds (green for high adherence, amber for pending).
2. **Daily Dose Logging & Filter Chips**:
   * Filters doses by time of day: **Morning**, **Afternoon**, **Evening**, and **Night**.
   * One-tap **"Mark Taken"** action that logs the exact timestamp and automatically deducts 1 pill from inventory.
   * **"Skip"** action requiring a mandatory clinical reason dialog (e.g., "Felt nauseous", "Doctor advised", "Fasting").
3. **Multi-Dose Medication Creation**:
   * Multi-slot time pickers allowing patients to schedule multiple doses per day (e.g., Morning and Night) for a single prescription.
   * Native date pickers for treatment start date and duration.
4. **Pill Inventory & Refills**:
   * Real-time calculation of remaining days of supply (`total stock / daily doses`).
   * Visual warning badges on medicines with $\le 5$ days of supply remaining.
   * Smart Refill Bottom Sheet: Quick-add buttons (`+10`, `+30`, `+60`, `+90`) plus custom quantity input.
   * **Exact Stock Override**: A dedicated pencil edit button allowing users to override and manually type in their exact pill count.
5. **Diagnostic Tests Countdown Tracker**:
   * Dedicated tab tracking upcoming laboratory scans, blood tests, and checkups.
   * Smart countdown badges ("Today", "Tomorrow", "In X Days", "Overdue").
   * Marking a test completed archives it and cancels its scheduled background alarms.
6. **Flutter Framework Safety (`_dependents.isEmpty`)**:
   * Prevented core Flutter framework crashes by ordering `Navigator.pop(context)` and snackbar notifications *before* dispatching synchronous Riverpod state changes.

---

## 5. Task 5: Local Notifications & Background Scheduling

Located in:
* `lib/core/services/notification_service.dart`
* `android/app/src/main/AndroidManifest.xml`

### Key Implementations:
1. **Timezone-Aware Scheduling**:
   * Integrated `timezone` and `flutter_timezone` to map native system timezones.
   * Added `_legacyTimezoneMap` to translate deprecated timezone IDs (e.g., `Asia/Calcutta` $\rightarrow$ `Asia/Kolkata`).
2. **Dose Pre-Alerts**:
   * Medication alarms fire **5 minutes before** the scheduled dose time to give patients time to prepare water and meals.
3. **Critical Low-Stock Push Alerts**:
   * Taking a dose that drops inventory to $\le 3$ days immediately fires a local notification warning the patient to request a refill.
4. **Cascading Diagnostic Test Reminders**:
   * Upcoming medical tests trigger a reminder **3 days before**. If that time has passed, it cascades to **1 day before**, and finally the morning of the test.
5. **State Synchronization & Cancellation**:
   * Permanently deleting or editing a reminder automatically cancels and reschedules its exact background alarm IDs without collisions.

---

## 6. Do Not Disturb (DND) Bypass Architecture

Located in:
* `android/app/src/main/kotlin/com/example/vistacortex_mobile/MainActivity.kt`
* `lib/core/services/notification_service.dart`
* `android/app/src/main/AndroidManifest.xml`

### How DND Bypass Works:
Because modern Android strictly protects user privacy, apps cannot silently disable DND without user opt-in. VistaCortex implements a **dual-approach architecture**:

```
[Reminders Header DND Button]
           │
           ▼
[DND Settings Modal Sheet]
  ├── Approach 1: Channel DND Bypass (Medical Alarm Channel)
  └── Approach 2: System Notification Policy Access
```

1. **Approach 1: Channel DND Override (`openChannelNotificationSettings`)**:
   * **Channel ID**: `medical_emergency_channel_v2`
   * **Channel Importance**: `Importance.max`
   * **Sound & Stream**: Routes to `AudioAttributesUsage.alarm` with custom bundled audio `alarm_loud.wav`.
   * **Native Bridge**: Uses `MethodChannel('com.vistacortex/dnd_settings')` in `MainActivity.kt` to trigger Android's `Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS`.
   * **User Experience**: Tapping the button opens the Android settings page for this channel directly, where the user can toggle **"Override Do Not Disturb"**.
2. **Approach 2: System DND Access (`openNotificationPolicyAccessSettings`)**:
   * **Permission**: `android.permission.ACCESS_NOTIFICATION_POLICY` and `android.permission.USE_FULL_SCREEN_INTENT`.
   * **Policy Check**: `notificationManager.isNotificationPolicyAccessGranted`.
   * **User Experience**: Tapping the button opens `Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS` so the user can grant complete Do Not Disturb policy access.

---

## 7. Full-Screen Lock Screen Alarm Architecture

Located in:
* `android/app/src/main/AndroidManifest.xml`
* `android/app/src/main/kotlin/com/example/vistacortex_mobile/MainActivity.kt`
* `lib/core/services/notification_service.dart`

### How Full-Screen Lock Screen Alarms Work:
When a phone is locked or the screen is turned off (sleeping), standard notifications only appear as passive entries on the lock screen. For clinical adherence and emergency alarms, VistaCortex turns on the screen and presents the full-screen alarm directly over the lock screen:

1. **Native Activity Lock Flags**:
   In `AndroidManifest.xml` on `<activity android:name=".MainActivity">`:
   ```xml
   android:showWhenLocked="true"
   android:turnScreenOn="true"
   ```
   In `MainActivity.kt`:
   ```kotlin
   if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
       setShowWhenLocked(true)
       setTurnScreenOn(true)
   } else {
       window.addFlags(
           WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
           WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
       )
   }
   ```
2. **Notification Configuration (`notification_service.dart`)**:
   * `fullScreenIntent: true`
   * `category: AndroidNotificationCategory.alarm`
   * `audioAttributesUsage: AudioAttributesUsage.alarm`
   * `priority: Priority.max`
3. **Android 14+ System Permissions**:
   * `android.permission.USE_FULL_SCREEN_INTENT`
   * `android.permission.SCHEDULE_EXACT_ALARM`
   * `android.permission.WAKE_LOCK`

---

## 8. CISO Security Assessment Report Remediation Matrix

This codebase incorporates all fixes for the **CISO Security Assessment Report (Oct 6, 2026 by Koushik Reddy)**:

| Finding ID | CISO Finding Description | Resolution Implemented in `task-4` | Status |
| :---: | :--- | :--- | :---: |
| **C1** | App doesn't build (merge conflict markers) | Resolved all conflict markers; NDK 28 & Platform 36 installed; `flutter analyze` passes with 0 errors. | ✅ **Fixed** |
| **C2** | Development login fallback bypassed password | Removed `createLocalSession` completely from `auth_service.dart`. Strict Firebase Auth enforced. | ✅ **Fixed** |
| **C3** | Patient data stored in plain text across accounts | Migrated patient profile, reminders, and reports to `FlutterSecureStorage`. Data is wiped on sign-out. | ✅ **Fixed** |
| **H1** | AI assistant scripted answers & sample data | Wiped mock patient data from `seed_data.dart`; AI chat strictly references authenticated patient data. | ✅ **Fixed** |
| **H2** | Audit log tamperable & fake "Priya Sharma" | Removed mock entries; implemented cryptographic SHA-256 HMAC hash chaining; removed misleading compliance tags. | ✅ **Fixed** |
| **H3** | Security features only pretended to work | Connected genuine `sendPasswordResetEmail`; implemented real family caregiver persistence. | ✅ **Fixed** |
| **H4** | Release builds unsigned & un-obfuscated | Enabled R8/Proguard code shrinking & obfuscation (`isMinifyEnabled = true`) in `app/build.gradle.kts`. | ✅ **Fixed** |
| **H5** | Health details visible on lock screen / screen capture | Added `FLAG_SECURE` in `MainActivity.kt` to block screenshots; neutralized notification text to generic alerts. | ✅ **Fixed** |
| **M1** | Weak 6-character passwords & user enumeration | Enforced $\ge 10$ character passwords and generic error messages in `login_screen.dart`. | ✅ **Fixed** |
| **M2** | Firebase App Check disabled | Enabled `firebase_app_check` with Play Integrity / DeviceCheck in `main.dart`. | ✅ **Fixed** |
| **M5** | Demographic data sent to analytics | Removed demographic tracking from `analytics_service.dart`; silenced debug logs in release builds. | ✅ **Fixed** |
| **M6** | Audit logs copied to clipboard | Changed export in `security_audit_screen.dart` to write to a private file via system Share Sheet. | ✅ **Fixed** |
| **L5** | Timezone guessed from UTC offset | Added `flutter_timezone` to query native device IANA timezone. | ✅ **Fixed** |
| **B1** | Reminders lost on restart | Implemented persistent encrypted storage in `reminders_provider.dart`. | ✅ **Fixed** |
| **B2** | Unstable reminder hash codes | Replaced with deterministic UUID hashing to prevent cross-restart cancellation failures. | ✅ **Fixed** |
| **B3** | 5-minute pre-alert repeating time shift | Fixed calculation logic so daily repeating reminders maintain their exact scheduled hour/minute. | ✅ **Fixed** |
| **B4** | Duplicate low-stock alerts | Debounced low-stock triggers in `reminders_provider.dart`. | ✅ **Fixed** |

---

## 9. Step-by-Step Testing Guide

### A. Testing DND Bypass on the Emulator
1. **Turn ON Do Not Disturb**: On the emulator, swipe down from the top twice and tap the **Do Not Disturb (⛔)** tile to activate DND.
2. **Enable Channel Override**:
   * In VistaCortex, go to the **Reminders** tab.
   * Tap the **DND Shield Icon** in the top header.
   * Tap **Open Channel DND Settings** under Approach 1.
   * Toggle ON **"Bypass Do Not Disturb"**.
3. **Trigger Alarm**: Schedule a dose 1-2 minutes ahead (or trigger low stock).
4. **Verification**: The alarm banner pops up and `alarm_loud.wav` plays even though DND is strictly active.

### B. Testing Full-Screen Lock Screen Alarm
1. In VistaCortex, go to **Reminders** $\rightarrow$ tap **`+`** $\rightarrow$ **Add Medicine**.
2. Look at the clock in the emulator's status bar (e.g. `11:20 PM`), and set the dose time **1 or 2 minutes ahead** (e.g. `11:22 PM`).
3. Tap **Save**.
4. **Immediately lock the screen**: Click the **Power button (⏻)** on the emulator toolbar (or press `Ctrl + F12`).
5. **Verification**: In ~5 seconds:
   * The dark emulator screen will **wake up and turn ON automatically**.
   * It will **bypass the lock screen** and present the alarm alert.
   * The loud alarm sound will blast.

---

## 10. How to Run the App

### Via Android Studio
1. Open the project folder in Android Studio.
2. Select **`main.dart`** and device **`Pixel 9 (mobile)`**.
3. Click the green **Play (▶️)** button (or press `Shift + F10`).

### Via Terminal
```powershell
cd d:\Vistacortex\new-app-changes
flutter run
```

### Direct Emulator Run
The APK is already installed on the Pixel 9 emulator. You can swipe up into the app drawer on the emulator and tap the **VistaCortex** app icon directly.
