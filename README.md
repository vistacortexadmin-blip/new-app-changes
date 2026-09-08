# VistaCortex 🩺

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod%202.x-blue)](https://riverpod.dev)
[![Branch](https://img.shields.io/badge/Branch-task--4-orange)]()

**VistaCortex** is an intelligent personal health assistant and clinical management platform built with **Flutter** and **Riverpod**.

---

## 🚀 Task 4: Implemented Features

This branch (`task-4`) contains the full implementation of **Task 4: Medication Reminders, Refill Supply Management & Health Adherence System**.

### 1. 📊 Daily Adherence Progress Ring
- **Real-time Adherence Score**: Calculates compliance percentage (`taken Doses / total Doses`).
- **Dynamic Color Coding**: Changes dynamically between Success (`≥ 80%`) and Warning (`< 80%`).
- **Motivational Progress Messaging**: Displays encouragement text based on adherence history.

### 2. 💊 Medication & Dose Management
- **Dose Action Buttons**:
  - **Taken**: Marks dose as taken, records timestamp (`loggedAt`), and decrements 1 pill from inventory.
  - **Skip**: Triggers a modal dialog prompting the user for a skip reason (e.g. side effects, nauseous) for clinical compliance audit.
- **Status Banners**: Renders clear visual badges for *Dose Taken* or *Dose Skipped* with recorded reasons.

### 3. ⏰ Time-of-Day Dose Filtering
- **Interactive Chip Bar**: Filter scheduled daily doses by time slot:
  - 🌅 **Morning**
  - ☀️ **Afternoon**
  - 🌆 **Evening**
  - 🌙 **Night**

### 4. 📦 Pill Inventory & Refill Supply Tracking
- **Days of Supply Calculation**: Computes remaining supply (`totalQuantityAvailable / dailyDoseCount`).
- **Low-Stock Warnings**: Highlights medicines with 5 days or less supply remaining in Amber.
- **+30 Refill Action**: Increases stock count by 30 pills reactively upon ordering refills.

### 5. ➕ Add Medicine Schedule Modal
- **Stateful Bottom Sheet Modal**: Form allowing users to input:
  - Medicine Name
  - Dosage (e.g. `500mg`, `1 Tablet`)
  - Time string (e.g. `08:00 AM`)
  - Time-of-Day dropdown selector (`morning`, `afternoon`, `evening`, `night`)
- **Automated ID Generation**: Uses `Uuid().v4()` and updates Riverpod `remindersProvider`.

---

## 📁 Task 4 Architecture & Files

```
lib/features/reminders/
├── models/
│   └── reminder_model.dart       # MedicineReminder, DoseSchedule, DoseTimeOfDay, AdherenceStatus
├── providers/
│   └── reminders_provider.dart    # RemindersState & RemindersNotifier (Riverpod)
└── views/
    └── reminders_screen.dart     # 3-Tab View (Doses, Refills, Tests), Adherence Ring, Action Dialogs
```

---

## 🛠️ Build & Configuration Fixes

- **Kotlin Incremental Build Fix**: Added `kotlin.incremental=false` and `kotlin.incremental.useClasspathSnapshot=false` to `android/gradle.properties` to fix Windows cross-drive path resolution crashes between `D:\` project root and `C:\` Flutter Pub cache.
- **Deprecation Cleanups**: Updated `DropdownButtonFormField` to `initialValue`.

---

## 🚀 Getting Started

1. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Analyze Project**:
   ```bash
   flutter analyze
   ```

3. **Run Application**:
   ```bash
   flutter run
   ```
