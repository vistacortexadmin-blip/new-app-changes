# VistaCortex - Core Features Architecture & Developer Process Guide

Welcome to the **VistaCortex** developer and implementation roadmap. This document outlines the technical architecture, file locations, state management flows, and step-by-step development process for each of the **8 core features** of the mobile application.

---

## 🏗️ Architectural Overview

The application is built with **Flutter** and **Riverpod** following the **Feature-First Architecture**:

```
lib/
├── app.dart                                # Main App Shell & 5-Tab Navigation Bar
├── main.dart                               # Entry point & ProviderScope initialization
├── core/
│   ├── config/                             # AppColors, Theme, and global constants
│   ├── storage/                            # Seed data and mock storage
│   └── utils/                              # Safety disclaimer, trend calculation utilities
└── features/
    ├── auth/                               # Onboarding & Welcome screens
    ├── dashboard/                          # Home dashboard summarizing all vitals & alerts
    ├── reports/                            # Features 1 & 2 (Storage, Analysis, Diet Plan)
    ├── reminders/                          # Features 3, 4 & 5 (Meds, Refills, Next Tests)
    ├── recovery_care/                      # Feature 6 (Surgery Care & Clinical Recovery)
    ├── test_booking/                       # Feature 7 (Diagnostic Lab Test Booking)
    ├── family_connect/                     # Feature 8 (Emergency SOS & Caregiver Access)
    └── ai_chat/                            # AI Clinical Assistant & Gemini Chat
```

Each feature folder strictly adheres to:
- `models/` - Dart data structures with serialization & helper methods.
- `providers/` - Riverpod `StateNotifier` / `Notifier` holding state & business logic.
- `views/` - Flutter UI widgets (`ConsumerWidget` / `ConsumerStatefulWidget`).

---

## 📋 The 8 Core Features

---

### Feature 1: Medical Test Report Storage & Test Diet Plan

#### Purpose
Organizes and archives diagnostic test records (e.g., Blood tests, MRI scans, Lipid profiles) and provides direct access to dietary recommendations customized to the patient's lab findings.

#### Key Files
- **Screen**: `lib/features/reports/views/reports_screen.dart`
- **Diet Plan Tab**: `lib/features/reports/views/report_details_screen.dart` (Diet Plan tab)
- **PDF Viewer Modal**: `lib/features/reports/views/pdf_view_modal.dart`
- **State Provider**: `lib/features/reports/providers/reports_provider.dart`
- **Model**: `lib/features/reports/models/report_model.dart`

#### Step-by-Step Development Process
1. **Explore in UI**: Open the app -> Tap **Reports** tab (2nd icon in bottom bar) -> View test cards and tap the floating **`+ Upload`** button.
2. **Modify Seed Data**: Add new test categories or initial test records inside `lib/core/storage/seed_data.dart`.
3. **Backend API Integration**:
   - In `reports_provider.dart`, replace `simulateUploadReport()` with an `http`/`dio` multipart request to upload user PDFs or images to AWS S3, Google Cloud Storage, or your secure medical backend.
   - Fetch the list of user reports dynamically on user login via a GET request (`/api/v1/reports`).

---

### Feature 2: Medical Report Analysis

#### Purpose
Transforms unstructured laboratory reports into actionable patient insights:
- Extracts critical biomarkers with color-coded ranges (`Normal`, `Borderline`, `Critical High/Low`).
- Generates plain-English clinical summaries eliminating difficult medical jargon.
- Suggests customized questions for the patient to ask their doctor.
- Tracks biomarker trendlines across historical visits.

#### Key Files
- **Analysis View**: `lib/features/reports/views/report_details_screen.dart`
- **Biomarker Trends**: `lib/features/reports/views/parameter_trend_screen.dart`
- **Trend Calculation Engine**: `lib/core/utils/trend_calculator.dart`

#### Step-by-Step Development Process
1. **Explore in UI**: On the Reports screen, tap any report (e.g., *Comprehensive Metabolic Panel*) -> Tap the **Analysis** tab. Tap any parameter to view historical trend sparklines.
2. **AI Engine Integration**:
   - Connect the OCR/Extraction pipeline: send uploaded lab report images/PDFs to Gemini 1.5 Flash (or your backend analysis microservice) with a structured JSON schema.
   - Parse the response into `ReportParameter` objects (`name`, `value`, `unit`, `referenceRange`, `status`).

---

### Feature 3: Next Test & Follow-up Reminder

#### Purpose
Ensures patients never miss crucial diagnostic screenings, chronic disease monitoring, or post-treatment reviews. Includes pre-test instructions (e.g., 12-hour fasting) and 1-tap booking.

#### Key Files
- **Screen**: `lib/features/reminders/views/reminders_screen.dart` (see `_buildNextTestsTab`)
- **State Provider**: `lib/features/reminders/providers/reminders_provider.dart`
- **Model**: `lib/features/reminders/models/reminder_model.dart` (see `NextScheduledTest`)

#### Step-by-Step Development Process
1. **Explore in UI**: Tap the **Reminders** tab (4th icon in bottom bar) -> Switch to the **Tests** tab.
2. **Mark as Completed**: Tap the checkmark icon to mark a test completed and archive it.
3. **Local & Push Notifications**:
   - Connect `flutter_local_notifications` to schedule alerts 24 hours and 2 hours prior to fasting start times.
   - Link the **"Book Test"** button to open `TestBookingScreen` pre-populated with the test name.

---

### Feature 4: Medicine / Tablet Reminder

#### Purpose
Daily dosing adherence system grouped into Morning, Afternoon, Evening, and Night with a real-time progress indicator ring and clinical skip-reason tracking.

#### Key Files
- **Screen**: `lib/features/reminders/views/reminders_screen.dart` (see `_buildDailyDosesTab`)
- **Add Medicine Modal**: `_showAddMedicineModal()` inside `reminders_screen.dart`
- **State Provider**: `lib/features/reminders/providers/reminders_provider.dart`
- **Model**: `lib/features/reminders/models/reminder_model.dart` (see `MedicineDose`)

#### Step-by-Step Development Process
1. **Explore in UI**: On the Reminders screen, tap **"Taken"** on any medicine card. Watch the circular progress ring update. Tap **"Skipped"** to view and submit a clinical reason.
2. **Add New Medication**: Tap the **`+`** icon in the app bar to test adding a new prescription schedule.
3. **Adherence Logging**: Sync dose records to your backend DB (`/api/v1/adherence/log`) to generate physician compliance reports.

---

### Feature 5: Medication Refill Alert

#### Purpose
Smart pill inventory tracker that counts remaining doses, forecasts running-out dates, highlights low stock warnings (< 7 days), and provides a 1-tap refill button.

#### Key Files
- **Screen**: `lib/features/reminders/views/reminders_screen.dart` (see `_buildRefillSupplyTab`)
- **State Logic**: `reminders_provider.dart` (`refillStock(medicineId, count)`)

#### Step-by-Step Development Process
1. **Explore in UI**: On the Reminders screen, tap the **Refills** tab. Observe the remaining days badge. Tap **"+30 Refill"** to replenish stock.
2. **Pharmacy API Integration**:
   - In `refillStock()`, trigger an external e-pharmacy order API (e.g., Apollo, 1mg, or in-hospital pharmacy) to order medicines automatically when inventory falls below 5 days.

---

### Feature 6: Surgery Care & Recovery Plan

#### Purpose
Post-operative management dashboard providing:
- Milestone tracking (e.g., "Day 14 Post-Op").
- Interactive 1–10 pain severity logger.
- Daily wound care, breathing exercise, and mobility task checklists.
- Specialized post-surgical high-protein & anti-inflammatory nutrition guidelines.

#### Key Files
- **Screen**: `lib/features/recovery_care/views/recovery_care_screen.dart`
- **State Provider**: `lib/features/recovery_care/providers/recovery_diet_provider.dart`
- **Model**: `lib/features/recovery_care/models/recovery_model.dart`

#### Step-by-Step Development Process
1. **Explore in UI**: Open the app -> Tap **More** (5th bottom nav icon) -> Tap **Surgery Care** (or tap the Surgery banner on the Home Dashboard).
2. **Test Interactivity**: Tap numbers on the 1–10 Pain Scale and toggle care checklist items. Switch to the **Diet** tab to view nutrition plans.
3. **Clinical Escalation**:
   - In `recovery_diet_provider.dart`, trigger an automated SMS/alert to the surgical team or emergency contact if pain score >= 8.

---

### Feature 7: Test Booking

#### Purpose
Comprehensive lab test marketplace supporting home sample collection and hospital visit bookings, slot scheduling, patient details confirmation, and instant booking vouchers.

#### Key Files
- **Screen**: `lib/features/test_booking/views/test_booking_screen.dart`
- **State Provider**: `lib/features/test_booking/providers/test_booking_provider.dart`
- **Model**: `lib/features/test_booking/models/test_booking_model.dart`

#### Step-by-Step Development Process
1. **Explore in UI**: Access **Book Lab Test** from the **More** menu or Home Dashboard.
2. **Booking Flow**: Tap **"Book Now"** on any test card -> Select appointment date & time in the modal bottom sheet -> Tap **"Confirm Booking"**.
3. **Payment Gateway**:
   - Integrate Razorpay / Stripe / UPI before calling `bookTestSlot()`.
   - On successful payment, automatically add a reminder to **Feature 3 (Next Test Reminder)**.

---

### Feature 8: Family Connect

#### Purpose
Caregiver and emergency network hub:
- Emergency SOS speed dial.
- Multi-member family sharing with role-based access (`Full Access`, `View Only`, `Emergency Only`).
- Automated missed-dose alerts to designated caregivers.
- Transparent access audit log.

#### Key Files
- **Screen**: `lib/features/family_connect/views/family_connect_screen.dart`
- **State Provider**: `lib/features/family_connect/providers/family_connect_provider.dart`
- **Model**: `lib/features/family_connect/models/family_model.dart`

#### Step-by-Step Development Process
1. **Explore in UI**: Open the app -> Tap **More** -> Tap **Family Connect**.
2. **Invite Member**: Tap **"Invite Member"** to open the invitation modal with relationship and permission dropdowns.
3. **Caregiver Escalation**:
   - When a medication in **Feature 4** is skipped or missed past 2 hours, trigger a push notification to members with `Emergency Only` or `Full Access` permissions.

---

## 🚀 Daily Developer Workflow

1. **Open Project in Android Studio**
2. **Launch Pixel 9 Emulator** via Device Manager
3. **Select Pixel 9 in Top Toolbar & Click Run (Play)**
4. **Pick a Feature File to Modify**
5. **Press Ctrl + \ for Instant Hot Reload**
6. **Verify Changes on Live Emulator Screen**
7. **Build Release APK**: `flutter build apk --release`

### Quick Commands Reference

- **Run app on connected emulator**:
  ```powershell
  cd "c:\Users\sudha\Downloads\VISTACORTEX\new features app"
  & "C:\src\flutter\bin\flutter.bat" run
  ```

- **Build fresh production release APK**:
  ```powershell
  cd "c:\Users\sudha\Downloads\VISTACORTEX\new features app"
  & "C:\src\flutter\bin\flutter.bat" build apk --release
  ```

- **Install release APK onto emulator/phone directly**:
  ```powershell
  & "C:\Users\sudha\AppData\Local\Android\Sdk\platform-tools\adb.exe" install -r "c:\Users\sudha\Downloads\VISTACORTEX\VistaCortex_release.apk"
  ```
