// lib/presentation/blocs/exercise_library/exercise_library_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercises/splits/exports.dart';
import 'package:gymgenius/presentation/blocs/exercise_library/exercise_library_event.dart';
import 'package:gymgenius/presentation/blocs/exercise_library/exercise_library_state.dart';

class ExerciseLibraryBloc
    extends Bloc<ExerciseLibraryEvent, ExerciseLibraryState> {
  ExerciseLibraryBloc() : super(const ExerciseLibraryState()) {
    on<ExerciseLibraryInitialized>(_onInitialized);
    on<ExerciseLibrarySearchChanged>(_onSearchChanged);
    on<ExerciseLibraryMuscleFilterChanged>(_onMuscleFilterChanged);
    on<ExerciseLibraryEquipmentFilterChanged>(_onEquipmentFilterChanged);
    on<ExerciseLibraryCategoryFilterChanged>(_onCategoryFilterChanged);
    on<ExerciseLibraryFiltersCleared>(_onFiltersCleared);
  }

  Future<void> _onInitialized(
    ExerciseLibraryInitialized event,
    Emitter<ExerciseLibraryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Load all exercises from the exports
      final allExercises = _loadAllExercises();
      emit(state.copyWith(
        allExercises: allExercises,
        filteredExercises: allExercises,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load exercises: $e',
      ));
    }
  }

  List<ExercisePoolEntry> _loadAllExercises() {
    return [
      ...chestExercises,
      ...backExercises,
      ...legsExercises,
      ...armsExercises,
      ...shouldersCoreExercises,
      ...pullExercises,
      ...pushExercises,
      ...chestTricepsExercises,
      ...backBicepsExercises,
      ...upperBodyExercises,
      ...lowerBodyExercises,
    ];
  }

  void _onSearchChanged(
    ExerciseLibrarySearchChanged event,
    Emitter<ExerciseLibraryState> emit,
  ) {
    final query = event.query.trim();
    emit(state.copyWith(searchQuery: query.isEmpty ? null : query));
    _applyFilters(emit);
  }

  void _onMuscleFilterChanged(
    ExerciseLibraryMuscleFilterChanged event,
    Emitter<ExerciseLibraryState> emit,
  ) {
    emit(state.copyWith(selectedMuscle: event.muscle));
    _applyFilters(emit);
  }

  void _onEquipmentFilterChanged(
    ExerciseLibraryEquipmentFilterChanged event,
    Emitter<ExerciseLibraryState> emit,
  ) {
    emit(state.copyWith(selectedEquipment: event.equipment));
    _applyFilters(emit);
  }

  void _onCategoryFilterChanged(
    ExerciseLibraryCategoryFilterChanged event,
    Emitter<ExerciseLibraryState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
    _applyFilters(emit);
  }

  void _onFiltersCleared(
    ExerciseLibraryFiltersCleared event,
    Emitter<ExerciseLibraryState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: null,
      selectedMuscle: null,
      selectedEquipment: null,
      selectedCategory: null,
    ));
    _applyFilters(emit);
  }

  void _applyFilters(Emitter<ExerciseLibraryState> emit) {
    final state = this.state;
    List<ExercisePoolEntry> filtered = List.from(state.allExercises);

    // Apply search query
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      final query = state.searchQuery!.toLowerCase();
      filtered = filtered.where((exercise) {
        return exercise.name.toLowerCase().contains(query) ||
            exercise.id.toLowerCase().contains(query);
      }).toList();
    }

    // Apply muscle filter
    if (state.selectedMuscle != null) {
      filtered = filtered.where((exercise) {
        return exercise.targetMuscles.contains(state.selectedMuscle);
      }).toList();
    }

    // Apply equipment filter
    if (state.selectedEquipment != null) {
      filtered = filtered.where((exercise) {
        return exercise.equipmentType == state.selectedEquipment;
      }).toList();
    }

    // Apply category filter
    if (state.selectedCategory != null) {
      filtered = filtered.where((exercise) {
        return exercise.category == state.selectedCategory;
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    emit(state.copyWith(filteredExercises: filtered));
  }
}
