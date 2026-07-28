import 'package:gymgenius/domain/enums/exercise_category.dart';
import 'package:gymgenius/domain/value_objects/tempo.dart';

class TempoBuilder {
  TempoBuilder._();

  static Tempo build(
    ExerciseCategory category,
  ) {
    switch (category) {
      case ExerciseCategory.compound:
        return const Tempo(
          eccentric: 3,
          pause: 1,
          concentric: 1,
          pauseAfter: 0,
        );

      case ExerciseCategory.isolation:
        return const Tempo(
          eccentric: 2,
          pause: 1,
          concentric: 2,
          pauseAfter: 0,
        );

      // case ExerciseCategory.plyometric:
      //   return const Tempo(
      //     eccentric: 1,
      //     pause: 0,
      //     concentric: 1,
      //     pauseAfter: 1,
      //   );

      case ExerciseCategory.cardio:
        return const Tempo(
          eccentric: 1,
          pause: 0,
          concentric: 1,
          pauseAfter: 0,
        );

      case ExerciseCategory.mobility:
        return const Tempo(
          eccentric: 3,
          pause: 2,
          concentric: 3,
          pauseAfter: 1,
        );

      // case ExerciseCategory.stretching:
      //   return const Tempo(
      //     eccentric: 2,
      //     pause: 20,
      //     concentric: 2,
      //     pauseAfter: 0,
      //   );
    }
  }
}
