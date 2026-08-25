/// A single food item portion inside a composed nutrition log.
class LoggedFoodPortion {
  final String foodId;
  final String foodName;
  final double grams;

  const LoggedFoodPortion({
    required this.foodId,
    required this.foodName,
    required this.grams,
  });

  bool get isValid => foodId.isNotEmpty && foodName.isNotEmpty && grams > 0;

  @override
  String toString() => '$foodName (${grams.round()}g)';
}
