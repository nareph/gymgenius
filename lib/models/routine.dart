// lib/models/routine.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class RoutineExercise {
  final String id; // ID unique de l'exercice DANS la routine
  final String name;
  final int sets;
  final String reps;
  final String weightSuggestionKg;
  final int restBetweenSetsSeconds;
  final String description;

  RoutineExercise({
    String? id,
    required this.name,
    required this.sets,
    required this.reps,
    this.weightSuggestionKg = 'N/A',
    this.restBetweenSetsSeconds = 60,
    this.description = '',
  }) : id = id ?? uuid.v4(); // Génère un ID si non fourni

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      id: map['id'] as String? ?? uuid.v4(), // Assurer un ID
      name: map['name'] as String? ?? 'Unknown Exercise',
      sets: map['sets'] as int? ?? 3,
      reps: map['reps'] as String? ?? '8-12',
      weightSuggestionKg: map['weightSuggestionKg'] as String? ?? 'N/A',
      restBetweenSetsSeconds: map['restBetweenSetsSeconds'] as int? ?? 60,
      description: map['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weightSuggestionKg': weightSuggestionKg,
      'restBetweenSetsSeconds': restBetweenSetsSeconds,
      'description': description,
    };
  }

  // Pour la comparaison d'objets si vous en avez besoin (Provider, Set, etc.)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoutineExercise &&
        other.id ==
            id && // Comparaison principale par ID si disponible et unique
        other.name == name &&
        other.sets == sets &&
        other.reps == reps &&
        other.weightSuggestionKg == weightSuggestionKg &&
        other.restBetweenSetsSeconds == restBetweenSetsSeconds &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id
            .hashCode ^ // Utiliser l'ID pour le hashcode est souvent suffisant si l'ID est unique
        name.hashCode ^
        sets.hashCode ^
        reps.hashCode ^
        weightSuggestionKg.hashCode ^
        restBetweenSetsSeconds.hashCode ^
        description.hashCode;
  }
}

class WeeklyRoutine {
  final String id; // ID unique de cette instance de routine
  final String name;
  final Map<String, List<RoutineExercise>> dailyWorkouts;
  final int durationInWeeks;
  final Timestamp generatedAt; // Timestamp de Firestore
  final Timestamp expiresAt; // Timestamp de Firestore
  // final Map<String, dynamic>? onboardingSnapshot; // Optionnel pour l'audit

  WeeklyRoutine({
    required this.id,
    required this.name,
    required this.dailyWorkouts,
    required this.durationInWeeks,
    required this.generatedAt,
    required this.expiresAt,
    // this.onboardingSnapshot,
  });

  // Utilisé pour convertir le Map de Firestore en objet WeeklyRoutine
  factory WeeklyRoutine.fromMap(Map<String, dynamic> map) {
    Map<String, List<RoutineExercise>> parsedWorkouts = {};
    if (map['dailyWorkouts'] is Map) {
      (map['dailyWorkouts'] as Map).forEach((day, exercisesDynamic) {
        if (exercisesDynamic is List) {
          parsedWorkouts[day as String] = exercisesDynamic
              .map((exJson) =>
                  RoutineExercise.fromMap(exJson as Map<String, dynamic>))
              .toList();
        }
      });
    }
    return WeeklyRoutine(
      id: map['id'] as String? ?? uuid.v4(), // Assurer un ID
      name: map['name'] as String? ?? 'Unnamed Routine',
      dailyWorkouts: parsedWorkouts,
      durationInWeeks: map['durationInWeeks'] as int? ?? 4,
      generatedAt:
          map['generatedAt'] as Timestamp? ?? Timestamp.now(), // Fallback
      expiresAt: map['expiresAt'] as Timestamp? ??
          Timestamp.fromDate(DateTime.now().add(Duration(
              days: (map['durationInWeeks'] as int? ?? 4) * 7))), // Fallback
      // onboardingSnapshot: map['onboardingSnapshot'] as Map<String, dynamic>?,
    );
  }

  // Méthode pour convertir l'objet WeeklyRoutine en Map pour Firestore
  // N'est pas directement utilisée si on construit le Map manuellement dans HomeTabScreen
  // mais peut être utile ailleurs.
  Map<String, dynamic> toMapForFirestore() {
    return {
      'id': id,
      'name': name,
      'dailyWorkouts': dailyWorkouts.map(
        (key, value) => MapEntry(key, value.map((ex) => ex.toMap()).toList()),
      ),
      'durationInWeeks': durationInWeeks,
      'generatedAt': generatedAt,
      'expiresAt': expiresAt,
      // 'onboardingSnapshot': onboardingSnapshot,
    };
  }

  // Noms des jours pour itération, etc.
  static const List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  // Pour l'affichage dans TrackingTabScreen, createdAt et expiresAt sont importants
  // Ces champs sont lus depuis Firestore (où ils sont des Timestamps)
  // et convertis en DateTime dans la logique de l'UI.
  // Le constructeur fromFirestore n'est plus nécessaire si on utilise fromMap directement
  // avec les données du document utilisateur.
}
