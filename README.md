# VistaCortex - Task 4 & 5: Medication Reminders & Local Notifications

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod%202.x-blue)](https://riverpod.dev)

This document covers the implementation of **Task 4 (Health Adherence & UI)** and **Task 5 (Local Notifications & Background Scheduling)** for **VistaCortex**.

---

## Features Implemented

### 1. Daily Adherence Ring & Progress Score
- **Gamified Progress**: Visual circular progress indicator showing the user's daily adherence score based on doses taken vs pending/skipped.
- **Dynamic Updates**: Automatically recalculates when doses are marked as taken or skipped.

### 2. Daily Dose Logging & Action System
- **Take/Skip Logic**: Users can mark doses as "Taken" (which deducts from their pill inventory) or "Skip" (with a mandatory reason like "Felt nauseous").
- **Time-of-Day Filtering**: Doses are grouped by Morning, Afternoon, Evening, and Night.

### 3. Multi-Dose Medication Scheduling
- **Native Pickers**: Uses Flutter's native `showDatePicker` and `showTimePicker` for bulletproof date/time entry.
- **Multiple Doses**: Users can select multiple times of day (e.g., Morning and Evening) for a single medication. The UI automatically spawns individual exact-time pickers for each selected dose block.

### 4. Pill Inventory & Refill Supply Management
- **Automatic Tracking**: The app calculates remaining days of supply (`total pills / daily doses`).
- **Low Stock Alerts**: Visually highlights medicines with ≤ 5 days of supply.
- **Refill Button**: Contextual "+30 Refill" button instantly updates inventory.
- **Push Notification**: Automatically triggers a local notification warning when supply drops to ≤ 3 days.

### 5. Diagnostic Tests & Labs
- **Tests Tab**: Dedicated tab for tracking upcoming medical tests, labs, and scans.
- **Smart Countdown**: Calculates days remaining (e.g., "In 3 Days", "Tomorrow", "Today", "Overdue").
- **Celebratory UI**: Marking a test as complete triggers a green confetti success banner.

### 6. Robust Local Notifications (Task 5)
- **`flutter_local_notifications` v18**: Integrated with Android core library desugaring for full backwards compatibility.
- **Timezone Support**: Initialized with local device timezones to ensure alarms fire exactly on time.
- **Cascading Test Reminders**: Tests schedule a reminder 3 days before. If that has already passed, it falls back to 1 day before, then the morning of the test.
- **Pre-Alerts**: Medication reminders fire exactly 5 minutes *before* the scheduled dose time to give the user time to prepare.
- **Notification ID Safety**: Generates safe, collision-free integer IDs from object hashes to prevent reminders from overwriting each other.
- **Automatic Cancellation**: Cancels scheduled test notifications immediately if the user marks the test as completed early.

---

## Architecture & State

- **State Management**: `RemindersNotifier` (Riverpod) acts as the single source of truth. All UI actions dispatch methods to this provider.
- **Notification Service**: A Singleton `NotificationService` handles permission requests, initialization, and scheduling logic. Wrapped in fail-safe `try/catch` blocks at app launch to prevent crash-to-desktop scenarios.
- **UI Context Awareness**: The main Floating Action Button (`+`) checks the active Tab. It opens the "Add Medicine" modal on the Doses tab, and the "Add Test" modal on the Tests tab.

---

## Getting Started

1. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run Application**:
   ```bash
   flutter run
   ```
   *(Note: The emulator must support Android 13+ Notification Permissions)*

---

## Permissions (Android)
- `POST_NOTIFICATIONS`: Required for Android 13+.
- `SCHEDULE_EXACT_ALARM`: Required for precise medicine reminders.
- `RECEIVE_BOOT_COMPLETED`: Reschedules alarms if the user restarts their phone.

## Security & Privacy Guardrails (CISO Assessment Phase 1-3)

A comprehensive security overhaul was conducted to address all critical findings from the CISO Security Assessment Report, hardening the app against unauthorized access, data leaks, and HIPAA violations:

### 1. Identity & Authentication Hardening
- **Removed Critical Backdoor**: Stripped out the `createLocalSession` fallback in `AuthService` that allowed attackers to bypass Firebase and log in using just an email address (C2).
- **Password Policies**: Increased minimum password length to 10 characters (M1).
- **Anti-Enumeration**: Standardized Firebase login errors to a single generic message (*"Invalid credentials or sign-in failed"*) to prevent attackers from discovering if a patient's email exists in the system (M1).

### 2. PHI Protection & Privacy
- **Encrypted Local Storage**: Migrated all offline patient data (Profile, Reminders, Reports, and Security Audit Ledger) from insecure `SharedPreferences` to lutter_secure_storage (Android Keystore / iOS Keychain) (C3).
- **Secure Data Wipe**: Engineered a complete `storage.deleteAll()` command that reliably destroys all decrypted local PHI the moment a user signs out (C3).
- **Analytics Sanitization**: Removed gender and other demographic tracking from Firebase Analytics events to prevent HIPAA violations (M5).
- **Silent Telemetry**: Disabled internal `debugPrint` logging in release mode to prevent variable leaks to `logcat` on production devices (M5).
- **Screenshot Blocking**: Enabled `FLAG_SECURE` on the Android `MainActivity` to block screenshots, screen recordings, and blank out the app preview in the OS recent-apps switcher (H5).
- **Mock Data Cleaned**: Purged hardcoded clinical AI mock answers (H1) and fake medical records (H2) that risked contaminating real patient data or dispensing false medical advice.

### 3. Infrastructure & Architecture Security
- **Firebase App Check**: Activated Firebase App Check with device attestation (Play Integrity on Android, DeviceCheck on iOS) to block botnets, emulators, and unauthorized API calls (M2).
- **Secure File Export**: Replaced the highly insecure clipboard copy mechanism for the Security Audit Log with a private temporary file export via the OS Share Sheet (M6).
- **Release Obfuscation**: Enabled R8/Proguard code shrinking and obfuscation in uild.gradle.kts to protect intellectual property and deter reverse-engineering (H4).
- **Timezone Precision**: Replaced UTC offset guessing with lutter_timezone to query the OS for the actual IANA timezone string, guaranteeing safe medication alerts across daylight saving boundaries (L5).
- **UI Honesty**: Removed false claims about encryption and unbuilt security features from the Settings and Family Invite UI, and added placeholders for Account Deletion (H3/M7).
