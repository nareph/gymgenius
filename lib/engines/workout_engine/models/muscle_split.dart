/// Represents a muscle group split for a training day.
class MuscleSplit {
  final String name;
  final List<String> muscles;
  final String theme;

  const MuscleSplit({
    required this.name,
    required this.muscles,
    required this.theme,
  });
}
