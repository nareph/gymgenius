enum BudgetLevel {
  low,
  medium,
  high,
}

extension BudgetLevelExtension on BudgetLevel {
  String get displayName {
    switch (this) {
      case BudgetLevel.low:
        return 'Low Budget';
      case BudgetLevel.medium:
        return 'Medium Budget';
      case BudgetLevel.high:
        return 'High Budget';
    }
  }

  String get value {
    switch (this) {
      case BudgetLevel.low:
        return 'low';
      case BudgetLevel.medium:
        return 'medium';
      case BudgetLevel.high:
        return 'high';
    }
  }

  static BudgetLevel fromValue(String value) {
    return BudgetLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BudgetLevel.medium,
    );
  }
}
