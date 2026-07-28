import 'package:gymgenius/domain/enums/equipment_type.dart';
import 'package:gymgenius/domain/enums/muscle_group.dart';
import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

class DescriptionBuilder {
  DescriptionBuilder._();

  static String build({
    required ExercisePoolEntry entry,
  }) {
    return '''
Target muscles: ${entry.targetMuscles.map((e) => e.displayName).join(', ')}

How to perform:
${entry.description}

Execution Tips:
• Maintain a neutral spine throughout the movement.
• Perform the exercise through a full range of motion.
• Control both the lifting and lowering phases.
• Exhale during the concentric phase and inhale during the eccentric phase.
• Stop immediately if you feel sharp pain.

Equipment:
${entry.equipmentType.displayName}
''';
  }
}
