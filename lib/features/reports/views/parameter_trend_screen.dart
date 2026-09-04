import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_colors.dart';
import '../../../core/utils/trend_calculator.dart';
import '../providers/reports_provider.dart';

class ParameterTrendScreen extends ConsumerWidget {
  final String parameterName;

  const ParameterTrendScreen({
    super.key,
    required this.parameterName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref
        .read(reportsProvider.notifier)
        .getHistoricalParameterTrends(parameterName);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('$parameterName Trends'),
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'Not enough historical reports to establish a trend line.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLatestValueCard(history.last),
                  const SizedBox(height: 16),

                  const Text(
                    'Chronological Report Points',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(history.length, (index) {
                    final point = history[index];
                    final date = point['date'] as DateTime;
                    final val = point['value'] as double;
                    final unit = point['unit'] as String;
                    final title = point['reportTitle'] as String;
                    final status = point['status'] as ValueStatus;

                    String trendText = 'Initial Baseline';
                    TrendDirection direction = TrendDirection.stable;

                    if (index > 0) {
                      final prevVal = history[index - 1]['value'] as double;
                      direction = TrendCalculator.calculateTrend(prevVal, val);
                      if (direction == TrendDirection.increased) {
                        trendText = 'Increased from ${prevVal.toStringAsFixed(1)}';
                      } else if (direction == TrendDirection.decreased) {
                        trendText = 'Decreased from ${prevVal.toStringAsFixed(1)}';
                      } else {
                        trendText = 'Stable relative to previous test';
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: TrendCalculator.getStatusColor(status).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              direction == TrendDirection.increased
                                  ? Icons.trending_up_rounded
                                  : (direction == TrendDirection.decreased
                                      ? Icons.trending_down_rounded
                                      : Icons.trending_flat_rounded),
                              color: TrendCalculator.getStatusColor(status),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd MMMM yyyy').format(date),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  title,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  trendText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: direction == TrendDirection.decreased
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${val.toStringAsFixed(1)} $unit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: TrendCalculator.getStatusColor(status).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  TrendCalculator.getStatusLabel(status),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: TrendCalculator.getStatusColor(status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildLatestValueCard(Map<String, dynamic> latest) {
    final val = latest['value'] as double;
    final unit = latest['unit'] as String;
    final status = latest['status'] as ValueStatus;
    final date = latest['date'] as DateTime;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parameterName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Latest on ${DateFormat('dd MMM yyyy').format(date)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${val.toStringAsFixed(1)} $unit',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  TrendCalculator.getStatusLabel(status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: TrendCalculator.getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
