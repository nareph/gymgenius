import 'package:gymgenius/domain/entities/health_profile.dart';
import 'package:gymgenius/domain/entities/training_program.dart';

/// Interface for program optimizers.
///
/// An optimizer takes a valid TrainingProgram and improves it without
/// changing its core structure (split, volume, frequency).
abstract class ProgramOptimizer {
  /// Optimizes the given program.
  ///
  /// Returns the optimized program. If optimization fails or is not available,
  /// the original program should be returned.
  Future<TrainingProgram> optimize({
    required TrainingProgram program,
    required HealthProfile profile,
    Map<String, dynamic>? options,
  });

  /// Returns true if this optimizer is available (e.g., API key configured).
  bool get isAvailable;
}
