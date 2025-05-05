// lib/screens/main_dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// HomeScreen n'est plus nécessaire ici si on utilise pushNamed pour la déconnexion
// import 'package:gymgenius/screens/home_screen.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  // Fonction de déconnexion
  Future<void> _logout(BuildContext context) async {
    // Accès aux couleurs du thème pour le SnackBar
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    try {
      await FirebaseAuth.instance.signOut();
      // Utilise pushNamedAndRemoveUntil pour revenir à la route d'accueil
      // Assure-toi que '/home' est bien la route pour HomeScreen dans main.dart
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home', // Route nommée de l'écran d'accueil
        (Route<dynamic> route) =>
            false, // Supprime toutes les routes précédentes
      );
    } catch (e) {
      print("Error logging out: $e");
      // Vérifie si le widget est toujours monté avant d'afficher le SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error logging out. Please try again.",
              // Utilise le style de texte du thème pour SnackBar
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onError),
            ),
            backgroundColor:
                colorScheme.error, // Utilise la couleur d'erreur du thème
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accès au thème
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Obtenir l'utilisateur
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // --- AppBar ---
      // Le style vient de AppBarTheme dans AppTheme
      appBar: AppBar(
        // Le style du titre vient du thème
        title: const Text("GymGenius Dashboard"),
        // Pas besoin de spécifier backgroundColor ici
        actions: [
          IconButton(
            // L'icône utilise la couleur de iconTheme de AppBarTheme
            icon: const Icon(Icons.logout),
            tooltip: "Log Out",
            onPressed: () => _logout(context),
          ),
        ],
      ),

      // --- Body ---
      // Le fond vient de scaffoldBackgroundColor dans AppTheme
      // body: Container( // Plus besoin de Container pour le fond dégradé
      //   decoration: BoxDecoration( ... gradient ...),
      // ),
      body: Center(
        // Garder Center si le contenu ne remplit pas l'écran
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Aligner en haut
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- Message de Bienvenue ---
              if (user != null)
                Padding(
                  // Ajout d'un padding pour espacer du haut
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Text(
                    "Welcome, ${user.email ?? 'Fitness Enthusiast'}!",
                    // Utilise un style de titre approprié du thème
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              // const SizedBox(height: 30), // Remplacé par Padding ci-dessus

              // --- Placeholder pour la Routine ---
              Card(
                // Le style (couleur de fond, forme, élévation) peut être défini
                // dans CardTheme dans AppTheme, ou on surcharge ici.
                // Utilisons les couleurs du thème pour la cohérence.
                color: colorScheme.surface.withOpacity(
                    0.8), // Couleur surface légèrement transparente
                // elevation: cardTheme.elevation ?? 2, // Utilise l'élévation du thème ou une valeur par défaut
                // shape: cardTheme.shape, // Utilise la forme du thème
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15.0)), // Ou forme spécifique ici

                child: Padding(
                  padding: const EdgeInsets.all(20.0), // Padding augmenté
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        // Utilise la couleur secondaire (orange) du thème
                        color: colorScheme.secondary,
                        size: 45, // Taille augmentée
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Your AI-Generated Routine",
                        // Utilise un style du thème pour les titres de section
                        style: textTheme
                            .titleLarge, // Ou headlineSmall si plus approprié
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Your personalized workout plan based on your goals and preferences will appear here soon.",
                        // Utilise un style de corps de texte du thème
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Autres sections potentielles ---
              // Si vous ajoutez des boutons ici, ils utiliseront le style ElevatedButton du thème
              // ElevatedButton(onPressed: () {}, child: Text("View Stats")),
              // ElevatedButton(onPressed: () {}, child: Text("Log Workout")),

              const Spacer(), // Pousse le contenu vers le haut

              // --- Affichage UID (pour info/debug) ---
              Text(
                "User UID: ${user?.uid ?? 'Loading...'}",
                // Utilise un style de texte petit et discret du thème
                style: textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
