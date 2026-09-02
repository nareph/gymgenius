// tool/generate_catalog_definitions.dart

import 'dart:io';

import 'package:gymgenius/domain/enums/exports.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercises/splits/exports.dart';

void main() {
  final exercises = _getCanonicalExercisesWithSplits();
  final grouped = <String, List<ExercisePoolEntry>>{};

  for (final entry in exercises) {
    if (entry.targetMuscles.isEmpty) {
      continue;
    }

    final primaryMuscle = entry.targetMuscles.first;
    final key = _muscleToFileName(primaryMuscle);

    grouped.putIfAbsent(key, () => <ExercisePoolEntry>[]).add(entry);
  }

  final outputDir = Directory(
    'lib/engines/workout_engine/shared/exercises/catalog/definitions',
  );

  outputDir.createSync(recursive: true);

  for (final entry in grouped.entries) {
    final fileName = '${entry.key}_exercises.dart';
    final file = File('${outputDir.path}/$fileName');

    final sortedEntries = [...entry.value]
      ..sort((a, b) => a.id.compareTo(b.id));

    final content = _generateFileContent(
      entry.key,
      sortedEntries,
    );

    file.writeAsStringSync(content);

    print(
      '✅ Generated $fileName (${sortedEntries.length} exercises)',
    );
  }

  _removeObsoleteFiles(outputDir);

  final total = grouped.values.fold<int>(
    0,
    (sum, entries) => sum + entries.length,
  );

  print('🎉 Done.');
  print('📦 Generated $total canonical exercise definitions.');
}

/// Builds one canonical entry per exercise ID.
///
/// When the same ID is present in several legacy split pools, the exercise
/// is kept only once and all source split names are merged into
/// [compatibleSplits].
List<ExercisePoolEntry> _getCanonicalExercisesWithSplits() {
  final canonical = <String, _CanonicalExercise>{};

  final sources = <_ExerciseSource>[
    _ExerciseSource(
      splitName: 'Chest',
      exercises: chestExercises,
    ),
    _ExerciseSource(
      splitName: 'Back',
      exercises: backExercises,
    ),
    _ExerciseSource(
      splitName: 'Legs',
      exercises: legsExercises,
    ),
    _ExerciseSource(
      splitName: 'Core',
      exercises: coreExercises,
    ),
    _ExerciseSource(
      splitName: 'Arms',
      exercises: armsExercises,
    ),
    _ExerciseSource(
      splitName: 'Shoulders',
      exercises: shouldersExercises,
    ),
    _ExerciseSource(
      splitName: 'Pull',
      exercises: pullExercises,
    ),
    _ExerciseSource(
      splitName: 'Push',
      exercises: pushExercises,
    ),
    _ExerciseSource(
      splitName: 'Chest & Triceps',
      exercises: chestTricepsExercises,
    ),
    _ExerciseSource(
      splitName: 'Back & Biceps',
      exercises: backBicepsExercises,
    ),
    _ExerciseSource(
      splitName: 'Upper Body',
      exercises: upperBodyExercises,
    ),
    _ExerciseSource(
      splitName: 'Lower Body',
      exercises: lowerBodyExercises,
    ),
  ];

  for (final source in sources) {
    for (final entry in source.exercises) {
      final existing = canonical[entry.id];

      if (existing == null) {
        canonical[entry.id] = _CanonicalExercise(
          entry: entry,
          compatibleSplits: {
            source.splitName,
          },
        );
      } else {
        existing.compatibleSplits.add(source.splitName);
      }
    }
  }

  return canonical.values
      .map(
        (item) => _withCompatibleSplits(
          item.entry,
          item.compatibleSplits,
        ),
      )
      .toList();
}

/// Creates a new immutable [ExercisePoolEntry] containing the merged
/// split applicability metadata.
ExercisePoolEntry _withCompatibleSplits(
  ExercisePoolEntry source,
  Set<String> compatibleSplits,
) {
  return ExercisePoolEntry(
    id: source.id,
    name: source.name,
    category: source.category,
    difficulty: source.difficulty,
    equipmentType: source.equipmentType,
    targetMuscles: List<MuscleGroup>.unmodifiable(
      source.targetMuscles,
    ),
    secondaryMuscles: List<MuscleGroup>.unmodifiable(
      source.secondaryMuscles,
    ),
    compatibleSplits: Set<String>.unmodifiable(
      compatibleSplits,
    ),
    weightSuggestion: source.weightSuggestion,
    usesWeight: source.usesWeight,
    isTimed: source.isTimed,
    movementPattern: source.movementPattern,
    mechanics: source.mechanics,
    forceType: source.forceType,
    laterality: source.laterality,
    planeOfMotion: source.planeOfMotion,
    description: source.description,
  );
}

String _muscleToFileName(MuscleGroup muscle) {
  switch (muscle) {
    case MuscleGroup.chest:
      return 'chest';

    case MuscleGroup.back:
      return 'back';

    case MuscleGroup.shoulders:
    case MuscleGroup.traps:
      return 'shoulders';

    case MuscleGroup.biceps:
    case MuscleGroup.triceps:
    case MuscleGroup.forearms:
      return 'arms';

    case MuscleGroup.quadriceps:
    case MuscleGroup.hamstrings:
    case MuscleGroup.glutes:
    case MuscleGroup.calves:
    case MuscleGroup.adductors:
      return 'legs';

    case MuscleGroup.absCore:
      return 'core';

    default:
      return 'other';
  }
}

String _generateFileContent(
  String groupName,
  List<ExercisePoolEntry> entries,
) {
  final buffer = StringBuffer();

  buffer.writeln(
    '// lib/engines/workout_engine/shared/exercises/'
    'catalog/definitions/${groupName}_exercises.dart',
  );
  buffer.writeln('// ⚠️ AUTO-GENERATED – DO NOT EDIT MANUALLY');
  buffer.writeln();
  buffer.writeln(
    "import 'package:gymgenius/domain/enums/exports.dart';",
  );
  buffer.writeln(
    "import 'package:gymgenius/engines/workout_engine/shared/"
    "exercise_pool_entry.dart';",
  );
  buffer.writeln();
  buffer.writeln(
    '/// Canonical definitions for $groupName exercises.',
  );
  buffer.writeln(
    'const List<ExercisePoolEntry> ${groupName}Definitions = [',
  );

  for (final entry in entries) {
    _writeExercise(buffer, entry);
  }

  buffer.writeln('];');

  return buffer.toString();
}

void _writeExercise(
  StringBuffer buffer,
  ExercisePoolEntry entry,
) {
  final sortedSplits = [...entry.compatibleSplits]..sort();

  buffer.writeln('  ExercisePoolEntry(');

  buffer.writeln(
    '    id: ${_dartString(entry.id)},',
  );

  buffer.writeln(
    '    name: ${_dartString(entry.name)},',
  );

  buffer.writeln(
    '    category: ${entry.category},',
  );

  buffer.writeln(
    '    difficulty: ${entry.difficulty},',
  );

  buffer.writeln(
    '    equipmentType: ${entry.equipmentType},',
  );

  buffer.writeln('    targetMuscles: [');
  for (final muscle in entry.targetMuscles) {
    buffer.writeln('      $muscle,');
  }
  buffer.writeln('    ],');

  buffer.writeln('    secondaryMuscles: [');
  for (final muscle in entry.secondaryMuscles) {
    buffer.writeln('      $muscle,');
  }
  buffer.writeln('    ],');

  buffer.writeln('    compatibleSplits: {');
  for (final split in sortedSplits) {
    buffer.writeln(
      '      ${_dartString(split)},',
    );
  }
  buffer.writeln('    },');

  if (entry.weightSuggestion != null) {
    buffer.writeln(
      '    weightSuggestion: '
      '${_dartString(entry.weightSuggestion!)},',
    );
  }

  buffer.writeln(
    '    usesWeight: ${entry.usesWeight},',
  );

  buffer.writeln(
    '    isTimed: ${entry.isTimed},',
  );

  buffer.writeln(
    '    movementPattern: ${entry.movementPattern},',
  );

  buffer.writeln(
    '    mechanics: ${entry.mechanics},',
  );

  buffer.writeln(
    '    forceType: ${entry.forceType},',
  );

  buffer.writeln(
    '    laterality: ${entry.laterality},',
  );

  buffer.writeln(
    '    planeOfMotion: ${entry.planeOfMotion},',
  );

  buffer.writeln(
    '    description: ${_dartString(entry.description)},',
  );

  buffer.writeln('  ),');
}

/// Safely generates a single-quoted Dart string.
///
/// Escapes characters that could otherwise break the generated source:
/// - backslash
/// - single quote
/// - dollar sign interpolation
/// - common control characters
String _dartString(String value) {
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$')
      .replaceAll('\r', r'\r')
      .replaceAll('\n', r'\n')
      .replaceAll('\t', r'\t');

  return "'$escaped'";
}

void _removeObsoleteFiles(Directory outputDir) {
  final obsoleteFiles = <String>[
    'other_exercises.dart',
  ];

  for (final fileName in obsoleteFiles) {
    final file = File('${outputDir.path}/$fileName');

    if (file.existsSync()) {
      file.deleteSync();

      print(
        '🗑️ Removed $fileName',
      );
    }
  }
}

class _ExerciseSource {
  const _ExerciseSource({
    required this.splitName,
    required this.exercises,
  });

  final String splitName;
  final List<ExercisePoolEntry> exercises;
}

class _CanonicalExercise {
  _CanonicalExercise({
    required this.entry,
    required Set<String> compatibleSplits,
  }) : compatibleSplits = {...compatibleSplits};

  final ExercisePoolEntry entry;
  final Set<String> compatibleSplits;
}
