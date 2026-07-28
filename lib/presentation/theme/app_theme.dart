// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Optional: Define a global font family for the app.
  // Ensure the font is added to pubspec.yaml and assets.
  // static const String _fontFamily = 'YourCustomFont'; // Example

  // --- Dark Theme Definition ---
  static ThemeData get darkTheme {
    // --- Color Scheme Definition ---
    // This defines the primary set of colors for the dark theme.
    // It's based on Material Design principles.
    final ColorScheme colorScheme = ColorScheme.dark(
      primary: Colors.blue
          .shade600, // Primary color (e.g., for main buttons, active elements)
      onPrimary: Colors.white, // Text/icon color on primary background
      secondary: Colors.orangeAccent
          .shade700, // Secondary color (e.g., for FABs, accents) - slightly darker orange
      onSecondary: Colors.black, // Text/icon color on secondary background
      surface: Colors.grey
          .shade900, // Background color for surfaces like cards, bottom sheets
      onSurface: Colors.white
          .withValues(alpha: 0.9), // Text/icon color on main background
      error: Colors.redAccent
          .shade400, // Error color (e.g., for error messages, invalid fields)
      onError: Colors.black, // Text/icon color on error background
      brightness: Brightness.dark, // Explicitly set brightness to dark
      // You can also define other colors like:
      // primaryContainer, onPrimaryContainer,
      // secondaryContainer, onSecondaryContainer,
      // tertiary, onTertiary,
      // surfaceVariant, onSurfaceVariant,
      // outline, outlineVariant, etc. for more detailed theming.
      surfaceContainerHighest:
          Colors.grey.shade800, // Example for elevated surfaces
      outlineVariant: Colors.grey.shade700, // Example for subtle borders
    );

    // --- Text Theme Definition ---
    // Defines default text styles for various text elements.
    // These styles will be applied throughout the app unless overridden.
    final TextTheme textTheme = TextTheme(
      displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          letterSpacing: 0.5), // Reduced letter spacing
      displayMedium: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface),
      displaySmall: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface),

      headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface),
      headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface),
      headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface), // Adjusted from 22

      titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface), // Using w600
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface),
      titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface),

      bodyLarge: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
          height: 1.4), // Added line height
      bodyMedium: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurface.withValues(alpha: 0.85),
          height: 1.4), // Slightly more opaque
      bodySmall: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface.withValues(alpha: 0.75),
          height: 1.3),

      // --- MAIN ADJUSTMENT FOR BUTTONS ---
      // labelLarge is typically used by ElevatedButton, TextButton, OutlinedButton child text.
      labelLarge: TextStyle(
        fontSize:
            15, // Adjusted to 15 (from your 16, original was 18) - find what suits best
        fontWeight: FontWeight.bold, // Kept bold
        color: colorScheme
            .onPrimary, // Default for ElevatedButton, may be overridden by button themes
        letterSpacing: 0.5, // Reduced letter spacing
      ),

      labelMedium: TextStyle(
        // Not actively used by default buttons but good for consistency for other labels.
        fontSize: 13, // Adjusted (e.g., 13)
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface, // Usually onSurface for general labels
      ),

      // --- OPTIONAL ADJUSTMENT FOR SMALLER LABELS ---
      labelSmall: TextStyle(
        fontSize: 11, // Adjusted to 11 (from your 12, original was 13)
        color: colorScheme.onSurface
            .withValues(alpha: 0.8), // Slightly less opaque
        letterSpacing: 0.25,
      ),
    );
    // .apply(fontFamily: _fontFamily); // Apply global font family if defined

    // --- ElevatedButton Theme ---
    // Defines the default style for all ElevatedButtons.
    final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            colorScheme.primary, // Use primary color for button background
        foregroundColor: colorScheme.onPrimary, // Text color on primary
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0)), // Softer pill shape
        padding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 28), // Adjusted padding
        // Ensures the updated textTheme.labelLarge is used
        textStyle: textTheme.labelLarge?.copyWith(
            // letterSpacing: 0.75 // You can further customize letter spacing here if needed
            ),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.2), // Subtle shadow
        disabledBackgroundColor: colorScheme.onSurface
            .withValues(alpha: 0.12), // Standard disabled background
        disabledForegroundColor: colorScheme.onSurface
            .withValues(alpha: 0.38), // Standard disabled foreground
      ),
    );

    // --- TextButton Theme ---
    // Defines the default style for all TextButtons.
    final TextButtonThemeData textButtonTheme = TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary, // Text color for TextButtons
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600), // Use labelLarge, but maybe less bold
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );

    // --- InputDecoration Theme (for TextFields) ---
    // Defines the default style for all InputDecorations (used by TextField, TextFormField).
    final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.5), // Example: slightly transparent surface
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide
            .none, // No border by default, rely on fillColor or underline
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: colorScheme.error, width: 2.0),
      ),
      labelStyle:
          textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,
      errorStyle:
          textTheme.bodySmall?.copyWith(color: colorScheme.error, fontSize: 11),
    );

    // --- AppBar Theme ---
    // Defines the default style for all AppBars.
    final AppBarTheme appBarTheme = AppBarTheme(
      backgroundColor: colorScheme
          .surface, // Or surfaceContainer for a slight elevation feel
      elevation: 0, // Minimalist flat AppBar, or a small value like 1 or 2
      scrolledUnderElevation: 2, // Elevation when content scrolls under AppBar
      iconTheme:
          IconThemeData(color: colorScheme.onSurface), // Icon color in AppBar
      actionsIconTheme:
          IconThemeData(color: colorScheme.primary), // Color for action icons
      titleTextStyle: textTheme.titleLarge
          ?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
      centerTitle: true, // Center titles by default
    );

    // --- BottomNavigationBar Theme ---
    final BottomNavigationBarThemeData bottomNavigationBarTheme =
        BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest, // Or surface
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      selectedLabelStyle:
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: textTheme.labelSmall,
      elevation: 2, // Subtle elevation
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    );

    // --- Final ThemeData ---
    // Assembles all the theme components.
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme, // Apply the adjusted TextTheme
      // fontFamily: _fontFamily, // Apply global font family if defined
      scaffoldBackgroundColor:
          colorScheme.surface, // Use background from colorScheme
      appBarTheme: appBarTheme,
      elevatedButtonTheme:
          elevatedButtonTheme, // Apply the updated ElevatedButtonTheme
      textButtonTheme: textButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      cardTheme: CardThemeData(
        // Default Card styling
        elevation: 1.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        color: colorScheme
            .surfaceContainer, // Slightly different from main surface
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      ),
      chipTheme: ChipThemeData(
        // Default Chip styling
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primary,
        labelStyle: textTheme.labelMedium
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        secondaryLabelStyle: textTheme.labelMedium
            ?.copyWith(color: colorScheme.onPrimary), // For selected chips
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        side: BorderSide.none,
      ),
      dialogTheme: DialogThemeData(
        // Default Dialog styling
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      visualDensity: VisualDensity
          .adaptivePlatformDensity, // Adapts density to the platform
      useMaterial3: true, // Enable Material 3 features and styling
      // checkboxTheme: CheckboxThemeData( /* ... */ ), // Example for Checkbox
      // radioTheme: RadioThemeData( /* ... */ ),       // Example for RadioButton
      // switchTheme: SwitchThemeData( /* ... */ ),     // Example for Switch
    );
  }

  // You can define a lightTheme similarly if needed.
  // static ThemeData get lightTheme { /* ... */ }
}
