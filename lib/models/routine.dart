// lib/models/routine.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Définition du modèle pour un seul exercice dans une routine
class RoutineExercise {
  final String name;
  final int sets;
  final String reps; // Peut être "8-10" ou "AMRAP" ou "60sec"
  final String weightSuggestionKg;
  final int restBetweenSetsSeconds;
  final String description;

  RoutineExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weightSuggestionKg,
    required this.restBetweenSetsSeconds,
    required this.description,
  });

  // Factory constructor pour créer un RoutineExercise à partir d'une Map (Firestore)
  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      name: map['name'] as String? ?? 'Unknown Exercise',
      sets: map['sets'] as int? ?? 0,
      reps: map['reps'] as String? ?? 'N/A',
      weightSuggestionKg: map['weightSuggestionKg'] as String? ?? 'N/A',
      restBetweenSetsSeconds: map['restBetweenSetsSeconds'] as int? ?? 0,
      description: map['description'] as String? ?? '',
    );
  }

  // Méthode pour convertir RoutineExercise en Map (pour Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weightSuggestionKg': weightSuggestionKg,
      'restBetweenSetsSeconds': restBetweenSetsSeconds,
      'description': description,
    };
  }
}

// Définition du modèle pour la routine hebdomadaire complète
class WeeklyRoutine {
  final String userId;
  final String name; // Nom de la routine (e.g., "Static Sample Routine")
  final Map<String, List<RoutineExercise>?>
      dailyWorkouts; // e.g., 'monday': [RoutineExercise(...)], 'tuesday': null
  final int durationInWeeks; // Durée prévue de la routine en semaines
  final Timestamp?
      createdAt; // Date et heure de génération de la routine, nullable au cas où elle vient d'une source sans ce champ initialement

  WeeklyRoutine({
    required this.userId,
    required this.name,
    required this.dailyWorkouts,
    required this.durationInWeeks,
    this.createdAt, // Peut être null si non encore sauvegardé ou si vient d'une ancienne structure
  });

  // Factory constructor pour créer un WeeklyRoutine à partir d'un DocumentSnapshot Firestore
  factory WeeklyRoutine.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, List<RoutineExercise>?> workouts = {};

    // Parcourir tous les jours de la semaine définis dans notre constante
    for (String dayKey in WeeklyRoutine.daysOfWeek) {
      if (data.containsKey(dayKey)) {
        final dayData = data[dayKey];
        if (dayData != null && dayData is List) {
          // Vérifie que les éléments de la liste sont bien des Map avant de caster
          workouts[dayKey] = dayData
              .whereType<
                  Map<String, dynamic>>() // Filtre pour ne garder que les Map
              .map((exData) => RoutineExercise.fromMap(exData))
              .toList();
          if (workouts[dayKey]!.isEmpty && dayData.isNotEmpty) {
            // Si après filtrage c'est vide mais la liste originale ne l'était pas,
            // cela peut indiquer un problème de format de données dans Firestore pour ce jour.
            print(
                "Warning: Exercises for day '$dayKey' could not be parsed correctly. Original data: $dayData");
            workouts[dayKey] =
                null; // Traiter comme un jour de repos en cas d'échec de parsing partiel
          } else if (workouts[dayKey]!.isEmpty) {
            workouts[dayKey] = null; // Jour de repos si la liste est vide
          }
        } else {
          workouts[dayKey] =
              null; // Jour de repos (ex: explicitement null dans Firestore)
        }
      } else {
        workouts[dayKey] =
            null; // Jour non défini dans Firestore = jour de repos
      }
    }

    return WeeklyRoutine(
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? 'Unnamed Routine',
      dailyWorkouts: workouts,
      durationInWeeks:
          data['durationInWeeks'] as int? ?? 8, // Valeur par défaut
      createdAt: data['createdAt'] as Timestamp?, // createdAt peut être null
    );
  }

  // Méthode pour convertir WeeklyRoutine en Map (pour Firestore)
  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = {
      'userId': userId,
      'name': name,
      'durationInWeeks': durationInWeeks,
      // 'createdAt' sera géré par FieldValue.serverTimestamp() lors de la sauvegarde initiale.
      // Si createdAt a déjà une valeur (par ex. lors d'une mise à jour), on pourrait vouloir la préserver :
      // if (createdAt != null) 'createdAt': createdAt,
    };

    // Ajoute les jours de la semaine et leurs exercices
    dailyWorkouts.forEach((day, exercises) {
      if (exercises != null && exercises.isNotEmpty) {
        data[day] = exercises.map((ex) => ex.toMap()).toList();
      } else {
        // Pour les jours de repos, on peut soit omettre la clé, soit la mettre à null.
        // Mettre à null est plus explicite.
        data[day] = null;
      }
    });

    return data;
  }

  // Constante statique pour l'ordre des jours (déplacée ici pour la centralisation)
  static const List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];
}

// L'extension n'est plus nécessaire si `daysOfWeek` est une constante statique dans la classe.
// Vous pouvez supprimer l'extension WeeklyRoutineDays si vous l'aviez ajoutée séparément.