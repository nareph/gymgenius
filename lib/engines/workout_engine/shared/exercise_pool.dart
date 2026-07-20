import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

/// Central repository of exercises with detailed descriptions and muscle targets.
/// Used by the local generator to create personalized workouts.
class ExercisePool {
  ExercisePool._();

  static List<Map<String, dynamic>> getExercises({
    required String splitName,
    required List<EquipmentType> allowedEquipment,
    List<String>? focusMuscles,
  }) {
    final pool = _exercisePools[splitName] ?? _exercisePools['Push']!;

    var filtered = pool
        .where((entry) => allowedEquipment.contains(entry.equipmentType))
        .toList();

    // Sort by relevance to focus muscles
    if (focusMuscles != null && focusMuscles.isNotEmpty) {
      filtered.sort((a, b) {
        final scoreA =
            a.targetMuscles.where((m) => focusMuscles.contains(m)).length;
        final scoreB =
            b.targetMuscles.where((m) => focusMuscles.contains(m)).length;
        return scoreB.compareTo(scoreA);
      });
    }

    return filtered.map((e) => e.toMap()).toList();
  }

  static final Map<String, List<ExercisePoolEntry>> _exercisePools = {
    // ========================================
    // PUSH SPLIT
    // ========================================
    'Push': [
      const ExercisePoolEntry(
        name: 'Push-ups',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['chest', 'shoulders', 'triceps'],
        usesWeight: false,
        description: '**Target: Chest, Shoulders, Triceps**\n\n'
            '1. Start in a high plank position with hands slightly wider than shoulders.\n'
            '2. Lower your body until your chest nearly touches the floor.\n'
            '3. Press back up to the starting position, fully extending arms.\n'
            '4. Repeat for desired reps.',
      ),
      const ExercisePoolEntry(
        name: 'Dumbbell Bench Press',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['chest', 'shoulders', 'triceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Chest, Shoulders, Triceps**\n\n'
            '1. Lie on a bench with dumbbells in each hand, palms facing forward.\n'
            '2. Press the dumbbells up until arms are fully extended.\n'
            '3. Lower them slowly to the sides of your chest.\n'
            '4. Press back up explosively.',
      ),
      const ExercisePoolEntry(
        name: 'Barbell Bench Press',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.barbell,
        targetMuscles: ['chest', 'shoulders', 'triceps'],
        usesWeight: true,
        weightSuggestion: 'Heavy',
        description: '**Target: Chest, Shoulders, Triceps**\n\n'
            '1. Lie on a flat bench, grip the barbell slightly wider than shoulder-width.\n'
            '2. Unrack the bar and lower it to your mid-chest.\n'
            '3. Press the bar back up to full extension.',
      ),
      const ExercisePoolEntry(
        name: 'Incline Dumbbell Press',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['chest', 'shoulders'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Upper Chest, Shoulders**\n\n'
            '1. Set an incline bench to about 30-45 degrees.\n'
            '2. Press dumbbells from shoulder height upward.\n'
            '3. Lower with control.',
      ),
      const ExercisePoolEntry(
        name: 'Shoulder Press',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['shoulders', 'triceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Shoulders, Triceps**\n\n'
            '1. Sit on a bench with back support, dumbbells at shoulder height.\n'
            '2. Press the weights overhead until arms are extended.\n'
            '3. Lower them back to shoulder height with control.',
      ),
      const ExercisePoolEntry(
        name: 'Lateral Raises',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['shoulders'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Side Shoulders**\n\n'
            '1. Stand with dumbbells at your sides, palms facing in.\n'
            '2. Raise the dumbbells laterally to shoulder height.\n'
            '3. Lower them slowly back to start.',
      ),
      const ExercisePoolEntry(
        name: 'Tricep Pushdowns',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.cable,
        targetMuscles: ['triceps'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Triceps**\n\n'
            '1. Attach a rope or bar to a high pulley.\n'
            '2. Grip the handle and pull down until arms are straight.\n'
            '3. Squeeze triceps at the bottom, then return slowly.',
      ),
      const ExercisePoolEntry(
        name: 'Dips',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['chest', 'triceps', 'shoulders'],
        usesWeight: false,
        description: '**Target: Chest, Triceps, Shoulders**\n\n'
            '1. Hoist yourself up on parallel bars or a dip station.\n'
            '2. Lower your body by bending your elbows until shoulders are below elbows.\n'
            '3. Push back up to start.',
      ),
    ],

    // ========================================
    // PULL SPLIT
    // ========================================
    'Pull': [
      const ExercisePoolEntry(
        name: 'Pull-ups',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.pullUpBar,
        targetMuscles: ['back', 'biceps'],
        usesWeight: false,
        description: '**Target: Back, Biceps**\n\n'
            '1. Hang from a pull-up bar with hands slightly wider than shoulders.\n'
            '2. Pull your body up until your chin is above the bar.\n'
            '3. Lower yourself with control to full extension.',
      ),
      const ExercisePoolEntry(
        name: 'Chin-ups',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.pullUpBar,
        targetMuscles: ['back', 'biceps'],
        usesWeight: false,
        description: '**Target: Back, Biceps**\n\n'
            '1. Use an underhand grip (palms facing you).\n'
            '2. Pull up until chin clears the bar.\n'
            '3. Lower slowly.',
      ),
      const ExercisePoolEntry(
        name: 'Dumbbell Rows',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['back', 'biceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Back, Biceps**\n\n'
            '1. Place one knee and hand on a bench, other foot on floor.\n'
            '2. With a dumbbell in the free hand, pull it towards your hip.\n'
            '3. Squeeze your back at the top, then lower slowly.',
      ),
      const ExercisePoolEntry(
        name: 'Barbell Rows',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.barbell,
        targetMuscles: ['back', 'biceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Back, Biceps**\n\n'
            '1. Bend at hips, keeping back straight, grip barbell with overhand grip.\n'
            '2. Pull the bar towards your lower chest.\n'
            '3. Squeeze shoulder blades together, then lower.',
      ),
      const ExercisePoolEntry(
        name: 'Lat Pulldowns',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.cable,
        targetMuscles: ['back', 'biceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Back, Biceps**\n\n'
            '1. Sit at a lat pulldown machine, grip the bar wide.\n'
            '2. Pull the bar down to your upper chest.\n'
            '3. Control the return.',
      ),
      const ExercisePoolEntry(
        name: 'Bicep Curls',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['biceps'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Biceps**\n\n'
            '1. Stand with dumbbells at your sides, palms facing forward.\n'
            '2. Curl the weights up to shoulder height, squeezing biceps.\n'
            '3. Lower them back down with control.',
      ),
      const ExercisePoolEntry(
        name: 'Hammer Curls',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['biceps'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Biceps (brachialis)**\n\n'
            '1. Hold dumbbells with a neutral grip (palms facing each other).\n'
            '2. Curl up without rotating your wrists.',
      ),
      const ExercisePoolEntry(
        name: 'Face Pulls',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.cable,
        targetMuscles: ['shoulders', 'back'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Rear Delts, Upper Back**\n\n'
            '1. Attach a rope to a high pulley.\n'
            '2. Pull the rope towards your face, elbows high.\n'
            '3. Squeeze rear delts and release slowly.',
      ),
    ],

    // ========================================
    // LEGS SPLIT
    // ========================================
    'Legs': [
      const ExercisePoolEntry(
        name: 'Bodyweight Squats',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['quadriceps', 'glutes', 'hamstrings'],
        usesWeight: false,
        description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
            '1. Stand with feet shoulder-width apart.\n'
            '2. Lower your hips back and down as if sitting in a chair.\n'
            '3. Go as low as you can while keeping chest up.\n'
            '4. Push through heels to return to standing.',
      ),
      const ExercisePoolEntry(
        name: 'Goblet Squats',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['quadriceps', 'glutes', 'hamstrings'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
            '1. Hold a dumbbell vertically against your chest, hands under the top plate.\n'
            '2. Perform a squat as described above, keeping the weight close.',
      ),
      const ExercisePoolEntry(
        name: 'Barbell Squats',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.barbell,
        targetMuscles: ['quadriceps', 'glutes', 'hamstrings'],
        usesWeight: true,
        weightSuggestion: 'Heavy',
        description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
            '1. Place a barbell on your upper back, feet shoulder-width apart.\n'
            '2. Squat down to parallel or below.\n'
            '3. Drive through heels to stand up.',
      ),
      const ExercisePoolEntry(
        name: 'Romanian Deadlifts',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['hamstrings', 'glutes'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Hamstrings, Glutes**\n\n'
            '1. Stand with feet hip-width apart, dumbbells in front of thighs.\n'
            '2. Hinge at hips, push butt back, lower dumbbells along your shins.\n'
            '3. Feel the stretch in hamstrings, then return to start.',
      ),
      const ExercisePoolEntry(
        name: 'Lunges',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['quadriceps', 'glutes', 'hamstrings'],
        usesWeight: false,
        description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
            '1. Step forward with one leg, lowering your hips until both knees are bent at 90°.\n'
            '2. Push back to start and repeat on the other leg.',
      ),
      const ExercisePoolEntry(
        name: 'Dumbbell Lunges',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['quadriceps', 'glutes', 'hamstrings'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
            '1. Hold dumbbells at your sides.\n'
            '2. Perform a lunge as described above.',
      ),
      const ExercisePoolEntry(
        name: 'Leg Press',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.machine,
        targetMuscles: ['quadriceps', 'glutes', 'hamstrings'],
        usesWeight: true,
        weightSuggestion: 'Heavy',
        description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
            '1. Sit on the leg press machine, feet on the platform shoulder-width apart.\n'
            '2. Lower the platform until your knees are at 90°.\n'
            '3. Press back up without locking your knees.',
      ),
      const ExercisePoolEntry(
        name: 'Leg Curls',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.machine,
        targetMuscles: ['hamstrings'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Hamstrings**\n\n'
            '1. Lie face down on the leg curl machine, ankles under the pads.\n'
            '2. Curl your heels towards your glutes.\n'
            '3. Lower with control.',
      ),
      const ExercisePoolEntry(
        name: 'Calf Raises',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['calves'],
        usesWeight: false,
        description: '**Target: Calves**\n\n'
            '1. Stand on the edge of a step or flat ground.\n'
            '2. Raise your heels as high as possible.\n'
            '3. Lower slowly below the step for a full stretch.',
      ),
    ],

    // ========================================
    // CHEST & TRICEPS
    // ========================================
    'Chest & Triceps': [
      const ExercisePoolEntry(
        name: 'Push-ups',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['chest', 'triceps', 'shoulders'],
        usesWeight: false,
        description: '**Target: Chest, Triceps, Shoulders**\n\n'
            '1. Start in plank position.\n'
            '2. Lower chest to floor.\n'
            '3. Push back up.',
      ),
      const ExercisePoolEntry(
        name: 'Dumbbell Bench Press',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['chest', 'triceps', 'shoulders'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Chest, Triceps, Shoulders**\n\n'
            '1. Lie on a bench with dumbbells.\n'
            '2. Press up from chest level.\n'
            '3. Lower slowly.',
      ),
      const ExercisePoolEntry(
        name: 'Incline Dumbbell Press',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['chest', 'shoulders'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Upper Chest, Shoulders**\n\n'
            '1. Incline bench at 30-45°.\n'
            '2. Press dumbbells from shoulder height.\n'
            '3. Lower with control.',
      ),
      const ExercisePoolEntry(
        name: 'Cable Flyes',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.cable,
        targetMuscles: ['chest'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Chest (Fly movement)**\n\n'
            '1. Set cables at chest height, grip handles.\n'
            '2. Bring hands together in front of your chest.\n'
            '3. Squeeze chest and return slowly.',
      ),
      const ExercisePoolEntry(
        name: 'Tricep Pushdowns',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.cable,
        targetMuscles: ['triceps'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Triceps**\n\n'
            '1. Attach rope to high pulley.\n'
            '2. Pull down to full extension.\n'
            '3. Squeeze triceps at bottom.',
      ),
      const ExercisePoolEntry(
        name: 'Dips',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['chest', 'triceps', 'shoulders'],
        usesWeight: false,
        description: '**Target: Chest, Triceps, Shoulders**\n\n'
            '1. Hoist on parallel bars.\n'
            '2. Lower body until elbows are at 90°.\n'
            '3. Push back up.',
      ),
    ],

    // ========================================
    // BACK & BICEPS
    // ========================================
    'Back & Biceps': [
      const ExercisePoolEntry(
        name: 'Pull-ups',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.pullUpBar,
        targetMuscles: ['back', 'biceps'],
        usesWeight: false,
        description: '**Target: Back, Biceps**\n\n'
            '1. Hang from bar.\n'
            '2. Pull up until chin over bar.\n'
            '3. Lower slowly.',
      ),
      const ExercisePoolEntry(
        name: 'Chin-ups',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.pullUpBar,
        targetMuscles: ['back', 'biceps'],
        usesWeight: false,
        description: '**Target: Back, Biceps**\n\n'
            '1. Underhand grip.\n'
            '2. Pull up to chin over bar.',
      ),
      const ExercisePoolEntry(
        name: 'Dumbbell Rows',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['back', 'biceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Back, Biceps**\n\n'
            '1. Support one knee and hand on bench.\n'
            '2. Row dumbbell towards hip.',
      ),
      const ExercisePoolEntry(
        name: 'Barbell Rows',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.barbell,
        targetMuscles: ['back', 'biceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Back, Biceps**\n\n'
            '1. Bent-over position, overhand grip.\n'
            '2. Pull bar to lower chest.',
      ),
      const ExercisePoolEntry(
        name: 'Lat Pulldowns',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.cable,
        targetMuscles: ['back', 'biceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Back, Biceps**\n\n'
            '1. Sit at machine, grip wide.\n'
            '2. Pull bar to upper chest.',
      ),
      const ExercisePoolEntry(
        name: 'Bicep Curls',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['biceps'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Biceps**\n\n'
            '1. Stand with dumbbells.\n'
            '2. Curl up to shoulder height.',
      ),
      const ExercisePoolEntry(
        name: 'Hammer Curls',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['biceps'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Biceps (brachialis)**\n\n'
            '1. Neutral grip.\n'
            '2. Curl without rotation.',
      ),
    ],

    // ========================================
    // SHOULDERS & CORE
    // ========================================
    'Shoulders & Core': [
      const ExercisePoolEntry(
        name: 'Shoulder Press',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['shoulders', 'triceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Shoulders, Triceps**\n\n'
            '1. Sit with dumbbells at shoulders.\n'
            '2. Press overhead.',
      ),
      const ExercisePoolEntry(
        name: 'Lateral Raises',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['shoulders'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Side Shoulders**\n\n'
            '1. Raise dumbbells to sides to shoulder height.',
      ),
      const ExercisePoolEntry(
        name: 'Front Raises',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['shoulders'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Front Shoulders**\n\n'
            '1. Raise dumbbells in front to shoulder height.',
      ),
      const ExercisePoolEntry(
        name: 'Plank',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['core'],
        usesWeight: false,
        isTimed: true,
        description: '**Target: Core**\n\n'
            '1. Forearm plank position.\n'
            '2. Hold body straight from head to heels.\n'
            '3. Engage core and hold for time.',
      ),
      const ExercisePoolEntry(
        name: 'Side Plank',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['core'],
        usesWeight: false,
        isTimed: true,
        description: '**Target: Obliques**\n\n'
            '1. Side support on forearm.\n'
            '2. Hold body straight.\n'
            '3. Repeat on other side.',
      ),
      const ExercisePoolEntry(
        name: 'Cable Woodchops',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.cable,
        targetMuscles: ['core', 'shoulders'],
        usesWeight: true,
        weightSuggestion: 'Light',
        description: '**Target: Core, Shoulders**\n\n'
            '1. Set cable at high or low position.\n'
            '2. Chop diagonally across body.',
      ),
    ],

    // ========================================
    // UPPER BODY
    // ========================================
    'Upper Body': [
      const ExercisePoolEntry(
        name: 'Push-ups',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['chest', 'shoulders', 'triceps'],
        usesWeight: false,
        description: '**Target: Chest, Shoulders, Triceps**\n\n'
            '1. Plank position.\n'
            '2. Lower and push up.',
      ),
      const ExercisePoolEntry(
        name: 'Pull-ups',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.pullUpBar,
        targetMuscles: ['back', 'biceps'],
        usesWeight: false,
        description: '**Target: Back, Biceps**\n\n'
            '1. Hang from bar.\n'
            '2. Pull up.',
      ),
      const ExercisePoolEntry(
        name: 'Dips',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['chest', 'triceps', 'shoulders'],
        usesWeight: false,
        description: '**Target: Chest, Triceps, Shoulders**\n\n'
            '1. Parallel bars.\n'
            '2. Lower and push up.',
      ),
      const ExercisePoolEntry(
        name: 'Dumbbell Bench Press',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['chest', 'shoulders', 'triceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Chest, Shoulders, Triceps**\n\n'
            '1. Lie on bench.\n'
            '2. Press dumbbells.',
      ),
      const ExercisePoolEntry(
        name: 'Dumbbell Rows',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['back', 'biceps'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Back, Biceps**\n\n'
            '1. One-arm row on bench.',
      ),
    ],

    // ========================================
    // LOWER BODY
    // ========================================
    'Lower Body': [
      const ExercisePoolEntry(
        name: 'Bodyweight Squats',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['quadriceps', 'glutes', 'hamstrings'],
        usesWeight: false,
        description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
            '1. Stand feet apart.\n'
            '2. Squat down.\n'
            '3. Stand up.',
      ),
      const ExercisePoolEntry(
        name: 'Lunges',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['quadriceps', 'glutes', 'hamstrings'],
        usesWeight: false,
        description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
            '1. Step forward.\n'
            '2. Lower hips.\n'
            '3. Push back.',
      ),
      const ExercisePoolEntry(
        name: 'Glute Bridges',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['glutes'],
        usesWeight: false,
        description: '**Target: Glutes**\n\n'
            '1. Lie on back, knees bent.\n'
            '2. Lift hips off floor.\n'
            '3. Squeeze glutes at top.',
      ),
      const ExercisePoolEntry(
        name: 'Calf Raises',
        category: ExerciseCategory.isolation,
        equipmentType: EquipmentType.bodyweight,
        targetMuscles: ['calves'],
        usesWeight: false,
        description: '**Target: Calves**\n\n'
            '1. Stand on edge of step.\n'
            '2. Raise heels.\n'
            '3. Lower below step.',
      ),
      const ExercisePoolEntry(
        name: 'Goblet Squats',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['quadriceps', 'glutes', 'hamstrings'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Quadriceps, Glutes, Hamstrings**\n\n'
            '1. Hold dumbbell at chest.\n'
            '2. Squat down.',
      ),
      const ExercisePoolEntry(
        name: 'Romanian Deadlifts',
        category: ExerciseCategory.compound,
        equipmentType: EquipmentType.dumbbell,
        targetMuscles: ['hamstrings', 'glutes'],
        usesWeight: true,
        weightSuggestion: 'Moderate',
        description: '**Target: Hamstrings, Glutes**\n\n'
            '1. Hinge at hips.\n'
            '2. Lower dumbbells along shins.',
      ),
    ],
  };
}
