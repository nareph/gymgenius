// lib/presentation/screens/exercise_library/models/exercise_filter.dart

import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';

class ExerciseFilter {
  final String? searchQuery;
  final MuscleGroup? muscleGroup;
  final EquipmentType? equipmentType;
  final ExerciseCategory? category;

  const ExerciseFilter({
    this.searchQuery,
    this.muscleGroup,
    this.equipmentType,
    this.category,
  });

  ExerciseFilter copyWith({
    String? searchQuery,
    MuscleGroup? muscleGroup,
    EquipmentType? equipmentType,
    ExerciseCategory? category,
  }) {
    return ExerciseFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipmentType: equipmentType ?? this.equipmentType,
      category: category ?? this.category,
    );
  }

  bool get isEmpty =>
      searchQuery == null &&
      muscleGroup == null &&
      equipmentType == null &&
      category == null;

  bool get isNotEmpty => !isEmpty;
}
