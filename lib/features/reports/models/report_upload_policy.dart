class ReportUploadPolicy {
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
  static const int maxVaultSizeBytes = 100 * 1024 * 1024;

  static const String maxFileSizeLabel = '10 MB';
  static const String maxVaultSizeLabel = '100 MB';

  const ReportUploadPolicy._();

  static bool isFileSizeAllowed(int bytes) =>
      bytes > 0 && bytes <= maxFileSizeBytes;
}

class EmptyReportFileException implements Exception {
  const EmptyReportFileException();
}

class ReportFileTooLargeException implements Exception {
  final int actualBytes;

  const ReportFileTooLargeException(this.actualBytes);
}

class ReportVaultFullException implements Exception {
  const ReportVaultFullException();
}
