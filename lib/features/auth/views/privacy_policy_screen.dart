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

                  // Policy sections
                  _buildPolicySection(
                    '1. Data Collection',
                    'VistaCortex collects personal health information including your name, age, medical reports, medication schedules, and health metrics. This data is used solely to provide you with personalized healthcare insights and reminders.',
                  ),
                  _buildPolicySection(
                    '2. Data Storage & Security',
                    'All your health data is encrypted using AES-256 encryption and stored securely on HIPAA-compliant servers. We implement industry-standard security measures including end-to-end encryption, biometric authentication, and secure data transmission protocols.',
                  ),
                  _buildPolicySection(
                    '3. Data Sharing',
                    'We do NOT sell, trade, or share your personal health data with third parties for marketing purposes. Your data may only be shared with:\n\n• Healthcare providers you explicitly authorize\n• Family members you grant access to through Family Connect\n• Emergency services when you activate SOS',
                  ),
                  _buildPolicySection(
                    '4. AI Analysis Disclaimer',
                    'Our AI-powered health analysis provides informational insights only and does not constitute medical advice, diagnosis, or treatment. Always consult your healthcare provider for medical decisions.',
                  ),
                  _buildPolicySection(
                    '5. Data Retention',
                    'Your health records are retained for as long as your account is active. You may request deletion of your data at any time through the app settings or by contacting support@vistacortex.com.',
                  ),
                  _buildPolicySection(
                    '6. Your Rights',
                    'You have the right to:\n\n• Access your personal health data at any time\n• Request correction of inaccurate data\n• Export your data in standard formats\n• Delete your account and all associated data\n• Withdraw consent for data processing',
                  ),
                  _buildPolicySection(
                    '7. Cookies & Analytics',
                    'We use minimal analytics to improve app performance and user experience. No tracking cookies are used for advertising purposes. You can opt out of analytics collection in app settings.',
                  ),
                  _buildPolicySection(
                    '8. Updates to Policy',
                    'We may update this privacy policy from time to time. You will be notified of any significant changes through in-app notifications and email. Continued use of the app after policy updates constitutes acceptance.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Last updated: September 2026',
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
