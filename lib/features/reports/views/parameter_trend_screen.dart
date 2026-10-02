import 'dart:math' as math;
import 'dart:ui' as ui;

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
    ref.watch(reportsProvider);
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
                  _buildTrendChart(history),
                  const SizedBox(height: 20),
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
                        trendText =
                            'Increased from ${prevVal.toStringAsFixed(1)}';
                      } else if (direction == TrendDirection.decreased) {
                        trendText =
                            'Decreased from ${prevVal.toStringAsFixed(1)}';
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
                              color: TrendCalculator.getStatusColor(status)
                                  .withValues(alpha: 0.12),
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  title,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: TrendCalculator.getStatusColor(status)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  TrendCalculator.getStatusLabel(status),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        TrendCalculator.getStatusColor(status),
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

  Widget _buildTrendChart(List<Map<String, dynamic>> history) {
    final values = history
        .map(
          (point) => _ChartPoint(
            date: point['date'] as DateTime,
            value: point['value'] as double,
            status: point['status'] as ValueStatus,
          ),
        )
        .toList(growable: false);
    return Semantics(
      label:
          '$parameterName historical trend chart with ${values.length} report points',
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biomarker trendline',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              values.length == 1
                  ? 'Add another report containing this biomarker to establish a direction.'
                  : '${DateFormat('dd MMM yyyy').format(values.first.date)} - ${DateFormat('dd MMM yyyy').format(values.last.date)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              key: const Key('parameter-trend-chart'),
              width: double.infinity,
              height: 190,
              child: CustomPaint(
                painter: _TrendLinePainter(points: values),
              ),
            ),
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500),
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

class _ChartPoint {
  final DateTime date;
  final double value;
  final ValueStatus status;

  const _ChartPoint({
    required this.date,
    required this.value,
    required this.status,
  });
}

class _TrendLinePainter extends CustomPainter {
  final List<_ChartPoint> points;

  const _TrendLinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const left = 42.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 30.0;
    final chartWidth = math.max(1.0, size.width - left - right);
    final chartHeight = math.max(1.0, size.height - top - bottom);
    final rawMin = points.map((point) => point.value).reduce(math.min);
    final rawMax = points.map((point) => point.value).reduce(math.max);
    final rawSpan = rawMax - rawMin;
    final padding =
        rawSpan == 0 ? math.max(rawMax.abs() * 0.1, 1.0) : rawSpan * 0.15;
    final minValue = rawMin - padding;
    final maxValue = rawMax + padding;
    final valueSpan = math.max(maxValue - minValue, 1.0);

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var index = 0; index <= 3; index++) {
      final y = top + (chartHeight * index / 3);
      canvas.drawLine(Offset(left, y), Offset(left + chartWidth, y), gridPaint);
      final labelValue = maxValue - (valueSpan * index / 3);
      _paintText(
        canvas,
        labelValue.toStringAsFixed(labelValue.abs() >= 100 ? 0 : 1),
        Offset(0, y - 7),
        const TextStyle(fontSize: 9, color: AppColors.textMuted),
      );
    }

    final offsets = <Offset>[];
    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1
          ? left + chartWidth / 2
          : left + (chartWidth * index / (points.length - 1));
      final normalized = (points[index].value - minValue) / valueSpan;
      final y = top + chartHeight - (normalized * chartHeight);
      offsets.add(Offset(x, y));
    }

    if (offsets.length > 1) {
      final fillPath = Path()
        ..moveTo(offsets.first.dx, top + chartHeight)
        ..lineTo(offsets.first.dx, offsets.first.dy);
      for (final offset in offsets.skip(1)) {
        fillPath.lineTo(offset.dx, offset.dy);
      }
      fillPath
        ..lineTo(offsets.last.dx, top + chartHeight)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.2),
              AppColors.primary.withValues(alpha: 0.02),
            ],
          ).createShader(
            Rect.fromLTWH(left, top, chartWidth, chartHeight),
          ),
      );

      final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      for (final offset in offsets.skip(1)) {
        linePath.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(
        linePath,
        Paint()
          ..color = AppColors.primary
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    for (var index = 0; index < offsets.length; index++) {
      final color = TrendCalculator.getStatusColor(points[index].status);
      canvas
        ..drawCircle(offsets[index], 6, Paint()..color = Colors.white)
        ..drawCircle(offsets[index], 4, Paint()..color = color);
    }

    _paintText(
      canvas,
      DateFormat('dd MMM').format(points.first.date),
      Offset(left, size.height - 18),
      const TextStyle(fontSize: 9, color: AppColors.textMuted),
    );
    if (points.length > 1) {
      final lastLabel = DateFormat('dd MMM').format(points.last.date);
      final painter = _textPainter(
        lastLabel,
        const TextStyle(fontSize: 9, color: AppColors.textMuted),
      );
      painter.paint(
        canvas,
        Offset(left + chartWidth - painter.width, size.height - 18),
      );
    }
  }

  TextPainter _textPainter(String text, TextStyle style) => TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: ui.TextDirection.ltr,
      )..layout();

  void _paintText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
  ) {
    _textPainter(text, style).paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _TrendLinePainter oldDelegate) {
    if (oldDelegate.points.length != points.length) return true;
    for (var index = 0; index < points.length; index++) {
      if (oldDelegate.points[index].date != points[index].date ||
          oldDelegate.points[index].value != points[index].value ||
          oldDelegate.points[index].status != points[index].status) {
        return true;
      }
    }
    return false;
  }
}
