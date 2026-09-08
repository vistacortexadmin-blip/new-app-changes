# VistaCortex 🩺

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod%202.x-blue)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS%20|%20Web-brightgreen)]()

**VistaCortex** is an intelligent personal health assistant and clinical management platform built with **Flutter** and **Riverpod**. Designed with a modern Material 3 design system, VistaCortex empowers patients and care teams with smart reminder schedules, AI-assisted medical report parsing, recovery tracking, family caregiver connectivity, and a tamper-evident HIPAA security audit trail.

---

## ✨ Key Features

### ⏰ Medication & Dose Reminders
- **Daily Adherence Tracking**: Real-time progress ring scoring daily dose compliance.
- **Dose Management**: Log doses as **Taken** or **Skipped** (with mandatory reason recording).
- **Time-of-Day Filtering**: Filter doses by *Morning*, *Afternoon*, *Evening*, or *Night*.
- **Refill & Stock Management**: Inventory tracking for pills remaining with automatic low-stock alerts.
- **Add Medicine Modal**: Schedule custom medications with dosage instructions and custom times.

### 📄 Medical Report Scanner & Biomarker Trends
- **Report OCR & Parsing**: Upload medical reports (Lab Results, Prescriptions) for smart parsing.
- **Biomarker Analysis**: Track HbA1c, Fasting Blood Sugar, Lipid Profile, and Blood Pressure.
- **Visual Trend Calculator**: Automated assessment of clinical progress over time.

### 🛡️ Cryptographic Security Audit Ledger
- **HIPAA-Compliant PHI Logging**: Full audit trail recording all Protected Health Information access and mutations.
- **SHA-256 Tamper-Evident Ledger**: Cryptographic hash chaining ensures audit entries cannot be modified or forged.
- **Audit Inspector Screen**: Built-in verification UI to audit system integrity and inspect compliance logs.

### 📊 Smart Health Dashboard
- **Vitals Overview**: Real-time monitoring of Heart Rate, Blood Sugar, SpO2, and Sleep.
- **Clinical Status Badges**: Instant visual feedback for normal, borderline, and elevated vitals.
- **Emergency SOS Shortcut**: Quick access to trigger family/caregiver emergency protocols.

### 💬 AI Clinical Health Assistant
- **Interactive Health Q&A**: Intelligent assistant for medical advice, diet tips, and prescription clarification.
- **Built-in Safety Disclaimers**: Automatic clinical safety disclaimers for patient protection.

### 🏋️ Recovery & Care Plans
- **Rehabilitation Tracking**: Post-surgery and chronic recovery meal plans, diet guidance, and movement exercises.
- **Progress Tracking**: Daily recovery task completion indicators.

### 👨‍👩‍👧 Family & Caregiver Connect
- **Dependent Monitoring**: View and manage health logs for family members or elderly dependents.
- **Emergency Notifications**: Immediate alert dispatches for critical vital thresholds.

---

## 🏗️ Architecture & Technology Stack

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
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your machine:

- **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (v3.19.0 or higher)
- **[Dart SDK](https://dart.dev/get-dart)** (v3.3.0 or higher)
- **Android Studio** or **VS Code** with Flutter & Dart extensions
- **Android Emulator** or physical device (Android 8.0 / API 26+)

### Installation & Run

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/vistacortexadmin-blip/new-app-changes.git
   cd new-app-changes
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Code Analysis**:
   ```bash
   flutter analyze
   ```

4. **Launch the Application**:
   ```bash
   flutter run
   ```

---

## 🛠️ Build & Troubleshooting Notes

### Kotlin Incremental Cache Issue (Windows Cross-Drive)
If building on Windows when the project is on a different drive (e.g. `D:\`) than the Flutter pub cache (`C:\`), Kotlin's incremental compiler might fail with a path resolution error.

This is automatically handled in `android/gradle.properties`:
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
