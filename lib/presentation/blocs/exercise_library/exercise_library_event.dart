// lib/presentation/blocs/exercise_library/exercise_library_event.dart

import 'package:equatable/equatable.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';

abstract class ExerciseLibraryEvent extends Equatable {
  const ExerciseLibraryEvent();

  @override
  List<Object?> get props => [];
}

class ExerciseLibraryInitialized extends ExerciseLibraryEvent {}

class ExerciseLibrarySearchChanged extends ExerciseLibraryEvent {
  final String query;

  const ExerciseLibrarySearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ExerciseLibraryMuscleFilterChanged extends ExerciseLibraryEvent {
  final MuscleGroup? muscle;

  const ExerciseLibraryMuscleFilterChanged(this.muscle);

  @override
  List<Object?> get props => [muscle];
}

class ExerciseLibraryEquipmentFilterChanged extends ExerciseLibraryEvent {
  final EquipmentType? equipment;

  const ExerciseLibraryEquipmentFilterChanged(this.equipment);

  @override
  List<Object?> get props => [equipment];
}

class ExerciseLibraryCategoryFilterChanged extends ExerciseLibraryEvent {
  final ExerciseCategory? category;

  const ExerciseLibraryCategoryFilterChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class ExerciseLibraryFiltersCleared extends ExerciseLibraryEvent {}

class ExerciseLibraryExerciseSelected extends ExerciseLibraryEvent {
  final String exerciseId;

  const ExerciseLibraryExerciseSelected(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}
