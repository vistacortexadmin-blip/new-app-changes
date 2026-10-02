import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/report_upload_policy.dart';

class StoredReportDocument {
  final String path;
  final String originalFileName;

  const StoredReportDocument({
    required this.path,
    required this.originalFileName,
  });
}

class ReportFileService {
  final Future<Directory> Function() _documentsDirectory;
  final Uuid _uuid;
  final int _maxFileSizeBytes;
  final int _maxVaultSizeBytes;

  ReportFileService({
    Future<Directory> Function()? documentsDirectory,
    Uuid? uuid,
    int maxFileSizeBytes = ReportUploadPolicy.maxFileSizeBytes,
    int maxVaultSizeBytes = ReportUploadPolicy.maxVaultSizeBytes,
  })  : _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory,
        _uuid = uuid ?? const Uuid(),
        _maxFileSizeBytes = maxFileSizeBytes,
        _maxVaultSizeBytes = maxVaultSizeBytes;

  Future<Directory> get _storageDirectory async {
    final root = await _documentsDirectory();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}medical_reports',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<StoredReportDocument> copyIntoVault({
    required String sourcePath,
    required String originalFileName,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const FileSystemException('The selected document is unavailable.');
    }

    final sourceSize = await source.length();
    if (sourceSize <= 0) {
      throw const EmptyReportFileException();
    }
    if (sourceSize > _maxFileSizeBytes) {
      throw ReportFileTooLargeException(sourceSize);
    }

    final extension = _safeExtension(originalFileName, sourcePath);
    final directory = await _storageDirectory;
    final storedBytes = await _storedBytes(directory);
    if (storedBytes + sourceSize > _maxVaultSizeBytes) {
      throw const ReportVaultFullException();
    }
    final destination = File(
      '${directory.path}${Platform.pathSeparator}report_${_uuid.v4()}$extension',
    );
    await source.copy(destination.path);

    return StoredReportDocument(
      path: destination.path,
      originalFileName: originalFileName,
    );
  }

  Future<void> deleteFromVault(String path) async {
    if (path.trim().isEmpty) return;

    final directory = await _storageDirectory;
    final vaultPrefix =
        '${directory.absolute.path}${Platform.pathSeparator}'.toLowerCase();
    final file = File(path);
    final candidate = file.absolute.path.toLowerCase();

    // Never delete arbitrary asset or external paths.
    if (!candidate.startsWith(vaultPrefix)) return;
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _safeExtension(String fileName, String sourcePath) {
    final candidate = fileName.contains('.') ? fileName : sourcePath;
    final dot = candidate.lastIndexOf('.');
    if (dot < 0 || dot == candidate.length - 1) return '';
    final extension = candidate.substring(dot).toLowerCase();
    return RegExp(r'^\.[a-z0-9]{1,8}$').hasMatch(extension) ? extension : '';
  }

  Future<int> _storedBytes(Directory directory) async {
    var total = 0;
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }
}
