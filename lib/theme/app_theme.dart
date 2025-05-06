// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Nom de police (optionnel)
  // static const String _fontFamily = 'VotrePolice';

  // --- Thème Sombre (Dark Theme) ---
  static ThemeData get darkTheme {
    // Définition du jeu de couleurs (Inchangé)
    final ColorScheme colorScheme = ColorScheme.dark(
      primary: Colors.blue.shade700,
      onPrimary: Colors.white,
      secondary: Colors.orangeAccent.shade400,
      onSecondary: Colors.black,
      surface: Colors.blue.shade800,
      onSurface: Colors.white.withOpacity(0.9),
      error: Colors.redAccent.shade200,
      onError: Colors.black,
      brightness: Brightness.dark,
    );

    // Définition des styles de texte (MODIFIÉ)
    final TextTheme textTheme = TextTheme(
      displayLarge: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          letterSpacing: 1.5),
      headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface),
      headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface),
      bodyLarge: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      bodyMedium: TextStyle(
          fontSize: 14, color: colorScheme.onSurface.withOpacity(0.8)),

      // --- AJUSTEMENT PRINCIPAL ICI ---
      labelLarge: TextStyle(
          fontSize:
              16, // <-- RÉDUIT DE 18 à 16 (ou une autre valeur qui vous convient)
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary),

      labelMedium: TextStyle(
          // Ce style n'est pas activement utilisé par les boutons par défaut, mais ajusté pour cohérence
          fontSize: 15, // <-- Ajusté (ex: 15)
          fontWeight: FontWeight.w500,
          color: colorScheme.onPrimary),

      // --- AJUSTEMENT OPTIONNEL ICI ---
      labelSmall: TextStyle(
          fontSize: 12, // <-- RÉDUIT DE 13 à 12 (ou gardez 13 si c'était bon)
          color: colorScheme.onSurface.withOpacity(0.9)),
    ); //.apply(fontFamily: _fontFamily);

    // Style ElevatedButton (MODIFIÉ pour utiliser le nouveau textTheme.labelLarge)
    final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        // Assure que le style de texte mis à jour est utilisé
        textStyle: textTheme.labelLarge
            ?.copyWith(letterSpacing: 1.0), // Utilise le labelLarge ajusté
        elevation: 2,
        disabledBackgroundColor: Colors.grey.shade600.withOpacity(0.5),
        disabledForegroundColor: Colors.white.withOpacity(0.7),
      ),
    );

    // Style TextButton (Inchangé)
    final TextButtonThemeData textButtonTheme =
        TextButtonThemeData(style: TextButton.styleFrom(/* ... */));

    // Style InputDecoration (Inchangé)
    final InputDecorationTheme inputDecorationTheme =
        InputDecorationTheme(/* ... */);

    // Style AppBar (Inchangé)
    final AppBarTheme appBarTheme = AppBarTheme(/* ... */);

    // ThemeData final (Référence le ElevatedButtonTheme mis à jour)
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme, // Applique le TextTheme ajusté
      fontFamily: null,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: appBarTheme,
      elevatedButtonTheme:
          elevatedButtonTheme, // Applique le ElevatedButtonTheme mis à jour
      textButtonTheme: textButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      checkboxTheme: CheckboxThemeData(/* ... */),
    );
  }
}
