// lib/presentation/screens/exercise_library/exercise_library_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/presentation/blocs/exercise_library/exercise_library_bloc.dart';
import 'package:gymgenius/presentation/blocs/exercise_library/exercise_library_event.dart';
import 'package:gymgenius/presentation/blocs/exercise_library/exercise_library_state.dart';
import 'package:gymgenius/presentation/screens/exercise_library/exercise_detail_screen.dart';
import 'package:gymgenius/presentation/screens/exercise_library/widgets/exercise_card.dart';
import 'package:gymgenius/presentation/screens/exercise_library/widgets/exercise_filter_chip.dart';
import 'package:gymgenius/presentation/screens/exercise_library/widgets/exercise_search_bar.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => const ExerciseLibraryScreen(),
    );
  }

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  late final ExerciseLibraryBloc _bloc;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _bloc = ExerciseLibraryBloc()..add(ExerciseLibraryInitialized());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: _showFilters ? colorScheme.primary : null,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: _showFilters ? 'Hide filters' : 'Show filters',
          ),
          if (_showFilters)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                _bloc.add(ExerciseLibraryFiltersCleared());
              },
              tooltip: 'Clear all filters',
            ),
        ],
      ),
      body: BlocProvider.value(
        value: _bloc,
        child: Column(
          children: [
            // Search bar
            const ExerciseSearchBar(),
            // Filter chips (collapsible)
            if (_showFilters) _buildFilterChips(context),
            // Results
            Expanded(
              child: BlocBuilder<ExerciseLibraryBloc, ExerciseLibraryState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading exercises',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error!,
                            style: textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _bloc.add(ExerciseLibraryInitialized());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.filteredExercises.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: colorScheme.onSurface.withAlpha(102),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No exercises found',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha(102),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = state.filteredExercises[index];
                      return ExerciseCard(
                        exercise: exercise,
                        onTap: () {
                          Navigator.push(
                            context,
                            ExerciseDetailScreen.route(exercise),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Footer with count
            Padding(
              padding: const EdgeInsets.all(12),
              child: BlocBuilder<ExerciseLibraryBloc, ExerciseLibraryState>(
                builder: (context, state) {
                  return Text(
                    '${state.exerciseCount} exercises found',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha(153),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return BlocBuilder<ExerciseLibraryBloc, ExerciseLibraryState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Muscle group filter
                ExerciseFilterChip(
                  label: state.selectedMuscle?.displayName ?? 'Muscle',
                  icon: Icons.fitness_center,
                  isActive: state.selectedMuscle != null,
                  onTap: () => _showMuscleFilterDialog(context),
                ),
                const SizedBox(width: 8),
                // Equipment filter
                ExerciseFilterChip(
                  label: state.selectedEquipment?.displayName ?? 'Equipment',
                  icon: Icons.build,
                  isActive: state.selectedEquipment != null,
                  onTap: () => _showEquipmentFilterDialog(context),
                ),
                const SizedBox(width: 8),
                // Category filter
                ExerciseFilterChip(
                  label: state.selectedCategory?.displayName ?? 'Type',
                  icon: Icons.category,
                  isActive: state.selectedCategory != null,
                  onTap: () => _showCategoryFilterDialog(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMuscleFilterDialog(BuildContext context) {
    final state = _bloc.state;
    final selected = state.selectedMuscle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Muscle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a muscle group to filter exercises',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153),
                        ),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<MuscleGroup?>(
                    groupValue: selected,
                    onChanged: (newValue) {
                      _bloc.add(ExerciseLibraryMuscleFilterChanged(newValue));
                      Navigator.pop(context);
                    },
                    child: Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: state.availableMuscles.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return RadioListTile<MuscleGroup?>(
                              value: null,
                              title: Text(
                                'All Muscles',
                                style: TextStyle(
                                  fontWeight: selected == null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }
                          final muscle = state.availableMuscles[index - 1];
                          return RadioListTile<MuscleGroup?>(
                            value: muscle,
                            title: Text(
                              muscle.displayName,
                              style: TextStyle(
                                fontWeight: selected == muscle
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEquipmentFilterDialog(BuildContext context) {
    final state = _bloc.state;
    final selected = state.selectedEquipment;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Equipment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select equipment type to filter exercises',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153),
                        ),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<EquipmentType?>(
                    groupValue: selected,
                    onChanged: (newValue) {
                      _bloc
                          .add(ExerciseLibraryEquipmentFilterChanged(newValue));
                      Navigator.pop(context);
                    },
                    child: Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: state.availableEquipment.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return RadioListTile<EquipmentType?>(
                              value: null,
                              title: Text(
                                'All Equipment',
                                style: TextStyle(
                                  fontWeight: selected == null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }
                          final equipment = state.availableEquipment[index - 1];
                          return RadioListTile<EquipmentType?>(
                            value: equipment,
                            title: Text(
                              equipment.displayName,
                              style: TextStyle(
                                fontWeight: selected == equipment
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCategoryFilterDialog(BuildContext context) {
    final state = _bloc.state;
    final selected = state.selectedCategory;
    final categories = ExerciseCategory.values;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Exercise Type',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select category to filter exercises',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(153),
                        ),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<ExerciseCategory?>(
                    groupValue: selected,
                    onChanged: (newValue) {
                      _bloc.add(ExerciseLibraryCategoryFilterChanged(newValue));
                      Navigator.pop(context);
                    },
                    child: Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return RadioListTile<ExerciseCategory?>(
                              value: null,
                              title: Text(
                                'All Types',
                                style: TextStyle(
                                  fontWeight: selected == null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }
                          final category = categories[index - 1];
                          return RadioListTile<ExerciseCategory?>(
                            value: category,
                            title: Text(
                              category.displayName,
                              style: TextStyle(
                                fontWeight: selected == category
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
