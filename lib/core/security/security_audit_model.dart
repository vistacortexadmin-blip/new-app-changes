import 'dart:convert';
import 'package:crypto/crypto.dart';

enum AuditActionType {
  authLoginSuccess,
  authLoginFailure,
  authLogout,
  authSessionExpired,
  phiReportViewed,
  phiReportUploaded,
  phiReportExported,
  phiParameterTrendAnalyzed,
  medicationTaken,
  medicationSkipped,
  medicationRefillRequested,
  familyCaregiverInvited,
  familyPermissionModified,
  familyPermissionRevoked,
  emergencySosTriggered,
  dataExportRequested,
  securityAnomalyDetected,
  integrityVerificationPerformed,
}

enum AuditResourceType {
  authSession,
  phiMedicalReport,
  medicationSchedule,
  familyAccessControl,
  emergencySos,
  systemSecurity,
}

enum AuditOutcome {
  success,
  denied,
  failure,
}

enum DataClassification {
  phi,       // Protected Health Information (HIPAA)
  pii,       // Personally Identifiable Information (GDPR)
  security,  // Access tokens, auth, permissions
  general,   // Operational telemetry
}

class SecurityAuditEvent {
  final String id;
  final DateTime timestamp;
  final String actorId;
  final String actorRole;
  final String actorEmail;
  final String sessionId;
  final AuditActionType actionType;
  final AuditResourceType resourceType;
  final String resourceId;
  final DataClassification dataClassification;
  final AuditOutcome outcome;
  final String? failureReason;
  final String originIp;
  final String deviceId;
  final Map<String, dynamic> metadata;
  final String previousHash;
  final String hash;

  SecurityAuditEvent({
    required this.id,
    required this.timestamp,
    required this.actorId,
    required this.actorRole,
    required this.actorEmail,
    required this.sessionId,
    required this.actionType,
    required this.resourceType,
    required this.resourceId,
    required this.dataClassification,
    required this.outcome,
    this.failureReason,
    required this.originIp,
    required this.deviceId,
    required this.metadata,
    required this.previousHash,
    required this.hash,
  });

  /// Computes the cryptographic SHA-256 hash for this audit record
  static String computeHash({
    required String id,
    required DateTime timestamp,
    required String actorId,
    required String actionType,
    required String resourceId,
    required String outcome,
    required String previousHash,
    required Map<String, dynamic> metadata,
  }) {
    final payload = '$previousHash|$id|${timestamp.toUtc().toIso8601String()}|$actorId|$actionType|$resourceId|$outcome|${jsonEncode(metadata)}';
    final bytes = utf8.encode(payload);
    return sha256.convert(bytes).toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'actorId': actorId,
      'actorRole': actorRole,
      'actorEmail': actorEmail,
      'sessionId': sessionId,
      'actionType': actionType.name,
      'resourceType': resourceType.name,
      'resourceId': resourceId,
      'dataClassification': dataClassification.name,
      'outcome': outcome.name,
      'failureReason': failureReason,
      'originIp': originIp,
      'deviceId': deviceId,
      'metadata': metadata,
      'previousHash': previousHash,
      'hash': hash,
    };
  }

  factory SecurityAuditEvent.fromMap(Map<String, dynamic> map) {
    return SecurityAuditEvent(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      actorId: map['actorId'] as String? ?? 'unknown',
      actorRole: map['actorRole'] as String? ?? 'patient',
      actorEmail: map['actorEmail'] as String? ?? '',
      sessionId: map['sessionId'] as String? ?? '',
      actionType: AuditActionType.values.firstWhere(
        (e) => e.name == map['actionType'],
        orElse: () => AuditActionType.phiReportViewed,
      ),
      resourceType: AuditResourceType.values.firstWhere(
        (e) => e.name == map['resourceType'],
        orElse: () => AuditResourceType.phiMedicalReport,
      ),
      resourceId: map['resourceId'] as String? ?? '',
      dataClassification: DataClassification.values.firstWhere(
        (e) => e.name == map['dataClassification'],
        orElse: () => DataClassification.phi,
      ),
      outcome: AuditOutcome.values.firstWhere(
        (e) => e.name == map['outcome'],
        orElse: () => AuditOutcome.success,
      ),
      failureReason: map['failureReason'] as String?,
      originIp: map['originIp'] as String? ?? '127.0.0.1',
      deviceId: map['deviceId'] as String? ?? 'mobile_device',
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
      previousHash: map['previousHash'] as String? ?? 'GENESIS',
      hash: map['hash'] as String? ?? '',
    );
  }

  String toJson() => jsonEncode(toMap());
  factory SecurityAuditEvent.fromJson(String source) =>
      SecurityAuditEvent.fromMap(jsonDecode(source) as Map<String, dynamic>);
}

class AuditIntegrityReport {
  final int totalRecords;
  final bool isChainIntact;
  final int? compromisedIndex;
  final String? rootHash;
  final String? latestHash;
  final DateTime verifiedAt;
  final String message;

  AuditIntegrityReport({
    required this.totalRecords,
    required this.isChainIntact,
    this.compromisedIndex,
    this.rootHash,
    this.latestHash,
    required this.verifiedAt,
    required this.message,
  });
}
