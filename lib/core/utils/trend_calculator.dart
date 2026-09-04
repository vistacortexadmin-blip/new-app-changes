import 'package:flutter/material.dart';
import '../config/app_colors.dart';

enum TrendDirection {
  increased,
  decreased,
  stable,
  unspecified,
}

enum ValueStatus {
  normal,
  high,
  low,
  critical,
}

class TrendCalculator {
  static TrendDirection calculateTrend(double previous, double current, {double tolerance = 0.03}) {
    if (previous <= 0) return TrendDirection.unspecified;
    final diff = current - previous;
    final percentDiff = (diff / previous).abs();
    
    if (percentDiff < tolerance) {
      return TrendDirection.stable;
    } else if (diff > 0) {
      return TrendDirection.increased;
    } else {
      return TrendDirection.decreased;
    }
  }

  static ValueStatus evaluateStatus(double value, double minRange, double maxRange) {
    if (value < minRange) {
      return (value < minRange * 0.7) ? ValueStatus.critical : ValueStatus.low;
    } else if (value > maxRange) {
      return (value > maxRange * 1.3) ? ValueStatus.critical : ValueStatus.high;
    }
    return ValueStatus.normal;
  }

  static Color getStatusColor(ValueStatus status) {
    switch (status) {
      case ValueStatus.normal:
        return AppColors.success;
      case ValueStatus.low:
        return AppColors.accentBlue;
      case ValueStatus.high:
        return AppColors.warning;
      case ValueStatus.critical:
        return AppColors.error;
    }
  }

  static String getStatusLabel(ValueStatus status) {
    switch (status) {
      case ValueStatus.normal:
        return 'Normal';
      case ValueStatus.low:
        return 'Low';
      case ValueStatus.high:
        return 'High';
      case ValueStatus.critical:
        return 'Critical Alert';
    }
  }
}
