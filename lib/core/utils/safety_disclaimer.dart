import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';

class SafetyDisclaimerBanner extends StatelessWidget {
  final bool compact;
  final VoidCallback? onLearnMore;

  const SafetyDisclaimerBanner({
    super.key,
    this.compact = false,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.infoSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.info.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.info),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'AI summaries are for educational reference. Consult your doctor for medical decisions.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.2),
              ),
            ),
            if (onLearnMore != null)
              GestureDetector(
                onTap: onLearnMore,
                child: const Text(
                  'Info',
                  style: TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Clinical Safety & Patient Guidance',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.medicalDisclaimerFull,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
