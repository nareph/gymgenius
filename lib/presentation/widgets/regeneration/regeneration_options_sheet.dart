// lib/presentation/widgets/regeneration/regeneration_options_sheet.dart

import 'package:flutter/material.dart';
import 'package:gymgenius/core/logger/logger_service.dart';
import 'package:gymgenius/domain/entities/exercise.dart';
import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';
import 'package:gymgenius/domain/entities/weekly_workout.dart';

enum RegenerationType {
  fullProgram,
  specificDay,
  singleExercise,
  withPreferences,
}

enum IntensityLevel {
  easier,
  similar,
  harder,
}

class RegenerationOptions {
  final RegenerationType type;
  final String? targetDay;
  final String? targetExerciseId;
  final String? newEquipmentPreference;
  final List<String>? musclesToFocus;
  final List<String>? musclesToAvoid;
  final IntensityLevel intensity;
  final int? exerciseCount;
  final bool keepStructure;

  const RegenerationOptions({
    required this.type,
    this.targetDay,
    this.targetExerciseId,
    this.newEquipmentPreference,
    this.musclesToFocus,
    this.musclesToAvoid,
    this.intensity = IntensityLevel.similar,
    this.exerciseCount,
    this.keepStructure = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      if (targetDay != null) 'targetDay': targetDay,
      if (targetExerciseId != null) 'targetExerciseId': targetExerciseId,
      if (newEquipmentPreference != null)
        'newEquipment': newEquipmentPreference,
      if (musclesToFocus != null) 'focusMuscles': musclesToFocus,
      if (musclesToAvoid != null) 'avoidMuscles': musclesToAvoid,
      'intensity': intensity.name,
      if (exerciseCount != null) 'exerciseCount': exerciseCount,
      'keepStructure': keepStructure,
    };
  }
}

class RegenerationOptionsSheet extends StatefulWidget {
  final HealthProfile? healthProfile;
  final TrainingProgram? currentProgram;
  final WeeklyWorkout? currentWeeklyWorkout;
  final String? currentDay;
  final String? targetExerciseId;
  final Function(RegenerationOptions) onApply;

  const RegenerationOptionsSheet({
    super.key,
    this.healthProfile,
    this.currentProgram,
    this.currentWeeklyWorkout,
    this.currentDay,
    this.targetExerciseId,
    required this.onApply,
  });

  @override
  State<RegenerationOptionsSheet> createState() =>
      _RegenerationOptionsSheetState();
}

class _RegenerationOptionsSheetState extends State<RegenerationOptionsSheet> {
  late RegenerationType _selectedType;
  String? _targetDay;
  String? _targetExerciseId;
  String? _newEquipment;
  final List<String> _musclesToFocus = [];
  final List<String> _musclesToAvoid = [];
  IntensityLevel _intensity = IntensityLevel.similar;
  bool _keepStructure = true;
  int? _exerciseCount;
  List<String> _availableWorkoutDays = [];
  List<Map<String, dynamic>> _availableExercises = [];

  late final List<String> _userMuscleGroups;
  late final List<String> _availableEquipment;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.targetExerciseId != null
        ? RegenerationType.singleExercise
        : (widget.currentDay != null
            ? RegenerationType.specificDay
            : RegenerationType.fullProgram);

    _targetDay = widget.currentDay;
    _targetExerciseId = widget.targetExerciseId;

    // Get equipment and focus areas from HealthProfile
    final profile = widget.healthProfile;
    if (profile != null) {
      _availableEquipment =
          profile.training.equipment.map((e) => e.name).toList();
      _userMuscleGroups =
          profile.training.focusAreas.map((m) => m.name).toList();
    } else {
      _availableEquipment = ['bodyweight'];
      _userMuscleGroups = [
        'chest',
        'back',
        'quadriceps',
        'hamstrings',
        'glutes',
        'shoulders',
        'biceps',
        'triceps',
        'calves',
        'abs_core',
        'traps',
        'forearms',
      ];
    }

    if (_availableEquipment.isEmpty) {
      _availableEquipment.add('bodyweight');
    }

    _loadAvailableWorkoutDays();

    if (_targetDay != null) {
      _loadAvailableExercises(_targetDay!);
    }
  }

  void _loadAvailableWorkoutDays() {
    final program = widget.currentProgram;
    if (program != null && program.weeklySchedule.isNotEmpty) {
      _availableWorkoutDays = program.weeklySchedule.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) => entry.key)
          .toList();
    } else {
      _availableWorkoutDays = [];
    }
  }

  void _loadAvailableExercises(String day) {
    final program = widget.currentProgram;
    if (program != null) {
      final exercises = program.weeklySchedule[day];
      if (exercises!.isNotEmpty) {
        setState(() {
          _availableExercises =
              exercises.map((e) => _exerciseToMap(e)).toList();
        });
      } else {
        _availableExercises = [];
      }
    }
  }

  Map<String, dynamic> _exerciseToMap(Exercise exercise) {
    return {
      'id': exercise.id,
      'name': exercise.name,
      'sets': exercise.sets,
      'reps': exercise.reps,
      'description': exercise.description,
      'isTimed': exercise.isTimed,
      'usesWeight': exercise.isBodyweight,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(), style: textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _canApply() ? _applyOptions : null,
            tooltip: 'Apply',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTypeSelector(),
          const SizedBox(height: 20),
          if (_selectedType == RegenerationType.specificDay) ...[
            _buildDaySelector(),
            const SizedBox(height: 16),
          ],
          if (_selectedType == RegenerationType.singleExercise) ...[
            _buildDaySelector(),
            const SizedBox(height: 16),
            if (_targetDay != null) ...[
              _buildExerciseSelector(),
              const SizedBox(height: 16),
            ],
          ],
          if (_selectedType == RegenerationType.withPreferences) ...[
            _buildEquipmentSelector(),
            const SizedBox(height: 16),
            _buildMuscleFocusSelector(),
            const SizedBox(height: 16),
            _buildMuscleAvoidSelector(),
            const SizedBox(height: 16),
          ],
          if (_selectedType == RegenerationType.specificDay ||
              _selectedType == RegenerationType.withPreferences) ...[
            _buildIntensitySelector(),
            const SizedBox(height: 16),
          ],
          _buildStructureSelector(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _canApply() ? _applyOptions : null,
            icon: const Icon(Icons.auto_awesome),
            label: Text(
              _getActionButtonText(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to regenerate?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip(
              RegenerationType.fullProgram,
              'Complete Program',
              Icons.refresh,
            ),
            _buildTypeChip(
              RegenerationType.specificDay,
              'Specific Day',
              Icons.calendar_today,
            ),
            _buildTypeChip(
              RegenerationType.singleExercise,
              'Single Exercise',
              Icons.fitness_center,
            ),
            _buildTypeChip(
              RegenerationType.withPreferences,
              'With Preferences',
              Icons.tune,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(RegenerationType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = type;
          if (type != RegenerationType.specificDay &&
              type != RegenerationType.singleExercise) {
            _targetDay = null;
            _targetExerciseId = null;
          }
        });
      },
      selectedColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
    );
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Day',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_availableWorkoutDays.isEmpty)
          Text(
            'No workout days available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableWorkoutDays.map((day) {
              final isSelected = _targetDay == day;
              return ChoiceChip(
                label: Text(_formatDayName(day)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _targetDay = selected ? day : null;
                    _targetExerciseId = null;
                    if (selected) {
                      _loadAvailableExercises(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildExerciseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Exercise to Replace',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_availableExercises.isEmpty)
          Text(
            'No exercises available for this day',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableExercises.length,
            itemBuilder: (context, index) {
              final exercise = _availableExercises[index];
              final exerciseId = exercise['id'] ?? 'exercise_$index';
              final isSelected = _targetExerciseId == exerciseId;
              final name = exercise['name'] as String? ?? 'Unknown Exercise';
              final sets = exercise['sets'] ?? 3;
              final reps = exercise['reps'] ?? '8-12';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  leading: Icon(
                    Icons.fitness_center,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(name),
                  subtitle: Text('$sets sets × $reps'),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _targetExerciseId = isSelected ? null : exerciseId;
                    });
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEquipmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Equipment',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableEquipment.map((equipment) {
            final isSelected = _newEquipment == equipment;
            return ChoiceChip(
              label: Text(_formatEquipmentName(equipment)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _newEquipment = selected ? equipment : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMuscleFocusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Focus on these muscles',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _userMuscleGroups.map((muscle) {
            final isSelected = _musclesToFocus.contains(muscle);
            return FilterChip(
              label: Text(_formatMuscleName(muscle)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _musclesToFocus.add(muscle);
                  } else {
                    _musclesToFocus.remove(muscle);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMuscleAvoidSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avoid these muscles',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _userMuscleGroups.map((muscle) {
            final isSelected = _musclesToAvoid.contains(muscle);
            return FilterChip(
              label: Text(_formatMuscleName(muscle)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _musclesToAvoid.add(muscle);
                  } else {
                    _musclesToAvoid.remove(muscle);
                  }
                });
              },
              selectedColor:
                  Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intensity Level',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<IntensityLevel>(
          segments: const [
            ButtonSegment<IntensityLevel>(
              value: IntensityLevel.easier,
              label: Text('Easier'),
              icon: Icon(Icons.arrow_downward),
            ),
            ButtonSegment<IntensityLevel>(
              value: IntensityLevel.similar,
              label: Text('Similar'),
              icon: Icon(Icons.compare_arrows),
            ),
            ButtonSegment<IntensityLevel>(
              value: IntensityLevel.harder,
              label: Text('Harder'),
              icon: Icon(Icons.arrow_upward),
            ),
          ],
          selected: {_intensity},
          onSelectionChanged: (Set<IntensityLevel> newSelection) {
            setState(() {
              _intensity = newSelection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStructureSelector() {
    return SwitchListTile(
      title: const Text('Keep current structure'),
      subtitle: const Text('Similar exercise count and order'),
      value: _keepStructure,
      onChanged: (value) {
        setState(() {
          _keepStructure = value;
        });
      },
    );
  }

  bool _canApply() {
    switch (_selectedType) {
      case RegenerationType.fullProgram:
      case RegenerationType.withPreferences:
        return true;
      case RegenerationType.specificDay:
        return _targetDay != null;
      case RegenerationType.singleExercise:
        return _targetDay != null && _targetExerciseId != null;
    }
  }

  String _formatEquipmentName(String equipment) {
    final Map<String, String> displayNames = {
      'bodyweight': 'Bodyweight',
      'resistance_bands': 'Resistance Bands',
      'jump_rope': 'Jump Rope',
      'homemade_weights': 'Homemade Weights',
      'gym_machines_selectorized': 'Gym Machines',
      'dumbbells': 'Dumbbells',
      'barbell': 'Barbell',
      'kettlebell': 'Kettlebell',
      'pull_up_bar': 'Pull-up Bar',
      'yoga_mat': 'Yoga Mat',
    };
    return displayNames[equipment] ?? equipment.replaceAll('_', ' ');
  }

  String _formatMuscleName(String muscle) {
    final Map<String, String> displayNames = {
      'chest': 'Chest',
      'back': 'Back',
      'quadriceps': 'Quadriceps',
      'hamstrings': 'Hamstrings',
      'glutes': 'Glutes',
      'shoulders': 'Shoulders',
      'biceps': 'Biceps',
      'triceps': 'Triceps',
      'calves': 'Calves',
      'abs_core': 'Abs/Core',
      'traps': 'Traps',
      'forearms': 'Forearms',
    };
    return displayNames[muscle] ?? muscle.replaceAll('_', ' ');
  }

  String _formatDayName(String day) {
    return day[0].toUpperCase() + day.substring(1);
  }

  String _getTitle() {
    switch (_selectedType) {
      case RegenerationType.fullProgram:
        return 'Regenerate Complete Program';
      case RegenerationType.specificDay:
        return 'Regenerate Specific Day';
      case RegenerationType.singleExercise:
        return 'Replace Single Exercise';
      case RegenerationType.withPreferences:
        return 'Custom Regeneration';
    }
  }

  String _getActionButtonText() {
    switch (_selectedType) {
      case RegenerationType.fullProgram:
        return 'GENERATE NEW PROGRAM';
      case RegenerationType.specificDay:
        return _targetDay != null
            ? 'REGENERATE ${_targetDay!.toUpperCase()}'
            : 'SELECT A DAY';
      case RegenerationType.singleExercise:
        return _targetExerciseId != null
            ? 'REPLACE EXERCISE'
            : 'SELECT AN EXERCISE';
      case RegenerationType.withPreferences:
        return 'GENERATE WITH PREFERENCES';
    }
  }

  void _applyOptions() {
    if (!_canApply()) return;
    final options = RegenerationOptions(
      type: _selectedType,
      targetDay: _targetDay,
      targetExerciseId: _targetExerciseId,
      newEquipmentPreference: _newEquipment,
      musclesToFocus: _musclesToFocus.isNotEmpty ? _musclesToFocus : null,
      musclesToAvoid: _musclesToAvoid.isNotEmpty ? _musclesToAvoid : null,
      intensity: _intensity,
      exerciseCount: _exerciseCount,
      keepStructure: _keepStructure,
    );

    Log.debug('Applying regeneration options: ${options.toMap()}',
        tag: 'Regeneration');

    widget.onApply(options);
    Navigator.pop(context);
  }
}
