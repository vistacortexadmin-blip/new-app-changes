import '../models/report_model.dart';

abstract class ReportsRepository {
  Future<List<MedicalReport>> loadReports();

  Future<void> saveReports(List<MedicalReport> reports);

  Future<String> storeDocument({
    required String sourcePath,
    required String originalFileName,
  });

  Future<void> deleteDocument(MedicalReport report);
}
