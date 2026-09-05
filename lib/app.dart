import 'package:flutter/material.dart';
import 'core/config/app_colors.dart';
import 'core/config/app_theme.dart';
import 'features/auth/views/welcome_screen.dart';
import 'features/dashboard/views/dashboard_screen.dart';
import 'features/reports/views/reports_screen.dart';
import 'features/ai_chat/views/ai_chat_screen.dart';
import 'features/reminders/views/reminders_screen.dart';
import 'features/recovery_care/views/recovery_care_screen.dart';
import 'features/test_booking/views/test_booking_screen.dart';
import 'features/family_connect/views/family_connect_screen.dart';

class VistaCortexApp extends StatelessWidget {
  const VistaCortexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VistaCortex Healthcare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(), // Starts at Welcome / Onboarding screen (Screen 1)
    );
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
  }

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
              const Text(
                'More Health Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB)),
                ),
                title: const Text('Test Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Book diagnostic tests with nearby labs', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TestBookingScreen()),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF2F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFFEC4899)),
                ),
                title: const Text('Surgery Care', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Post-operative recovery & protocols', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecoveryCareScreen()),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.family_restroom_rounded, color: Color(0xFF6366F1)),
                ),
                title: const Text('Family Connect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Authorized family sharing & caregivers', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FamilyConnectScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 5 primary tabs exactly matching design board:
    // 0: Home | 1: Reports | 2: AI | 3: Reminders | 4: More
    final screens = [
      DashboardScreen(onNavigateTab: _onNavigateTab),
      const ReportsScreen(),
      const AiChatScreen(),
      const RemindersScreen(),
      const TestBookingScreen(), // Fallback / More screen
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
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
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFEFF6FF),
            surfaceTintColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.description_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.description_rounded, color: AppColors.primary),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                label: 'AI',
              ),
              NavigationDestination(
                icon: Icon(Icons.alarm_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.alarm_rounded, color: AppColors.primary),
                label: 'Reminders',
              ),
              NavigationDestination(
                icon: Icon(Icons.widgets_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.widgets_rounded, color: AppColors.primary),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
