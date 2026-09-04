import 'package:flutter/material.dart';
import 'core/config/app_colors.dart';
import 'core/config/app_theme.dart';
import 'features/dashboard/views/dashboard_screen.dart';
import 'features/reports/views/reports_screen.dart';
import 'features/reminders/views/reminders_screen.dart';
import 'features/recovery_care/views/recovery_care_screen.dart';
import 'features/test_booking/views/test_booking_screen.dart';

class VistaCortexApp extends StatelessWidget {
  const VistaCortexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VistaCortex Healthcare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 2; // Default to Dashboard (Center Tab)

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ReportsScreen(),
      const RemindersScreen(),
      DashboardScreen(onNavigateTab: _onNavigateTab),
      const RecoveryCareScreen(),
      const TestBookingScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primarySurface,
            surfaceTintColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.description_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.description_rounded, color: AppColors.primary),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.alarm_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.alarm_rounded, color: AppColors.primary),
                label: 'Reminders',
              ),
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.healing_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.healing_rounded, color: AppColors.primary),
                label: 'Care & Diet',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                label: 'Book Tests',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
