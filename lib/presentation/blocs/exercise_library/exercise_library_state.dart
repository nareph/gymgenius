// lib/presentation/blocs/exercise_library/exercise_library_state.dart

import 'package:equatable/equatable.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

class ExerciseLibraryState extends Equatable {
  final List<ExercisePoolEntry> allExercises;
  final List<ExercisePoolEntry> filteredExercises;
  final String? searchQuery;
  final MuscleGroup? selectedMuscle;
  final EquipmentType? selectedEquipment;
  final ExerciseCategory? selectedCategory;
  final bool isLoading;
  final String? error;

  const ExerciseLibraryState({
    this.allExercises = const [],
    this.filteredExercises = const [],
    this.searchQuery,
    this.selectedMuscle,
    this.selectedEquipment,
    this.selectedCategory,
    this.isLoading = false,
    this.error,
  });

  ExerciseLibraryState copyWith({
    List<ExercisePoolEntry>? allExercises,
    List<ExercisePoolEntry>? filteredExercises,
    String? searchQuery,
    MuscleGroup? selectedMuscle,
    EquipmentType? selectedEquipment,
    ExerciseCategory? selectedCategory,
    bool? isLoading,
    String? error,
  }) {
    return ExerciseLibraryState(
      allExercises: allExercises ?? this.allExercises,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMuscle: selectedMuscle ?? this.selectedMuscle,
      selectedEquipment: selectedEquipment ?? this.selectedEquipment,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  int get exerciseCount => filteredExercises.length;

  bool get hasFilters =>
      searchQuery != null ||
      selectedMuscle != null ||
      selectedEquipment != null ||
      selectedCategory != null;

  List<MuscleGroup> get availableMuscles {
    final muscles = <MuscleGroup>{};
    for (final exercise in allExercises) {
      muscles.addAll(exercise.targetMuscles);
    }
    return muscles.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  List<EquipmentType> get availableEquipment {
    final equipment = <EquipmentType>{};
    for (final exercise in allExercises) {
      equipment.add(exercise.equipmentType);
    }
    return equipment.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  @override
  List<Object?> get props => [
        allExercises,
        filteredExercises,
        searchQuery,
        selectedMuscle,
        selectedEquipment,
        selectedCategory,
        isLoading,
        error,
      ];
}
