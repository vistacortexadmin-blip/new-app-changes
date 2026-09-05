import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_colors.dart';


class TestBookingScreen extends ConsumerWidget {
  const TestBookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Booking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Book lab tests from trusted partners.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Bar matching Screen 7
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  hintText: 'Search for tests (e.g. CBC, MRI, Sugar)...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // 2. Popular Tests Row matching Screen 7
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Popular Tests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
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
                  bgColor: const Color(0xFFEFF6FF),
                ),
                _buildPopularTestItem(
                  label: 'Blood Test\n ',
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEE2E2),
                ),
                _buildPopularTestItem(
                  label: 'Thyroid Test\n ',
                  icon: Icons.science_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  bgColor: const Color(0xFFF5F3FF),
                ),
                _buildPopularTestItem(
                  label: 'Vitamin D\n ',
                  icon: Icons.wb_sunny_outlined,
                  iconColor: const Color(0xFF6366F1),
                  bgColor: const Color(0xFFEEF2FF),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Nearby Labs Section Header
            const Text(
              'Nearby Labs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),

            // Nearby Labs list matching Screen 7
            _buildLabCard(
              name: 'Apollo Diagnostics',
              distance: '2.3 km',
              rating: '4.8',
              logoColor: const Color(0xFF0D9488),
              onBook: () => _showBookingSheet(context, ref, 'Apollo Diagnostics'),
            ),
            _buildLabCard(
              name: 'Thyrocare',
              distance: '3.1 km',
              rating: '4.6',
              logoColor: const Color(0xFFEF4444),
              onBook: () => _showBookingSheet(context, ref, 'Thyrocare'),
            ),
            _buildLabCard(
              name: 'Dr. Lal PathLabs',
              distance: '4.0 km',
              rating: '4.5',
              logoColor: const Color(0xFFF59E0B),
              onBook: () => _showBookingSheet(context, ref, 'Dr. Lal PathLabs'),
            ),
            _buildLabCard(
              name: 'MedPlus Diagnostics',
              distance: '4.5 km',
              rating: '4.4',
              logoColor: const Color(0xFF10B981),
              onBook: () => _showBookingSheet(context, ref, 'MedPlus Diagnostics'),
            ),
            const SizedBox(height: 18),

            // 4. Bottom Encouragement Card matching Screen 7
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Accurate tests.\nA healthier you.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF065F46),
                      height: 1.3,
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      color: Color(0xFF10B981),
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
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
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
    required VoidCallback onBook,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      distance,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
              Text(
                'Book at $labName',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select a slot for your recommended CBC & Lipid test.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.home_outlined, color: AppColors.primary),
                title: Text('Free Home Sample Collection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Phlebotomist arrives at your home address', style: TextStyle(fontSize: 12)),
                trailing: Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
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
