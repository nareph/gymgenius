/// Direction of a progress metric over a lookback window.
enum TrendDirection {
  gaining,
  losing,
  stable,
  fluctuating,
  insufficientData,
}

extension TrendDirectionExtension on TrendDirection {
  String get displayName {
    switch (this) {
      case TrendDirection.gaining:
        return 'Gaining';
      case TrendDirection.losing:
        return 'Losing';
      case TrendDirection.stable:
        return 'Stable';
      case TrendDirection.fluctuating:
        return 'Fluctuating';
      case TrendDirection.insufficientData:
        return 'Insufficient data';
    }
  }

  String get value {
    switch (this) {
      case TrendDirection.gaining:
        return 'gaining';
      case TrendDirection.losing:
        return 'losing';
      case TrendDirection.stable:
        return 'stable';
      case TrendDirection.fluctuating:
        return 'fluctuating';
      case TrendDirection.insufficientData:
        return 'insufficient_data';
    }
  }

  static TrendDirection fromValue(String value) {
    return TrendDirection.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TrendDirection.insufficientData,
    );
  }
}
