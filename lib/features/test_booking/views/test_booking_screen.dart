import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';

class TestBookingScreen extends ConsumerWidget {
  const TestBookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? const Color(0xFFF1F5F9) : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : AppColors.border;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Booking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            Text(
              'Book lab tests from trusted partners.',
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long_outlined, color: textColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search for blood tests, profiles, packages...',
                  hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                  prefixIcon: Icon(Icons.search_rounded, color: textSecondary, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Popular Tests Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Tests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
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

            // 4 Circular Test Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPopularTestItem(
                  label: 'Full Body\nCheckup',
                  icon: Icons.health_and_safety_outlined,
                  iconColor: const Color(0xFF2563EB),
                  bgColor: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF),
                  textColor: textColor,
                ),
                _buildPopularTestItem(
                  label: 'Blood Test\n ',
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFFEF4444),
                  bgColor: isDark ? const Color(0xFF4C1D1D) : const Color(0xFFFEE2E2),
                  textColor: textColor,
                ),
                _buildPopularTestItem(
                  label: 'Thyroid Test\n ',
                  icon: Icons.science_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  bgColor: isDark ? const Color(0xFF3B1E6D) : const Color(0xFFF5F3FF),
                  textColor: textColor,
                ),
                _buildPopularTestItem(
                  label: 'Vitamin D\n ',
                  icon: Icons.wb_sunny_outlined,
                  iconColor: const Color(0xFF6366F1),
                  bgColor: isDark ? const Color(0xFF2D2B69) : const Color(0xFFEEF2FF),
                  textColor: textColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Nearby Labs Section Header
            Text(
              'Nearby Labs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 14),

            // Nearby Labs list
            _buildLabCard(
              name: 'Apollo Diagnostics',
              distance: '2.3 km',
              rating: '4.8',
              logoColor: const Color(0xFF0D9488),
              cardBg: cardBg,
              textColor: textColor,
              textSecondary: textSecondary,
              borderColor: borderColor,
              isDark: isDark,
              onBook: () => _showBookingSheet(context, ref, 'Apollo Diagnostics'),
            ),
            _buildLabCard(
              name: 'Thyrocare',
              distance: '3.1 km',
              rating: '4.6',
              logoColor: const Color(0xFFEF4444),
              cardBg: cardBg,
              textColor: textColor,
              textSecondary: textSecondary,
              borderColor: borderColor,
              isDark: isDark,
              onBook: () => _showBookingSheet(context, ref, 'Thyrocare'),
            ),
            _buildLabCard(
              name: 'Dr. Lal PathLabs',
              distance: '4.0 km',
              rating: '4.5',
              logoColor: const Color(0xFFF59E0B),
              cardBg: cardBg,
              textColor: textColor,
              textSecondary: textSecondary,
              borderColor: borderColor,
              isDark: isDark,
              onBook: () => _showBookingSheet(context, ref, 'Dr. Lal PathLabs'),
            ),
            _buildLabCard(
              name: 'MedPlus Diagnostics',
              distance: '4.5 km',
              rating: '4.4',
              logoColor: const Color(0xFF10B981),
              cardBg: cardBg,
              textColor: textColor,
              textSecondary: textSecondary,
              borderColor: borderColor,
              isDark: isDark,
              onBook: () => _showBookingSheet(context, ref, 'MedPlus Diagnostics'),
            ),
            const SizedBox(height: 18),

            // 4. Bottom Encouragement Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF059669).withValues(alpha: 0.4) : const Color(0xFFA7F3D0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accurate tests.\nA healthier you.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                      height: 1.3,
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF047857) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volunteer_activism_rounded,
                      color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF10B981),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularTestItem({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color textColor,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLabCard({
    required String name,
    required String distance,
    required String rating,
    required Color logoColor,
    required Color cardBg,
    required Color textColor,
    required Color textSecondary,
    required Color borderColor,
    required bool isDark,
    required VoidCallback onBook,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: logoColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_hospital_rounded, color: logoColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      distance,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: onBook,
            child: const Text('Book', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context, WidgetRef ref, String labName) {
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
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book at $labName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a slot for your recommended CBC & Lipid test.',
                style: TextStyle(fontSize: 13, color: textSecondary),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.home_outlined, color: AppColors.primary),
                title: Text('Free Home Sample Collection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                subtitle: Text('Phlebotomist arrives at your home address', style: TextStyle(fontSize: 12, color: textSecondary)),
                trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Test slot confirmed at $labName! Added to reminders.')),
                    );
                  },
                  child: const Text('Confirm Booking'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
