import 'package:flutter/material.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/services/analytics_service.dart';
import 'profile_setup_screen.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _accepted = false;
  bool _hasScrolledToBottom = false;
  late final ScrollController _scrollController;
  final _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _analytics.logScreen('terms_conditions_screen');
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
        title: const Text(
          'Terms & Conditions',
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
          // Scrollable terms content
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
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: AppColors.accentPurple,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Terms of Service',
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
                      'Please review our terms before proceeding',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Terms sections
                  _buildTermsSection(
                    '1. Acceptance of Terms',
                    'By downloading, installing, or using VistaCortex, you agree to be bound by these Terms of Service. If you do not agree, please discontinue use of the application immediately.',
                  ),
                  _buildTermsSection(
                    '2. Description of Service',
                    'VistaCortex is a personal health management application that provides:\n\n• Medical report storage and AI-assisted analysis\n• Medication reminders and refill tracking\n• Post-surgical recovery care management\n• Diagnostic test booking services\n• Family health record sharing\n• AI health assistant chatbot\n\nThese services are provided for informational and organizational purposes only.',
                  ),
                  _buildTermsSection(
                    '3. Medical Disclaimer',
                    'VistaCortex is NOT a substitute for professional medical advice, diagnosis, or treatment. The AI-generated health insights, diet recommendations, and analysis reports are informational only. Always seek the advice of your physician or qualified health provider with any questions regarding a medical condition.\n\nIN CASE OF A MEDICAL EMERGENCY, CALL YOUR LOCAL EMERGENCY NUMBER IMMEDIATELY.',
                  ),
                  _buildTermsSection(
                    '4. User Responsibilities',
                    'You are responsible for:\n\n• Providing accurate personal and health information\n• Maintaining the confidentiality of your account credentials\n• Using the app in compliance with applicable laws\n• Not using the app for unauthorized medical practice\n• Reporting any security vulnerabilities or breaches',
                  ),
                  _buildTermsSection(
                    '5. Account Registration',
                    'You must provide accurate, current, and complete information during registration. You must be at least 18 years old to create an account, or have parental/guardian consent if under 18. You are responsible for all activities that occur under your account.',
                  ),
                  _buildTermsSection(
                    '6. Intellectual Property',
                    'All content, features, and functionality of VistaCortex, including but not limited to text, graphics, logos, icons, images, audio clips, and software, are the exclusive property of VistaCortex Technologies and are protected by international copyright and trademark laws.',
                  ),
                  _buildTermsSection(
                    '7. Third-Party Services',
                    'VistaCortex may integrate with third-party services including:\n\n• Diagnostic laboratory networks for test booking\n• Pharmacy services for medication refills\n• Payment gateways for transactions\n\nWe are not responsible for the practices or policies of these third-party services.',
                  ),
                  _buildTermsSection(
                    '8. Limitation of Liability',
                    'VistaCortex shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the service. Our total liability shall not exceed the amount paid by you, if any, for accessing the service.',
                  ),
                  _buildTermsSection(
                    '9. Termination',
                    'We reserve the right to terminate or suspend your account at any time, without prior notice, for conduct that we determine violates these Terms or is harmful to other users, us, or third parties. Upon termination, your right to use the app will immediately cease.',
                  ),
                  _buildTermsSection(
                    '10. Changes to Terms',
                    'We reserve the right to modify these Terms at any time. We will notify users of any material changes via in-app notification or email. Your continued use of VistaCortex after changes are posted constitutes acceptance of the revised Terms.',
                  ),
                  _buildTermsSection(
                    '11. Governing Law',
                    'These Terms shall be governed by and construed in accordance with the laws of India. Any disputes arising under these Terms shall be subject to the exclusive jurisdiction of the courts located in India.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Effective Date: September 2026',
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
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentPurple.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Please scroll down to read the full terms',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentPurple,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.accentPurple),
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
                                content: Text('Please read and scroll to the bottom of the terms first.'),
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
                              'I have read and agree to the Terms & Conditions',
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
                                  builder: (_) => const ProfileSetupScreen(),
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

  Widget _buildTermsSection(String title, String content) {
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
