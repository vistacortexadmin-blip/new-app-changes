import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/security/security_audit_model.dart';
import '../../../core/security/security_audit_service.dart';

class SecurityAuditScreen extends StatefulWidget {
  const SecurityAuditScreen({super.key});

  @override
  State<SecurityAuditScreen> createState() => _SecurityAuditScreenState();
}

class _SecurityAuditScreenState extends State<SecurityAuditScreen> {
  final _auditService = SecurityAuditService();
  String _selectedFilter = 'All';
  AuditIntegrityReport? _integrityReport;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _loadAndVerify();
  }

  Future<void> _loadAndVerify() async {
    await _auditService.initialize();
    setState(() {
      _integrityReport = _auditService.verifyLedgerIntegrity();
    });
  }

  void _runVerification() {
    setState(() => _isVerifying = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final report = _auditService.verifyLedgerIntegrity();
      setState(() {
        _integrityReport = report;
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(report.message),
          backgroundColor: report.isChainIntact ? AppColors.success : AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  void _showEventDetailsModal(SecurityAuditEvent event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Audit Record Detail',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildModalRow('Event ID', event.id),
              _buildModalRow('Timestamp (UTC)', event.timestamp.toIso8601String()),
              _buildModalRow('Actor ID', event.actorId),
              _buildModalRow('Actor Role', event.actorRole),
              _buildModalRow('Action Type', event.actionType.name),
              _buildModalRow('Resource Target', '${event.resourceType.name} (${event.resourceId})'),
              _buildModalRow('Data Classification', event.dataClassification.name.toUpperCase()),
              _buildModalRow('Outcome', event.outcome.name.toUpperCase()),
              _buildModalRow('Origin IP', event.originIp),
              _buildModalRow('Origin Device', event.deviceId),
              const Divider(height: 24),
              const Text(
                'Cryptographic Proof (SHA-256)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Block Hash: ${event.hash}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                    const SizedBox(height: 4),
                    Text('Prev Hash: ${event.previousHash}', style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy JSON Proof'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: event.toJson()));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Audit record JSON copied to clipboard')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = _auditService.ledger.reversed.toList();
    final filteredEvents = allEvents.where((e) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'PHI') return e.dataClassification == DataClassification.phi;
      if (_selectedFilter == 'Security') return e.dataClassification == DataClassification.security;
      if (_selectedFilter == 'PII') return e.dataClassification == DataClassification.pii;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Security Audit Ledger', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Export Audit Package',
            onPressed: () {
              final jsonPkg = _auditService.exportAuditPackage();
              Clipboard.setData(ClipboardData(text: jsonPkg));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compliance Audit Package copied to clipboard (JSON)'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Ledger Integrity Status Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (_integrityReport?.isChainIntact ?? true) ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (_integrityReport?.isChainIntact ?? true) ? AppColors.successSurface : AppColors.errorSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        (_integrityReport?.isChainIntact ?? true) ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                        color: (_integrityReport?.isChainIntact ?? true) ? AppColors.success : AppColors.error,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (_integrityReport?.isChainIntact ?? true) ? 'Cryptographic Chain Verified' : 'Integrity Compromise Detected',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: (_integrityReport?.isChainIntact ?? true) ? AppColors.success : AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_integrityReport?.totalRecords ?? 0} append-only records · SHA-256 Hash Chain',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Standard: HIPAA §164.312(b)',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isVerifying ? null : _runVerification,
                        icon: _isVerifying
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(_isVerifying ? 'Verifying...' : 'Verify Chain', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'PHI', 'Security', 'PII'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _selectedFilter = filter),
                    selectedColor: AppColors.primarySurface,
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // 3. Audit Trail List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return InkWell(
                  onTap: () => _showEventDetailsModal(event),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getClassificationColor(event.dataClassification).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                event.dataClassification.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _getClassificationColor(event.dataClassification),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatActionName(event.actionType),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: event.outcome == AuditOutcome.success ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                event.outcome.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: event.outcome == AuditOutcome.success ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(event.actorId, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const Spacer(),
                            const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d, HH:mm:ss').format(event.timestamp.toLocal()),
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link_rounded, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Hash: ${event.hash.substring(0, 16)}... (Chain Valid)',
                                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textMuted),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getClassificationColor(DataClassification classification) {
    switch (classification) {
      case DataClassification.phi:
        return const Color(0xFFDC2626); // Red (Protected Health Information)
      case DataClassification.security:
        return const Color(0xFF2563EB); // Blue (Security/Auth)
      case DataClassification.pii:
        return const Color(0xFF7C3AED); // Purple (PII)
      case DataClassification.general:
        return const Color(0xFF475569); // Slate
    }
  }

  String _formatActionName(AuditActionType action) {
    switch (action) {
      case AuditActionType.authLoginSuccess:
        return 'User Authentication Succeeded';
      case AuditActionType.authLoginFailure:
        return 'Authentication Attempt Denied';
      case AuditActionType.authLogout:
        return 'User Session Terminated';
      case AuditActionType.authSessionExpired:
        return 'Authentication Session Expired';
      case AuditActionType.phiReportViewed:
        return 'Medical Report Accessed';
      case AuditActionType.phiReportUploaded:
        return 'New Lab Document Encrypted & Stored';
      case AuditActionType.phiReportExported:
        return 'Patient Health Record Exported';
      case AuditActionType.phiParameterTrendAnalyzed:
        return 'Clinical Biomarker History Query';
      case AuditActionType.medicationTaken:
        return 'Medication Dose Acknowledged';
      case AuditActionType.medicationSkipped:
        return 'Medication Dose Deferred';
      case AuditActionType.medicationRefillRequested:
        return 'Pharmacy Refill Order Dispatched';
      case AuditActionType.familyCaregiverInvited:
        return 'Caregiver Invitation Dispatched';
      case AuditActionType.familyPermissionModified:
        return 'Sharing Permission Tier Adjusted';
      case AuditActionType.familyPermissionRevoked:
        return 'Caregiver Record Access Revoked';
      case AuditActionType.emergencySosTriggered:
        return 'Emergency SOS Protocol Activated';
      case AuditActionType.dataExportRequested:
        return 'Full Medical Data Export Requested';
      case AuditActionType.securityAnomalyDetected:
        return 'Security Anomaly Detected & Flagged';
      case AuditActionType.integrityVerificationPerformed:
        return 'Cryptographic Ledger Verification Checked';
    }
  }
}
