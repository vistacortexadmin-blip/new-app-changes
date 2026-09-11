import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_colors.dart';
import 'core/config/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/auth_service.dart';
import 'core/security/security_audit_model.dart';
import 'core/security/security_audit_service.dart';
import 'features/auth/views/welcome_screen.dart';
import 'features/auth/views/privacy_policy_screen.dart';
import 'features/dashboard/views/dashboard_screen.dart';
import 'features/reports/views/reports_screen.dart';
import 'features/ai_chat/views/ai_chat_screen.dart';
import 'features/reminders/views/reminders_screen.dart';
import 'features/recovery_care/views/recovery_care_screen.dart';
import 'features/test_booking/views/test_booking_screen.dart';
import 'features/family_connect/views/family_connect_screen.dart';
import 'features/security/views/security_audit_screen.dart';
import 'features/settings/views/settings_screen.dart';

class VistaCortexApp extends ConsumerWidget {
  const VistaCortexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'VistaCortex Healthcare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}

/// Security AuthGate: Watches auth stream and prevents unauthorized bypass
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0F1D),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const WelcomeScreen();
        }

        // Authenticated session exists: verify profile completion
        return FutureBuilder<bool>(
          future: _isProfileCompleted(user),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF0A0F1D),
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (profileSnapshot.data == true) {
              return const MainNavigationShell();
            }
            // Authenticated user completing onboarding sequence
            return const PrivacyPolicyScreen();
          },
        );
      },
    );
  }

  Future<bool> _isProfileCompleted(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('profile_completed') ?? false;
    final owner = prefs.getString('profile_owner_uid');
    final hasDisplayName = user.displayName != null && user.displayName!.trim().isNotEmpty;
    return hasDisplayName || (completed && (owner == null || owner == user.uid));
  }
}

class MainNavigationShell extends StatefulWidget {
  final int initialTabIndex;

  const MainNavigationShell({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _enforceAuthentication();
  }

  /// Security Route Guard: Ejects any unauthenticated or bypassed entry attempts
  void _enforceAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthService().currentUser == null) {
        SecurityAuditService().record(
          actionType: AuditActionType.securityAnomalyDetected,
          resourceType: AuditResourceType.authSession,
          resourceId: 'unauthorized_shell_entry',
          dataClassification: DataClassification.security,
          outcome: AuditOutcome.denied,
          failureReason: 'Attempted to access MainNavigationShell without active Firebase credentials',
        );
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
          );
        }
      }
    });
  }

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showMoreMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'More Health Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              _moreMenuTile(
                context,
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFF2563EB),
                iconBg: const Color(0xFFEFF6FF),
                title: 'Test Booking',
                subtitle: 'Book diagnostic tests with nearby labs',
                textColor: textColor,
                subtitleColor: subtitleColor,
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TestBookingScreen()));
                },
              ),
              _moreMenuTile(
                context,
                icon: Icons.health_and_safety_rounded,
                iconColor: const Color(0xFFEC4899),
                iconBg: const Color(0xFFFDF2F8),
                title: 'Surgery Care',
                subtitle: 'Post-operative recovery & protocols',
                textColor: textColor,
                subtitleColor: subtitleColor,
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RecoveryCareScreen()));
                },
              ),
              _moreMenuTile(
                context,
                icon: Icons.family_restroom_rounded,
                iconColor: const Color(0xFF6366F1),
                iconBg: const Color(0xFFEEF2FF),
                title: 'Family Connect',
                subtitle: 'Authorized family sharing & caregivers',
                textColor: textColor,
                subtitleColor: subtitleColor,
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FamilyConnectScreen()));
                },
              ),
              _moreMenuTile(
                context,
                icon: Icons.verified_user_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBg: const Color(0xFFF0FDF4),
                title: 'Security Audit Ledger',
                subtitle: 'HIPAA §164.312(b) & cryptographic hash chain',
                textColor: textColor,
                subtitleColor: subtitleColor,
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityAuditScreen()));
                },
              ),
              Divider(
                height: 24,
                thickness: 0.8,
                color: isDark ? const Color(0xFF334155) : AppColors.border,
              ),
              _moreMenuTile(
                context,
                icon: Icons.settings_rounded,
                iconColor: const Color(0xFF64748B),
                iconBg: const Color(0xFFF1F5F9),
                title: 'Settings',
                subtitle: 'Theme, account, privacy & more',
                textColor: textColor,
                subtitleColor: subtitleColor,
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                },
              ),
              _moreMenuTile(
                context,
                icon: Icons.logout_rounded,
                iconColor: AppColors.error,
                iconBg: const Color(0xFFFEF2F2),
                title: 'Sign Out',
                subtitle: 'Safely log out of your session',
                textColor: AppColors.error,
                subtitleColor: subtitleColor,
                isDark: isDark,
                chevronColor: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  _confirmSignOut(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _moreMenuTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subtitleColor,
    required bool isDark,
    Color? chevronColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? iconBg.withValues(alpha: 0.15) : iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subtitleColor)),
      trailing: Icon(Icons.chevron_right_rounded, color: chevronColor ?? (isDark ? const Color(0xFF64748B) : null)),
      onTap: onTap,
    );
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = [
      DashboardScreen(onNavigateTab: _onNavigateTab),
      const ReportsScreen(),
      const AiChatScreen(),
      const RemindersScreen(),
      const TestBookingScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              if (index == 4) {
                _showMoreMenu(context);
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            indicatorColor: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
            surfaceTintColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary),
                selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.description_outlined, color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary),
                selectedIcon: const Icon(Icons.description_rounded, color: AppColors.primary),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined, color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary),
                selectedIcon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                label: 'AI',
              ),
              NavigationDestination(
                icon: Icon(Icons.alarm_outlined, color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary),
                selectedIcon: const Icon(Icons.alarm_rounded, color: AppColors.primary),
                label: 'Reminders',
              ),
              NavigationDestination(
                icon: Icon(Icons.widgets_outlined, color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary),
                selectedIcon: const Icon(Icons.widgets_rounded, color: AppColors.primary),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
