import '../../features/reports/models/report_model.dart';
import '../../features/reminders/models/reminder_model.dart';
import '../../features/recovery_care/models/recovery_model.dart';
import '../../features/family_connect/models/family_model.dart';
import '../../features/family_connect/models/shared_activity_model.dart';
import '../../features/test_booking/models/test_booking_model.dart';

class SeedData {
  static List<MedicalReport> get initialReports => [];
  static List<MedicineReminder> get initialReminders => [];
  static List<NextTestReminder> get initialNextTests => [];
  static dynamic get initialDietPlan => null;
  static List<FamilyMember> get initialFamilyMembers => [];
  static List<SharedActivityLog> get initialActivityLogs => [];
  static List<DiagnosticProvider> get diagnosticProviders => [];
  static List<BookableTest> get bookableTests => [];
}
