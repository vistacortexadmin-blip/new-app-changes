# VistaCortex 🩺
# VistaCortex - Task 4: Medication & Reminders System 🩺

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod%202.x-blue)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-brightgreen)]()
[![Branch](https://img.shields.io/badge/Branch-task--4-orange)]()

**VistaCortex** is an intelligent personal health assistant and clinical management platform built with **Flutter** and **Riverpod**. Designed with a modern Material 3 design system, VistaCortex empowers patients and care teams with smart reminder schedules, AI-assisted medical report parsing, recovery tracking, family caregiver connectivity, and a tamper-evident HIPAA security audit trail.
This branch (`task-4`) implements **Task 4: Medication Reminders, Refill Supply Management & Health Adherence Tracking** for the **VistaCortex** application.

---

## ✨ Key Features
## ⏰ Task 4 Implementation Highlights

### ⏰ Medication & Dose Reminders
- **Daily Adherence Tracking**: Real-time progress ring scoring daily dose compliance.
- **Dose Management**: Log doses as **Taken** or **Skipped** (with mandatory reason recording).
- **Time-of-Day Filtering**: Filter doses by *Morning*, *Afternoon*, *Evening*, or *Night*.
- **Refill & Stock Management**: Inventory tracking for pills remaining with automatic low-stock alerts.
- **Add Medicine Modal**: Schedule custom medications with dosage instructions and custom times.
### 1. Daily Adherence Ring & Progress Score
- **Interactive Progress Meter**: Calculates real-time daily compliance percentage based on taken vs. scheduled doses.
- **Dynamic Status Styling**: Visual indicator changes color dynamically (Emerald Success `≥ 80%`, Amber Warning `< 80%`).

### 📄 Medical Report Scanner & Biomarker Trends
- **Report OCR & Parsing**: Upload medical reports (Lab Results, Prescriptions) for smart parsing.
- **Biomarker Analysis**: Track HbA1c, Fasting Blood Sugar, Lipid Profile, and Blood Pressure.
- **Visual Trend Calculator**: Automated assessment of clinical progress over time.
### 2. Daily Dose Logging & Action System
- **Dose Actions**: Mark doses as **Taken** or **Skipped** directly from the daily schedule list.
- **Dose Deduction**: Marking a dose as *Taken* automatically decrements 1 pill count from the available stock.
- **Skip Reason Dialog**: Marking a dose as *Skipped* opens a modal dialog requiring a skip reason (e.g., side effects, nauseous, election) for clinical audit trails.

### 🛡️ Cryptographic Security Audit Ledger
- **HIPAA-Compliant PHI Logging**: Full audit trail recording all Protected Health Information access and mutations.
- **SHA-256 Tamper-Evident Ledger**: Cryptographic hash chaining ensures audit entries cannot be modified or forged.
- **Audit Inspector Screen**: Built-in verification UI to audit system integrity and inspect compliance logs.
### 3. Time-of-Day Dose Filtering
- **Interactive Chips**: Filter medication schedules by time slot:
  - 🌅 **Morning**
  - ☀️ **Afternoon**
  - 🌆 **Evening**
  - 🌙 **Night**

### 📊 Smart Health Dashboard
- **Vitals Overview**: Real-time monitoring of Heart Rate, Blood Sugar, SpO2, and Sleep.
- **Clinical Status Badges**: Instant visual feedback for normal, borderline, and elevated vitals.
- **Emergency SOS Shortcut**: Quick access to trigger family/caregiver emergency protocols.
### 4. Pill Inventory & Refill Supply Management
- **Stock Tracking**: Real-time days-of-supply remaining counter (`totalQuantityAvailable / dailyDoseCount`).
- **Low Stock Alerts**: Highlighted warning cards when supply drops below 5 days (`isLowSupply`).
- **One-Tap Refill**: Instant `+30 Refill` action button updating stock counts reactively.

### 💬 AI Clinical Health Assistant
- **Interactive Health Q&A**: Intelligent assistant for medical advice, diet tips, and prescription clarification.
- **Built-in Safety Disclaimers**: Automatic clinical safety disclaimers for patient protection.
### 5. Add Medication Schedule Modal
- **Custom Schedule Entry**: Bottom sheet form allowing users to enter new medicine names, dosages, dose times, and time-of-day slots.
- **Unique UUID Assignment**: Generates unique IDs via `Uuid()` and updates state via Riverpod `remindersProvider`.

### 🏋️ Recovery & Care Plans
- **Rehabilitation Tracking**: Post-surgery and chronic recovery meal plans, diet guidance, and movement exercises.
- **Progress Tracking**: Daily recovery task completion indicators.

### 👨‍👩‍👧 Family & Caregiver Connect
- **Dependent Monitoring**: View and manage health logs for family members or elderly dependents.
- **Emergency Notifications**: Immediate alert dispatches for critical vital thresholds.

---

## 🏗️ Architecture & Technology Stack
## 📁 Task 4 File Structure

VistaCortex follows **Feature-First Clean Architecture** with unidirectional data flow powered by **Riverpod 2.x**.

```
lib/
├── app.dart                                    # Main App Shell & Navigation
├── main.dart                                   # Application Entry Point & ProviderScope
├── core/
│   ├── config/                                 # AppColors, AppTheme, AppConstants
│   ├── security/                               # Security Audit Model & Service (SHA-256 Ledger)
│   ├── services/                               # AuthService, AnalyticsService
│   ├── storage/                                # SeedData for initial state & testing
│   └── utils/                                  # SafetyDisclaimer, TrendCalculator
└── features/
    ├── ai_chat/                                # AI Health Assistant UI & Logic
    ├── auth/                                   # Authentication, Profile Setup & Onboarding
    ├── dashboard/                              # Main Vitals & Health Overview
    ├── family_connect/                         # Caregiver & Dependent Care Platform
    ├── recovery_care/                          # Post-op Rehabilitation & Diet Plans
    ├── reminders/                              # Medication Reminders, Adherence & Refills
    ├── reports/                                # Medical Report OCR & Biomarker Tracking
    └── security/                               # Security Audit Ledger Inspection Screen
lib/features/reminders/
├── models/
│   └── reminder_model.dart       # MedicineReminder, DoseSchedule, DoseTimeOfDay, AdherenceStatus
├── providers/
│   └── reminders_provider.dart    # RemindersState, RemindersNotifier & Riverpod StateNotifierProvider
└── views/
    └── reminders_screen.dart     # 3-Tab UI (Doses, Refills, Tests), Adherence Ring, Filter Chips, Modals
```

---

## 🚀 Getting Started
## 🚀 Getting Started (`task-4` Branch)

### Prerequisites

Ensure you have the following installed on your machine:

- **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (v3.19.0 or higher)
- **[Dart SDK](https://dart.dev/get-dart)** (v3.3.0 or higher)
- **Android Studio** or **VS Code** with Flutter & Dart extensions
- **Android Emulator** or physical device (Android 8.0 / API 26+)

### Installation & Run

1. **Clone the Repository**:
1. **Get Dependencies**:
   ```bash
   git clone https://github.com/vistacortexadmin-blip/new-app-changes.git
   cd new-app-changes
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Code Analysis**:
2. **Analyze Code**:
   ```bash
   flutter analyze
   flutter analyze lib/features/reminders/
   ```

4. **Launch the Application**:
3. **Run Application**:
   ```bash
   flutter run
   ```

---

## 🛠️ Build & Troubleshooting Notes
## 🛠️ Windows Build Notes

### Kotlin Incremental Cache Issue (Windows Cross-Drive)
If building on Windows when the project is on a different drive (e.g. `D:\`) than the Flutter pub cache (`C:\`), Kotlin's incremental compiler might fail with a path resolution error.

This is automatically handled in `android/gradle.properties`:
If building on Windows where the project drive (e.g. `D:\`) differs from the Flutter Pub Cache drive (`C:\`), Kotlin incremental cache lock prevention is set in `android/gradle.properties`:
```properties
# Disable Kotlin incremental compilation for cross-drive builds
kotlin.incremental=false
kotlin.incremental.useClasspathSnapshot=false
```

If you encounter daemon cache lock issues:
```powershell
.\android\gradlew.bat --stop
flutter clean
flutter pub get
```

---

## 🔒 Security & Medical Disclaimer

> **IMPORTANT**: VistaCortex is designed as a personal health management tool and decision-support system. It does not replace professional medical diagnosis, treatment, or clinical judgement. Always consult a qualified healthcare provider for medical advice.

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
