// lib/domain/value_objects/macro_targets.dart

/// Immutable value object representing daily macronutrient targets.
class MacroTargets {
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final int? waterMl;

  const MacroTargets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.waterMl,
  });

  double get proteinPercentage => (proteinG * 4 / calories) * 100;
  double get carbsPercentage => (carbsG * 4 / calories) * 100;
  double get fatPercentage => (fatG * 9 / calories) * 100;

  @override
  String toString() =>
      'MacroTargets($calories kcal, P${proteinG}g, C${carbsG}g, F${fatG}g)';
}
