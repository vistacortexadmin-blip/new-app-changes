import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/views/welcome_screen.dart';
import '../../auth/views/profile_setup_screen.dart';
import '../../reports/views/report_details_screen.dart';
import '../../reports/providers/reports_provider.dart';
import '../../recovery_care/views/recovery_care_screen.dart';
import '../../family_connect/views/family_connect_screen.dart';
import '../../test_booking/views/test_booking_screen.dart';
import '../../ai_chat/views/ai_chat_screen.dart';
import '../../settings/views/settings_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _userName = 'Sritan';
  String? _userImagePath;
  String? _userAge;
  String? _userGender;
  String? _userWeight;
  String? _userHeight;
  String? _userBloodGroup;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('user_name');
    final imagePath = prefs.getString('user_image_path');
    final age = prefs.getString('user_age');
    final gender = prefs.getString('user_gender');
    final weight = prefs.getString('user_weight');
    final height = prefs.getString('user_height');
    final bloodGroup = prefs.getString('user_blood_group');

    if (mounted) {
      setState(() {
        if (fullName != null && fullName.trim().isNotEmpty) {
          _userName = fullName.trim().split(' ').first;
        }
        _userImagePath = imagePath;
        _userAge = age;
        _userGender = gender;
        _userWeight = weight;
        _userHeight = height;
        _userBloodGroup = bloodGroup;
      });
    }
  }

  void _confirmSignOut(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Sign Out',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of VistaCortex? Your encrypted medical records and security audit logs will remain securely preserved on this device.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You have been signed out successfully.'),
                    backgroundColor: AppColors.textPrimary,
                  ),
                );
              }
            },
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showProfileModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar preview
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3A5F) : AppColors.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: ClipOval(
                    child: _userImagePath != null && File(_userImagePath!).existsSync()
                        ? Image.file(
                            File(_userImagePath!),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _userName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personal Health Account',
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 16),

                // Health tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (_userAge != null && _userAge!.isNotEmpty)
                      _buildProfileChip('Age: $_userAge yrs', isDark),
                    if (_userGender != null)
                      _buildProfileChip(_userGender!, isDark),
                    if (_userBloodGroup != null && _userBloodGroup != 'Select')
                      _buildProfileChip('Blood: $_userBloodGroup', isDark),
                    if (_userWeight != null && _userWeight!.isNotEmpty)
                      _buildProfileChip('$_userWeight kg', isDark),
                    if (_userHeight != null && _userHeight!.isNotEmpty)
                      _buildProfileChip('$_userHeight cm', isDark),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: isDark ? const Color(0xFF334155) : AppColors.divider),

                // Actions: Edit Profile, Settings & Sign Out
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A5F) : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                  ),
                  title: Text('Edit Health Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                  trailing: Icon(Icons.chevron_right_rounded, size: 20, color: textSecondary),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
                    ).then((_) => _loadUserProfile());
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : const Color(0xFF64748B), size: 20),
                  ),
                  title: Text('Settings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
                  trailing: Icon(Icons.chevron_right_rounded, size: 20, color: textSecondary),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                  ),
                  title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.error)),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.error),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmSignOut(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header: User Greeting + Notification Bell & Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Avatar with online dot
                      GestureDetector(
                        onTap: () => _showProfileModal(context),
                        child: Stack(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _userImagePath != null && File(_userImagePath!).existsSync()
                                    ? Image.file(
                                        File(_userImagePath!),
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Text(
                                          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isDark ? const Color(0xFF0F172A) : Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $_userName',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Take charge of your health today.',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Bell & Settings buttons
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.notifications_outlined, size: 20, color: textColor),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No new notifications today.')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Search Bar with AI action button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiChatScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: textSecondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ask anything about your health...',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Hero Encouragement Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF064E3B), const Color(0xFF0F2B22)]
                        : [const Color(0xFFD1FAE5), const Color(0xFFE0F2FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF059669).withValues(alpha: 0.4)
                        : const Color(0xFFA7F3D0).withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Small steps today,',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'a healthier tomorrow.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF065F46) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.eco_rounded,
                          color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF10B981),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 4. 6-Card Health Hub Grid
              _buildFeatureGrid(context, reportsState, isDark, cardBg, textColor, textSecondary, borderColor),
              const SizedBox(height: 24),

              // 5. Your Health Summary Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Health Summary',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onNavigateTab(1),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3 Metric Cards Row
              Row(
                children: [
                  _buildMetricCard(
                    count: '3',
                    label: 'Reports Added',
                    countColor: AppColors.primary,
                    bgColor: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
                    borderColor: isDark ? const Color(0xFF2563EB).withValues(alpha: 0.4) : const Color(0xFFBFDBFE),
                    labelColor: textColor,
                    onTap: () => widget.onNavigateTab(1),
                  ),
                  const SizedBox(width: 10),
                  _buildMetricCard(
                    count: '2',
                    label: 'Reminders Today',
                    countColor: const Color(0xFFF97316),
                    bgColor: isDark ? const Color(0xFF43281C) : const Color(0xFFFFF7ED),
                    borderColor: isDark ? const Color(0xFFF97316).withValues(alpha: 0.4) : const Color(0xFFFED7AA),
                    labelColor: textColor,
                    onTap: () => widget.onNavigateTab(3),
                  ),
                  const SizedBox(width: 10),
                  _buildMetricCard(
                    count: '1',
                    label: 'Upcoming Test',
                    countColor: const Color(0xFF0D9488),
                    bgColor: isDark ? const Color(0xFF134E4A) : const Color(0xFFF0FDFA),
                    borderColor: isDark ? const Color(0xFF0D9488).withValues(alpha: 0.4) : const Color(0xFF99F6E4),
                    labelColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TestBookingScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 6 Quick Action Grid Cards (2 rows of 3)
  Widget _buildFeatureGrid(
    BuildContext context,
    ReportsState reportsState,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color textSecondary,
    Color borderColor,
  ) {
    return Column(
      children: [
        // Row 1
        Row(
          children: [
            _buildGridItem(
              icon: Icons.description_rounded,
              iconColor: const Color(0xFF10B981),
              iconBgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
              title: 'Reports',
              subtitle: 'Store & manage',
              cardBg: cardBg,
              textColor: textColor,
              textSecondary: textSecondary,
              borderColor: borderColor,
              onTap: () => widget.onNavigateTab(1),
            ),
            const SizedBox(width: 10),
            _buildGridItem(
              icon: Icons.auto_awesome_rounded,
              iconColor: const Color(0xFF8B5CF6),
              iconBgColor: isDark ? const Color(0xFF3B1E6D) : const Color(0xFFF5F3FF),
              title: 'Analysis',
              subtitle: 'AI insights',
              cardBg: cardBg,
              textColor: textColor,
              textSecondary: textSecondary,
              borderColor: borderColor,
              onTap: () {
                if (reportsState.reports.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailsScreen(
                        report: reportsState.reports.first,
                      ),
                    ),
                  );
                } else {
                  widget.onNavigateTab(1);
                }
              },
            ),
            const SizedBox(width: 10),
            _buildGridItem(
              icon: Icons.alarm_rounded,
              iconColor: const Color(0xFFF97316),
              iconBgColor: isDark ? const Color(0xFF43281C) : const Color(0xFFFFF7ED),
              title: 'Reminders',
              subtitle: 'Never miss',
              cardBg: cardBg,
              textColor: textColor,
              textSecondary: textSecondary,
              borderColor: borderColor,
              onTap: () => widget.onNavigateTab(3),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2
        Row(
          children: [
            _buildGridItem(
              icon: Icons.calendar_month_rounded,
              iconColor: const Color(0xFF2563EB),
              iconBgColor: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
              title: 'Test Booking',
              subtitle: 'Book tests',
              cardBg: cardBg,
              textColor: textColor,
              textSecondary: textSecondary,
              borderColor: borderColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestBookingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            _buildGridItem(
              icon: Icons.health_and_safety_rounded,
              iconColor: const Color(0xFFEC4899),
              iconBgColor: isDark ? const Color(0xFF50123C) : const Color(0xFFFDF2F8),
              title: 'Surgery Care',
              subtitle: 'Guidance & recovery',
              cardBg: cardBg,
              textColor: textColor,
              textSecondary: textSecondary,
              borderColor: borderColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecoveryCareScreen(),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            _buildGridItem(
              icon: Icons.family_restroom_rounded,
              iconColor: const Color(0xFF6366F1),
              iconBgColor: isDark ? const Color(0xFF2D2B69) : const Color(0xFFEEF2FF),
              title: 'Family',
              subtitle: 'Stay together',
              cardBg: cardBg,
              textColor: textColor,
              textSecondary: textSecondary,
              borderColor: borderColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FamilyConnectScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required Color cardBg,
    required Color textColor,
    required Color textSecondary,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String count,
    required String label,
    required Color countColor,
    required Color bgColor,
    required Color borderColor,
    required Color labelColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: countColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
