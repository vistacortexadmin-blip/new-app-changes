# VistaCortex — Healthcare Management Platform

> **Internal Documentation**: This document tracks project architecture, Task 4 & Task 5 implementations, DND bypass mechanics, Full-Screen Lock Screen Alarm implementation, and complete PC environment recovery. (Ignored from remote repository via `.gitignore`).

---

## 1. Project Overview & Architecture

**VistaCortex** is an enterprise-grade patient healthcare management application designed around clinical protocols, HIPAA compliance, and medication adherence.

### Tech Stack
* **Framework**: Flutter 3.47.7 (Dart 3.13.5)
* **State Management**: `flutter_riverpod: ^2.6.1` (immutable StateNotifier pattern)
* **Cloud & Auth**: Firebase Auth, Firebase Core, Firebase Analytics, Google Sign-In, Firebase App Check
* **Notifications & Background Alarms**: `flutter_local_notifications: ^18.0.1`, `timezone: ^0.9.4`, `flutter_timezone: ^3.0.1`
* **Local Security & Persistence**: Encrypted SharedPreferences with HMAC SHA-256 cryptographic hash-chain audit ledger (HIPAA §164.312(b))
* **Document Processing**: `pdfx: ^2.11.0`, Google ML Kit text recognition

---

## 2. PC Reset Recovery & Environment Setup (Completed)

After the PC reset, the entire development toolchain was rebuilt and verified clean:

### Git & Branch State
* Cloned repository from `https://github.com/vistacortexadmin-blip/new-app-changes.git`.
* Active working branch: **`task-4`** (Commit `36b7b4a`), which contains all of Task 4 and incorporates Task 5 (PR #1).
* Aborted accidental merge conflicts and restored a 100% clean, verified working tree.

### Flutter SDK Installation
* Installed official stable release bundle at **`C:\src\flutter`**.
* Added `C:\src\flutter\bin` permanently to Windows User `Path`.
* Linked Android SDK (`C:\Users\ASUS\AppData\Local\Android\Sdk`) and Android Studio (`C:\Program Files\Android\Android Studio`).
* Set permanent `JAVA_HOME` to `C:\Program Files\Android\Android Studio\jbr`.
* Accepted all Android SDK licenses via `flutter doctor --android-licenses`.

### Android Toolchain & Gradle Fixes
* **NDK Installation**: Resolved missing NDK build failure by installing **`ndk/28.2.13676358`** directly using the Android CLI (`android sdk install ndk/28.2.13676358`).
* **SDK & CMake**: Installed Android SDK Platform 36 and CMake 3.22.1.
* **Syntax Fix**: Removed accidental typo `u` on line 15 in `lib/main.dart`.
* **Build Verification**: Ran `flutter build apk --debug`, which compiled cleanly into `build\app\outputs\flutter-apk\app-debug.apk`.

---

## 3. Pixel 9 Emulator Setup & Hardware Optimization

Configured the custom `Pixel_9` Android Virtual Device (`C:\Users\ASUS\.android\avd\Pixel_9.avd\config.ini`) with production performance tuning:

| Setting | Value | Rationale |
| :--- | :--- | :--- |
| **Hardware GPU** | `hw.gpu.enabled=yes` | Replaced slow CPU software rendering with dedicated NVIDIA GPU acceleration. |
| **Physical Keyboard** | `hw.keyboard=yes` | Fixed issue where physical keyboard keystrokes were ignored inside the emulator. |
| **RAM Allocation** | `4096 MB` (4 GB) | Upgraded from 2 GB to ensure smooth Android 17 operation. |
| **CPU Cores** | `hw.cpu.ncore=8` | Upgraded from 4 cores for fast app startup and smooth animations. |
| **Cameras** | `emulated` (front), `virtualscene` (back) | Provides valid camera feeds so camera-based flows do not crash. |
| **Biometric Bypass** | N/A | Tapping **Cancel** on Google Account setup skips simulated Face Unlock. |

---

## 4. Task 4: Medication Adherence & Pill Inventory UI

Located in:
* `lib/features/reminders/views/reminders_screen.dart`
* `lib/features/reminders/providers/reminders_provider.dart`
* `lib/features/reminders/models/reminder_model.dart`

### Features Implemented:
1. **Gamified Adherence Ring & Score**:
   * Interactive circular progress indicator calculating the user's daily adherence percentage in real time (`taken doses / total scheduled doses`).
   * Color-coded progress thresholds (green for high adherence, amber for pending).
2. **Daily Dose Logging & Filter Chips**:
   * Filters by time of day: **Morning**, **Afternoon**, **Evening**, and **Night**.
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

### Features Implemented:
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

## 8. Step-by-Step Testing Guide

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

## 9. How to Run the App

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
