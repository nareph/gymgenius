// Exemple: lib/models/routine.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Représente un exercice dans la routine
class RoutineExercise {
  final String name;
  final int sets;
  final String
      reps; // Garder en String pour flexibilité ("8-12", "AMRAP", "15")
  final String
      weightSuggestionKg; // Garder en String ("50kg", "Bodyweight", "Machine 5")
  final int restBetweenSetsSeconds;
  // --- Champs pour l'étape 2 ---
  final String? description; // Description de l'exercice
  final String? gifUrl; // URL du GIF illustratif
  final List<String>?
      targetMuscles; // Liste des muscles ciblés (e.g., ['chest', 'triceps'])

  RoutineExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weightSuggestionKg,
    required this.restBetweenSetsSeconds,
    this.description, // Optionnel pour l'instant
    this.gifUrl, // Optionnel pour l'instant
    this.targetMuscles, // Optionnel pour l'instant
  });

  // Méthode pour convertir depuis une Map (ex: JSON parsé ou Firestore)
  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      name: map['name'] ?? 'Unknown Exercise',
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? '8-12',
      weightSuggestionKg: map['weight_suggestion_kg']?.toString() ?? 'N/A',
      restBetweenSetsSeconds: map['rest_between_sets_seconds'] ?? 60,
      description: map['description'],
      gifUrl: map['gifUrl'],
      targetMuscles: map['targetMuscles'] != null
          ? List<String>.from(map['targetMuscles'])
          : null,
    );
  }

  // Méthode pour convertir en Map (utile pour sauvegarder dans Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight_suggestion_kg': weightSuggestionKg,
      'rest_between_sets_seconds': restBetweenSetsSeconds,
      'description': description,
      'gifUrl': gifUrl,
      'targetMuscles': targetMuscles,
    };
  }
}

// Représente l'ensemble de la routine hebdomadaire
class WeeklyRoutine {
  final String userId; // À qui appartient cette routine
  final Timestamp generatedAt; // Quand elle a été générée
  // Map où la clé est le jour (lowercase: "monday", "tuesday", etc.)
  // et la valeur est soit une List<RoutineExercise>, soit null/String("Rest Day")
  final Map<String, List<RoutineExercise>?>
      dailyWorkouts; // Utilise List? pour les jours de repos

  WeeklyRoutine({
    required this.userId,
    required this.generatedAt,
    required this.dailyWorkouts,
  });

  // Méthode pour convertir depuis un DocumentSnapshot de Firestore
  factory WeeklyRoutine.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, List<RoutineExercise>?> parsedWorkouts = {};

    // Itérer sur les jours possibles (ou les clés présentes dans data)
    for (var day in [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ]) {
      if (data.containsKey(day)) {
        final dayData = data[day];
        if (dayData is List) {
          // C'est une liste d'exercices
          parsedWorkouts[day] = dayData
              .map((exerciseMap) =>
                  RoutineExercise.fromMap(exerciseMap as Map<String, dynamic>))
              .toList();
        } else {
          // C'est probablement "Rest Day" ou null, on le met à null
          parsedWorkouts[day] = null;
        }
      } else {
        // Le jour n'est pas dans les données, on le met à null (repos)
        parsedWorkouts[day] = null;
      }
    }

    return WeeklyRoutine(
      userId: data['userId'] ?? '',
      generatedAt: data['generatedAt'] ?? Timestamp.now(),
      dailyWorkouts: parsedWorkouts,
    );
  }

  // Méthode pour convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    // Convertit la map d'exercices en une map stockable
    Map<String, dynamic> firestoreDailyWorkouts = {};
    dailyWorkouts.forEach((day, exercises) {
      if (exercises != null) {
        firestoreDailyWorkouts[day] = exercises.map((e) => e.toMap()).toList();
      } else {
        firestoreDailyWorkouts[day] = "Rest Day"; // Ou null si vous préférez
      }
    });

    return {
      'userId': userId,
      'generatedAt': generatedAt,
      ...firestoreDailyWorkouts, // Ajoute directement les jours (monday: [...], tuesday: "Rest Day", ...)
    };
  }
}
