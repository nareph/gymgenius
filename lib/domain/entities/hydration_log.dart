/// A single hydration intake entry in milliliters.
class HydrationLog {
  static const int minAmountMl = 1;
  static const int maxAmountMl = 5000;

  final String id;
  final String userId;
  final int amountMl;
  final DateTime loggedAt;
  final String? note;

  HydrationLog({
    required this.id,
    required this.userId,
    required int amountMl,
    required this.loggedAt,
    this.note,
  }) : amountMl = amountMl.clamp(minAmountMl, maxAmountMl);

  bool get isValid =>
      userId.isNotEmpty &&
      amountMl >= minAmountMl &&
      amountMl <= maxAmountMl;

  DateTime get dayKey =>
      DateTime(loggedAt.year, loggedAt.month, loggedAt.day);

  @override
  String toString() => 'HydrationLog(${amountMl}ml @ $loggedAt)';
}
