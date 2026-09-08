# VistaCortex - Task 4: Medication & Reminders System 🩺

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod%202.x-blue)](https://riverpod.dev)
[![Branch](https://img.shields.io/badge/Branch-task--4-orange)]()

This branch (`task-4`) implements **Task 4: Medication Reminders, Refill Supply Management & Health Adherence Tracking** for the **VistaCortex** application.

---

## ⏰ Task 4 Implementation Highlights

### 1. Daily Adherence Ring & Progress Score
- **Interactive Progress Meter**: Calculates real-time daily compliance percentage based on taken vs. scheduled doses.
- **Dynamic Status Styling**: Visual indicator changes color dynamically (Emerald Success `≥ 80%`, Amber Warning `< 80%`).

### 2. Daily Dose Logging & Action System
- **Dose Actions**: Mark doses as **Taken** or **Skipped** directly from the daily schedule list.
- **Dose Deduction**: Marking a dose as *Taken* automatically decrements 1 pill count from the available stock.
- **Skip Reason Dialog**: Marking a dose as *Skipped* opens a modal dialog requiring a skip reason (e.g., side effects, nauseous, election) for clinical audit trails.

### 3. Time-of-Day Dose Filtering
- **Interactive Chips**: Filter medication schedules by time slot:
  - 🌅 **Morning**
  - ☀️ **Afternoon**
  - 🌆 **Evening**
  - 🌙 **Night**

### 4. Pill Inventory & Refill Supply Management
- **Stock Tracking**: Real-time days-of-supply remaining counter (`totalQuantityAvailable / dailyDoseCount`).
- **Low Stock Alerts**: Highlighted warning cards when supply drops below 5 days (`isLowSupply`).
- **One-Tap Refill**: Instant `+30 Refill` action button updating stock counts reactively.

### 5. Add Medication Schedule Modal
- **Custom Schedule Entry**: Bottom sheet form allowing users to enter new medicine names, dosages, dose times, and time-of-day slots.
- **Unique UUID Assignment**: Generates unique IDs via `Uuid()` and updates state via Riverpod `remindersProvider`.

---

## 📁 Task 4 File Structure

```
lib/features/reminders/
├── models/
│   └── reminder_model.dart       # MedicineReminder, DoseSchedule, DoseTimeOfDay, AdherenceStatus
├── providers/
│   └── reminders_provider.dart    # RemindersState, RemindersNotifier & Riverpod StateNotifierProvider
└── views/
    └── reminders_screen.dart     # 3-Tab UI (Doses, Refills, Tests), Adherence Ring, Filter Chips, Modals
```

---

## 🚀 Getting Started (`task-4` Branch)

1. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Analyze Code**:
   ```bash
   flutter analyze lib/features/reminders/
   ```

3. **Run Application**:
   ```bash
   flutter run
   ```

---

## 🛠️ Windows Build Notes

If building on Windows where the project drive (e.g. `D:\`) differs from the Flutter Pub Cache drive (`C:\`), Kotlin incremental cache lock prevention is set in `android/gradle.properties`:
```properties
kotlin.incremental=false
kotlin.incremental.useClasspathSnapshot=false
```
