import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/auth_service.dart';
import 'terms_conditions_screen.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _accepted = false;
  bool _hasScrolledToBottom = false;
  late final ScrollController _scrollController;
  final _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _analytics.logScreen('privacy_policy_screen');
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (_scrollController.position.maxScrollExtent <= 0) {
          if (!_hasScrolledToBottom && mounted) {
            setState(() => _hasScrolledToBottom = true);
          }
        }
      }
    });
  }

  void _onScroll() {
    if (!_hasScrolledToBottom && _scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll <= 0 || currentScroll >= (maxScroll - 50)) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              await AuthService().signOut();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // Scrollable policy content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header icon
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Your Privacy Matters',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Please review our privacy policy carefully',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Policy Notice & Introduction
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Fiduciary Notice',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'VistaCortex Technologies Pvt. Ltd. ("VistaCortex") acts as the Data Fiduciary under India\'s Digital Personal Data Protection Act, 2023 (DPDP Act) and applicable rules. We process your personal and health information solely for specified, transparent healthcare management purposes.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Policy sections
                  _buildPolicySection(
                    '1. Affirmative Consent & Withdrawal',
                    'VistaCortex processes personal data only for specified purposes described in this privacy notice and consent flow. Consent is obtained through a clear affirmative action and is not bundled with unrelated purposes.\n\nYou have the right to withdraw your consent at any time through the app settings or by writing to privacy@vistacortex.com. Withdrawal does not affect processing lawfully carried out prior to withdrawal.',
                  ),
                  _buildPolicySection(
                    '2. Itemised Data Collection & Specified Purposes',
                    'We collect only the personal data necessary to provide our services:\n\n'
                    '• Account Information (Name, phone, email, age, gender): Used for authentication, identity verification, and communication.\n'
                    '• Health & Medical Information (Lab reports, vitals, prescriptions, recovery notes): Used to organize health records, visualize biomarker trends, provide adherence alerts, and assist recovery care.\n'
                    '• Diagnostic Booking Data: Name, address, and test details shared strictly with accredited lab partners to fulfill home sample collection.\n'
                    '• Authorized Caregiver Links: Contact details of family members you explicitly connect via Family Connect.\n'
                    '• Technical Telemetry: Anonymous app diagnostics and security audit logs used to prevent fraud and ensure platform integrity.',
                  ),
                  _buildPolicySection(
                    '3. AI Health Analysis & Non-Medical Advice',
                    'VistaCortex uses AI-assisted technologies to organise, extract, summarise, and explain information from health documents and user-provided health data.\n\n'
                    'AI-generated outputs are strictly informational and may be incomplete or inaccurate. VistaCortex does not represent AI output as a diagnosis, prescription, or substitute for professional medical judgment. Always consult a licensed healthcare professional for medical decisions.\n\n'
                    'Where third-party AI or model providers process personal data, processing is conducted securely under strict data processing agreements, and user data is never used to train public models without explicit consent.',
                  ),
                  _buildPolicySection(
                    '4. Data Storage, Security & Tamper-Evident Logs',
                    'We implement rigorous technical and organizational safeguards:\n\n'
                    '• Encryption at Rest: AES-256 cryptographic encryption for all stored records and databases.\n'
                    '• Encryption in Transit: TLS 1.3 protocols for all network communications.\n'
                    '• Tamper-Evident Security Audit Ledger: Every access, export, or edit of health records is recorded in a cryptographic, hash-chained audit ledger accessible in app settings.\n'
                    '• Local Hardware Keystore: Biometric credentials and authentication tokens remain securely isolated on your device hardware.',
                  ),
                  _buildPolicySection(
                    '5. Third-Party Data Processors & Lab Partners',
                    'We do NOT sell, rent, or trade your personal health data. We only engage trusted third-party processors bound by strict confidentiality and data protection obligations:\n\n'
                    '• Cloud Infrastructure: Google Cloud Platform & Firebase (secure server hosting and database services).\n'
                    '• Diagnostic Partners: NABL-accredited laboratory networks (only test name and address required for sample collection).\n'
                    '• Notifications: Firebase Cloud Messaging for timely dose reminders.\n\n'
                    'Data processing and cross-border transfers adhere to applicable provisions of the DPDP Act 2023.',
                  ),
                  _buildPolicySection(
                    '6. Personal Data Breach Response',
                    'If VistaCortex becomes aware of a personal-data breach, we will assess and respond to the incident using our security incident-response procedures.\n\n'
                    'Where applicable, we will make notifications to the Data Protection Board of India / relevant statutory authorities and affected individuals within the timelines and in the manner required by applicable law.',
                  ),
                  _buildPolicySection(
                    '7. Purpose-Based Retention & Deletion',
                    'We retain personal data only for as long as necessary for the specified purposes for which it was collected, or for periods required or permitted by applicable law.\n\n'
                    'When personal data is no longer required, we delete or anonymise it in accordance with our retention schedule. You may request account deletion at any time via App Settings or privacy@vistacortex.com. Deletion from active systems may be subject to backup cycles, statutory compliance, and lawful security retention requirements.',
                  ),
                  _buildPolicySection(
                    '8. Children\'s Privacy (Users Under 18)',
                    'VistaCortex is designed for use by adults or by parents/legal guardians managing healthcare for their dependents. Processing personal data of minors requires verifiable consent from a parent or legal guardian in accordance with the DPDP Act 2023. We do not engage in behavioral tracking or targeted advertising directed at children.',
                  ),
                  _buildPolicySection(
                    '9. Data Portability & Export Feature',
                    'As a product feature, VistaCortex provides users with convenient export functionality for account and health records in standard formats such as PDF, JSON, or FHIR. Availability may vary based on record types.',
                  ),
                  _buildPolicySection(
                    '10. Grievance Redressal & Contact Details',
                    'In compliance with the DPDP Act 2023, VistaCortex has designated a Grievance Redressal Officer to address data privacy inquiries and concerns:\n\n'
                    '• Legal Entity: VistaCortex Technologies Pvt. Ltd.\n'
                    '• Grievance Officer: grievance@vistacortex.com\n'
                    '• Privacy Inquiries: privacy@vistacortex.com\n'
                    '• Support: support@vistacortex.com\n'
                    '• Resolution Target: We endeavor to address and resolve all legitimate grievances within 30 days.',
                  ),
                  _buildPolicySection(
                    '11. Material Changes to this Policy',
                    'We may update this privacy policy from time to time. For material changes, we will provide advance in-app notification and obtain fresh affirmative consent where legally required.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Last updated: September 2026 · Compliant with DPDP Act 2023',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom bar with checkbox and Next button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Scroll hint banner when user hasn't reached the bottom
                  if (!_hasScrolledToBottom) ...[
                    GestureDetector(
                      onTap: _scrollToBottom,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Please scroll down to read the full policy',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Checkbox row
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _hasScrolledToBottom
                        ? () => setState(() => _accepted = !_accepted)
                        : () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please read and scroll to the bottom to accept.'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            _scrollToBottom();
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _accepted,
                              onChanged: _hasScrolledToBottom
                                  ? (val) => setState(() => _accepted = val ?? false)
                                  : null,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              side: BorderSide(
                                color: _hasScrolledToBottom
                                    ? AppColors.textSecondary
                                    : AppColors.textMuted.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'I have read and agree to the Privacy Policy',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _hasScrolledToBottom
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_hasScrolledToBottom && _accepted)
                            ? AppColors.primary
                            : const Color(0xFFCBD5E1),
                        foregroundColor: Colors.white,
                        elevation: (_hasScrolledToBottom && _accepted) ? 4 : 0,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: (_hasScrolledToBottom && _accepted)
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TermsConditionsScreen(),
                                ),
                              );
                            }
                          : null,
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
