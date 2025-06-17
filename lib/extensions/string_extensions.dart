// lib/extensions/string_extensions.dart

/// Provides extension methods for string manipulation, primarily for UI display.
extension StringCasingExtension on String {
  /// Converts a snake_case or space-separated string into a capitalized
  /// display format (e.g., "target_weight_kg" becomes "Target Weight Kg").
  String toCapitalizedDisplay() {
    if (isEmpty) return this;

    // Replace underscores with spaces, then split into words.
    final words = replaceAll('_', ' ').split(' ');

    // Capitalize the first letter of each word and make the rest lowercase.
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    });

    // Join the words back together with a space.
    return capitalizedWords.join(' ');
  }
}
