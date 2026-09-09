# VistaCortex - Task 4: Medication & Reminders System

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod%202.x-blue)](https://riverpod.dev)
This document covers the current **Task 4: Medication Reminders, Refill Supply Management & Health Adherence Tracking** implementation for **VistaCortex**, including the diagnostic-test controls already present in the shared Reminders screen. It does not describe a new Task 5 implementation or imply that changes have been merged into `main`.

---

## Task 4 Implementation Highlights

### Reminders Screen
- Three tabs: **Doses**, **Refills**, and **Tests**.
- The header **+** button opens an action sheet with **Add Medicine Reminder** and **Schedule Diagnostic Test**.
- Riverpod updates the visible schedule, adherence score, inventory, and test status when the corresponding state changes.

### 1. Daily Adherence Ring & Progress Score
- **Progress calculation**: Taken schedules divided by all schedules across all medicines, including pending and skipped schedules in the denominator. Returns zero when there are no schedules.
- **Display**: A circular progress indicator and integer percentage, independent of the selected time-of-day filter.
- **Status colors**: Success at `>= 80%`; warning below `80%`.

### 2. Daily Dose Logging & Action System
- **Dose cards**: Show medicine name, dosage, and the entered time string.
- **Pending-dose actions**: **Taken** records the status and current `loggedAt` timestamp and deducts one pill from stock, with a lower bound of zero.
- **Skip dialog**: Supports **Cancel** and **Submit**. Submitting records the status, timestamp, and free-text reason without deducting stock. An empty reason defaults to `Patient elected to skip`.
- **Completed action state**: Taken or skipped doses display a colored status banner instead of action buttons; skipped doses also display their reason.
- **Provider-level bulk action**: `markAllDosesTaken(timeOfDay)` marks only pending doses in the selected period, uses one timestamp, and deducts stock for each affected schedule. This method exists in the provider but is not exposed by the Reminders screen.

### 3. Time-of-Day Dose Filtering
- **Selectable periods**: Morning, Afternoon, Evening, and Night, with Morning selected initially.
- **Filtered list**: Shows schedules matching the selected period, including already taken or skipped doses.
- **Empty state**: Displays `No medicines scheduled for this time.` when no schedules match.

### 4. Pill Inventory & Refill Supply Management
- **Inventory cards**: Show every medicine's name, current pill count, and whole days of supply remaining.
- **Supply calculation**: `floor(totalQuantityAvailable / dailyDoseCount)`; returns zero when the daily dose count is zero or negative.
- **Low-stock warning**: Warning border and badge when supply is **five days or fewer** (`isLowSupply`).
- **One-tap refill**: The **+30 Refill** button appears only for low-supply medicines. It adds **30 pills**, updates state, and shows a confirmation. This is not necessarily 30 days of supply and does not place a pharmacy order.
- **Model helpers**: `isCriticalSupply` identifies supply of two days or fewer; `estimatedRefillDate` adds the remaining supply days to the current time. These helpers are not displayed separately in the Refills tab.
- **Empty state**: Displays `No medicines found.` when the medicine list is empty.

### 5. Add Medication Schedule Modal
- **Input fields**: Medicine name, dosage, total pills in the box, pills per day, a free-text time, and a time-of-day dropdown.
- **Defaults**: 30 pills, one pill per day, and Morning. Invalid integer input falls back to 30 pills or one pill per day respectively.
- **Required input**: Name and time must be nonempty before saving. There is no time-format or positive-quantity validation.
- **Created record**: UUID v4 ID, one pending dose schedule, current start date, a fixed 30-day duration, and empty instructions and prescribed-for fields.
- **Save behavior**: Appends the medicine to provider state, closes the keyboard-aware, scrollable bottom sheet, and shows `Reminder schedule saved!`.
- **Schedule distinction**: The pills-per-day field controls supply calculation; entering a value greater than one does not create additional dose schedules.

### 6. Existing Diagnostic-Test Controls

These controls already share the Reminders module; documenting them does not create a separate task or branch.

- **Schedule form**: Test name, clinic/lab name, preparation instructions, and a date picker. The initial date is seven days ahead; the selectable range runs from today through 365 days ahead.
- **Save behavior**: Requires a nonempty test name, defaults an empty clinic name to `TBD Clinic`, generates a UUID v4 ID, and prepends an incomplete test to state. The sheet closes and a confirmation appears.
- **Test cards**: Show the test name, clinic/lab, preparation instructions, and a status badge: `In N Days`, `Overdue`, or `Completed`.
- **Date helpers**: Days remaining are calculated relative to today's midnight; an incomplete test is overdue when that value is negative.
- **Completion**: **Mark Completed** updates the matching test while preserving its other fields. Completed tests remain in the list, with a success badge and without the completion button.
- **Empty state**: Displays `No upcoming diagnostic tests scheduled.` when there are no test records.
- **Related-report support**: The model includes an optional `relatedReportId`; the add form does not select a report.

## State and Data Model

- `DoseSchedule`: Time-of-day enum, displayed time string, pending/taken/skipped status, optional logging timestamp, and optional skip reason.
- `MedicineReminder`: ID, name, dosage, instructions, prescribed-for value, daily schedules, inventory, daily dose count, start date, duration, and optional warning, with supply helpers and `copyWith` updates.
- `NextTestReminder`: ID, test and clinic names, scheduled date, preparation instructions, completion state, and optional related report.
- `RemindersState`: Medicine and test lists plus the selected time filter. Derived getters expose low-supply medicines, incomplete tests, pending-dose count, and adherence. The Tests tab displays the full test list, not just the `upcomingTests` getter.
- `RemindersNotifier`: Handles filtering, individual and bulk dose logging, skipping, refilling, adding medicines/tests, and completing tests through `remindersProvider` (`StateNotifierProvider`).
- Initial records come from `SeedData.initialReminders` and `SeedData.initialNextTests`.

## Current Boundaries

- Reminder changes are held in memory. This module does not save them to local storage or a backend; provider recreation or an app restart restores seed data.
- There is no automatic daily dose reset, historical adherence log, background alarm, or local/push notification scheduling in this module. The displayed daily score reflects the schedules currently held in state.
- Refills and test completion are local state updates, not pharmacy orders, lab bookings, or doctor notifications, regardless of confirmation wording.
- The current screen does not provide edit/delete controls, dose undo, or a multi-time schedule editor.
- The test-completion handler currently contains malformed `SnackBar` code in the source. That is a known validation blocker, not a working doctor-notification integration; this documentation-only update does not repair application code.

---

## Task 4 Source Files

| File | Responsibility |
| --- | --- |
| [lib/features/reminders/models/reminder_model.dart](lib/features/reminders/models/reminder_model.dart) | Medication, dose, and diagnostic-test models and derived helpers |
| [lib/features/reminders/providers/reminders_provider.dart](lib/features/reminders/providers/reminders_provider.dart) | Riverpod state, computed summaries, and reminder mutations |
| [lib/features/reminders/views/reminders_screen.dart](lib/features/reminders/views/reminders_screen.dart) | Three-tab screen, cards, filters, dialogs, and add forms |
| [lib/core/storage/seed_data.dart](lib/core/storage/seed_data.dart) | Initial medicine and diagnostic-test records |
| [pubspec.yaml](pubspec.yaml) | SDK constraints and dependencies, including Riverpod `^2.5.1` and UUID `^4.4.0` |

---

## Getting Started

Use a Flutter SDK compatible with the project APIs and the Dart constraint `>=3.0.0 <4.0.0`. Run the following from the application root, not the nested Flutter SDK directory. An Android emulator/device and the application's Firebase configuration are needed for the corresponding app integrations.

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

## Windows Build Notes

If building on Windows where the project drive (e.g. `D:\`) differs from the Flutter Pub Cache drive (`C:\`), Kotlin incremental cache lock prevention is set in `android/gradle.properties`:
```properties
kotlin.incremental=false
kotlin.incremental.useClasspathSnapshot=false
```

