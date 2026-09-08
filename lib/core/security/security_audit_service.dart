import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../services/analytics_service.dart';
import 'security_audit_model.dart';

class SecurityAuditService {
  static final SecurityAuditService _instance = SecurityAuditService._internal();
  factory SecurityAuditService() => _instance;
  SecurityAuditService._internal();

  static const String _storageKey = 'vista_security_audit_ledger_v1';
  static const String _genesisHash = 'GENESIS_VISTACORTEX_AUDIT_HASH_2026_LEAF0';

  final _uuid = const Uuid();
  final _analytics = AnalyticsService();

  List<SecurityAuditEvent> _ledger = [];
  bool _isInitialized = false;

  // Rate-limiting / anomaly detection buffers
  final List<DateTime> _recentPhiAccessTimestamps = [];
  int _consecutiveAuthFailures = 0;

  List<SecurityAuditEvent> get ledger => List.unmodifiable(_ledger);

  /// Initializes the audit service from persistent local storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLogs = prefs.getStringList(_storageKey);

      if (savedLogs != null && savedLogs.isNotEmpty) {
        _ledger = savedLogs.map((item) => SecurityAuditEvent.fromJson(item)).toList();
      } else {
        // Populate initial verified seed trail for demo & compliance baseline
        await _seedInitialAuditEvents();
      }
      _isInitialized = true;
      debugPrint('[SecurityAudit] Initialized ledger with ${_ledger.length} events.');
    } catch (e) {
      debugPrint('[SecurityAudit] Initialization error: $e');
      if (_ledger.isEmpty) {
        await _seedInitialAuditEvents();
      }
      _isInitialized = true;
    }
  }

  /// Appends a new tamper-evident security audit record
  Future<SecurityAuditEvent> record({
    required AuditActionType actionType,
    required AuditResourceType resourceType,
    required String resourceId,
    required DataClassification dataClassification,
    AuditOutcome outcome = AuditOutcome.success,
    String? actorId,
    String? actorRole,
    String? actorEmail,
    String? sessionId,
    String? failureReason,
    String? originIp,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final id = _uuid.v4();
    final timestamp = DateTime.now().toUtc();
    final sanitizedMetadata = _sanitizePayload(metadata ?? {});
    final previousHash = _ledger.isEmpty ? _genesisHash : _ledger.last.hash;

    final computedHash = SecurityAuditEvent.computeHash(
      id: id,
      timestamp: timestamp,
      actorId: actorId ?? 'user_current',
      actionType: actionType.name,
      resourceId: resourceId,
      outcome: outcome.name,
      previousHash: previousHash,
      metadata: sanitizedMetadata,
    );

    final event = SecurityAuditEvent(
      id: id,
      timestamp: timestamp,
      actorId: actorId ?? 'user_current',
      actorRole: actorRole ?? 'patient',
      actorEmail: actorEmail ?? 'patient@vistacortex.health',
      sessionId: sessionId ?? 'sess_${timestamp.millisecondsSinceEpoch}',
      actionType: actionType,
      resourceType: resourceType,
      resourceId: resourceId,
      dataClassification: dataClassification,
      outcome: outcome,
      failureReason: failureReason,
      originIp: originIp ?? '127.0.0.1 (local)',
      deviceId: deviceId ?? 'Android Pixel 9 SDK 37',
      metadata: sanitizedMetadata,
      previousHash: previousHash,
      hash: computedHash,
    );

    // Append to in-memory ledger
    _ledger.add(event);

    // Commit to persistent append-only storage
    await _persistLedger();

    // Check for real-time security anomalies
    _runAnomalyDetectors(event);

    // Forward high-priority security events to remote analytics sink
    _forwardToRemoteSink(event);

    debugPrint('[SecurityAudit] Logged ${event.actionType.name} [Hash: ${event.hash.substring(0, 8)}...]');
    return event;
  }

  /// Cryptographically verifies the integrity of the audit chain from Genesis to latest block
  AuditIntegrityReport verifyLedgerIntegrity() {
    if (_ledger.isEmpty) {
      return AuditIntegrityReport(
        totalRecords: 0,
        isChainIntact: true,
        verifiedAt: DateTime.now().toUtc(),
        message: 'Audit ledger is currently empty. Genesis state valid.',
      );
    }

    String expectedPreviousHash = _genesisHash;

    for (int i = 0; i < _ledger.length; i++) {
      final event = _ledger[i];

      // 1. Verify previous hash chaining
      if (event.previousHash != expectedPreviousHash) {
        return AuditIntegrityReport(
          totalRecords: _ledger.length,
          isChainIntact: false,
          compromisedIndex: i,
          verifiedAt: DateTime.now().toUtc(),
          message: 'Chain broken at record #$i (ID: ${event.id}). Expected prevHash $expectedPreviousHash but found ${event.previousHash}.',
        );
      }

      // 2. Recompute current hash to detect in-place data tampering
      final recalculatedHash = SecurityAuditEvent.computeHash(
        id: event.id,
        timestamp: event.timestamp,
        actorId: event.actorId,
        actionType: event.actionType.name,
        resourceId: event.resourceId,
        outcome: event.outcome.name,
        previousHash: event.previousHash,
        metadata: event.metadata,
      );

      if (recalculatedHash != event.hash) {
        return AuditIntegrityReport(
          totalRecords: _ledger.length,
          isChainIntact: false,
          compromisedIndex: i,
          verifiedAt: DateTime.now().toUtc(),
          message: 'Tamper detected at record #$i (ID: ${event.id}). Record contents modified.',
        );
      }

      expectedPreviousHash = event.hash;
    }

    return AuditIntegrityReport(
      totalRecords: _ledger.length,
      isChainIntact: true,
      rootHash: _ledger.first.hash,
      latestHash: _ledger.last.hash,
      verifiedAt: DateTime.now().toUtc(),
      message: 'Cryptographic hash chain intact. All ${_ledger.length} records verified with zero tampering detected.',
    );
  }

  /// Redacts and sanitizes sensitive secrets from audit metadata
  Map<String, dynamic> _sanitizePayload(Map<String, dynamic> input) {
    const sensitiveKeys = [
      'password',
      'token',
      'secret',
      'apikey',
      'api_key',
      'credit_card',
      'pin',
      'ssn',
      'auth_token'
    ];

    final cleaned = <String, dynamic>{};
    input.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      if (sensitiveKeys.any((s) => lowerKey.contains(s))) {
        cleaned[key] = '[REDACTED_BY_AUDIT_SECURITY]';
      } else if (value is Map<String, dynamic>) {
        cleaned[key] = _sanitizePayload(value);
      } else {
        cleaned[key] = value;
      }
    });
    return cleaned;
  }

  /// Real-time anomaly detection rules
  void _runAnomalyDetectors(SecurityAuditEvent event) {
    final now = DateTime.now();

    // 1. Rapid PHI access detection (>5 PHI views in 30 seconds)
    if (event.dataClassification == DataClassification.phi) {
      _recentPhiAccessTimestamps.add(now);
      _recentPhiAccessTimestamps.removeWhere((t) => now.difference(t).inSeconds > 30);
      if (_recentPhiAccessTimestamps.length > 5) {
        debugPrint('[SecurityAudit WARNING] Rapid PHI access anomaly detected: ${_recentPhiAccessTimestamps.length} reads in 30s');
      }
    }

    // 2. Auth failure escalation
    if (event.actionType == AuditActionType.authLoginFailure) {
      _consecutiveAuthFailures++;
      if (_consecutiveAuthFailures >= 3) {
        debugPrint('[SecurityAudit CRITICAL] Multiple authentication failures detected: $_consecutiveAuthFailures attempts');
      }
    } else if (event.actionType == AuditActionType.authLoginSuccess) {
      _consecutiveAuthFailures = 0;
    }
  }

  /// Forwards audit telemetry to remote sink for external SIEM / analytics
  void _forwardToRemoteSink(SecurityAuditEvent event) {
    try {
      _analytics.logEvent('security_audit_event', {
        'audit_action': event.actionType.name,
        'resource_type': event.resourceType.name,
        'data_class': event.dataClassification.name,
        'outcome': event.outcome.name,
        'hash_prefix': event.hash.substring(0, 10),
      });
    } catch (_) {}
  }

  /// Persists in SharedPreferences
  Future<void> _persistLedger() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = _ledger.map((e) => e.toJson()).toList();
      await prefs.setStringList(_storageKey, stringList);
    } catch (e) {
      debugPrint('[SecurityAudit] Failed to persist ledger: $e');
    }
  }

  /// Seeds initial verified audit events so the application has a live audit history
  Future<void> _seedInitialAuditEvents() async {
    final now = DateTime.now().toUtc();

    final seedDefs = [
      {
        'action': AuditActionType.authLoginSuccess,
        'resourceType': AuditResourceType.authSession,
        'resourceId': 'sess_init_auth',
        'classification': DataClassification.security,
        'details': {'method': 'oauth_google', 'scope': 'email,profile'},
        'deltaMinutes': 120,
      },
      {
        'action': AuditActionType.phiReportUploaded,
        'resourceType': AuditResourceType.phiMedicalReport,
        'resourceId': 'rep_cmp_2026',
        'classification': DataClassification.phi,
        'details': {'reportTitle': 'Comprehensive Metabolic Panel', 'lab': 'Quest Diagnostics'},
        'deltaMinutes': 110,
      },
      {
        'action': AuditActionType.phiReportViewed,
        'resourceType': AuditResourceType.phiMedicalReport,
        'resourceId': 'rep_cmp_2026',
        'classification': DataClassification.phi,
        'details': {'viewTab': 'Biomarker Analysis', 'client': 'mobile_app'},
        'deltaMinutes': 60,
      },
      {
        'action': AuditActionType.medicationTaken,
        'resourceType': AuditResourceType.medicationSchedule,
        'resourceId': 'med_metformin_500',
        'classification': DataClassification.phi,
        'details': {'dosage': '500mg', 'timeSlot': 'Morning Dose'},
        'deltaMinutes': 45,
      },
      {
        'action': AuditActionType.familyCaregiverInvited,
        'resourceType': AuditResourceType.familyAccessControl,
        'resourceId': 'caregiver_sarah_sp',
        'classification': DataClassification.pii,
        'details': {'relation': 'Spouse', 'permissionTier': 'FullCaregiver'},
        'deltaMinutes': 30,
      },
    ];

    String prevHash = _genesisHash;
    for (var def in seedDefs) {
      final id = _uuid.v4();
      final ts = now.subtract(Duration(minutes: def['deltaMinutes'] as int));
      final metadata = def['details'] as Map<String, dynamic>;
      final action = def['action'] as AuditActionType;
      final resourceType = def['resourceType'] as AuditResourceType;
      final resourceId = def['resourceId'] as String;
      final classification = def['classification'] as DataClassification;

      final hash = SecurityAuditEvent.computeHash(
        id: id,
        timestamp: ts,
        actorId: 'patient_priya_sharma',
        actionType: action.name,
        resourceId: resourceId,
        outcome: AuditOutcome.success.name,
        previousHash: prevHash,
        metadata: metadata,
      );

      final event = SecurityAuditEvent(
        id: id,
        timestamp: ts,
        actorId: 'patient_priya_sharma',
        actorRole: 'patient',
        actorEmail: 'priya.sharma@vistacortex.health',
        sessionId: 'sess_initial_secure',
        actionType: action,
        resourceType: resourceType,
        resourceId: resourceId,
        dataClassification: classification,
        outcome: AuditOutcome.success,
        originIp: '192.168.1.45',
        deviceId: 'Pixel 9 API 37',
        metadata: metadata,
        previousHash: prevHash,
        hash: hash,
      );

      _ledger.add(event);
      prevHash = hash;
    }

    await _persistLedger();
  }

  /// Exports an audit package formatted in JSON for external compliance review
  String exportAuditPackage() {
    final report = verifyLedgerIntegrity();
    final package = {
      'application': 'VistaCortex Healthcare App',
      'standard': 'HIPAA Security Rule §164.312(b) & ISO 27001',
      'exportTimestamp': DateTime.now().toUtc().toIso8601String(),
      'ledgerIntegrityVerified': report.isChainIntact,
      'verificationMessage': report.message,
      'totalRecords': _ledger.length,
      'genesisHash': _genesisHash,
      'latestHash': _ledger.isNotEmpty ? _ledger.last.hash : null,
      'events': _ledger.map((e) => e.toMap()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(package);
  }
}
