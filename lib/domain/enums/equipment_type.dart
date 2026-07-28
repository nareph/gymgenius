// lib/domain/enums/equipment_type.dart

enum EquipmentType {
  bodyweight,
  resistanceBands,
  jumpRope,
  stairsOrStep,
  chairOrSimpleBench,
  dumbbells,
  kettlebell,
  homemadeWeights,
  barbellAndPlates,
  pullUpBarAccessible,
  dipStationOrParallelBars,
  adjustableBench,
  gymMachinesSelectorized,
  cableMachinePulley,
  smithMachine,
  legPressMachine,
  hackSquatMachine,
  legExtensionMachine,
  legCurlMachine,
  cardioTreadmill,
  cardioStationaryBike,
  cardioElliptical,
  cardioRowingMachine,
  openSpaceForRunningSprints,
  fitnessMat,
  foamRollerMassageBall,
  abWheel,
}

extension EquipmentTypeExtension on EquipmentType {
  String get displayName {
    switch (this) {
      case EquipmentType.bodyweight:
        return 'Bodyweight';
      case EquipmentType.resistanceBands:
        return 'Resistance Bands';
      case EquipmentType.jumpRope:
        return 'Jump Rope';
      case EquipmentType.stairsOrStep:
        return 'Stairs or Step';
      case EquipmentType.chairOrSimpleBench:
        return 'Chair or Simple Bench';
      case EquipmentType.dumbbells:
        return 'Dumbbells';
      case EquipmentType.kettlebell:
        return 'Kettlebell';
      case EquipmentType.homemadeWeights:
        return 'Homemade Weights';
      case EquipmentType.barbellAndPlates:
        return 'Barbell and Plates';
      case EquipmentType.pullUpBarAccessible:
        return 'Pull-up Bar';
      case EquipmentType.dipStationOrParallelBars:
        return 'Dip Bars';
      case EquipmentType.adjustableBench:
        return 'Adjustable Bench';
      case EquipmentType.gymMachinesSelectorized:
        return 'Selectorized Machines';
      case EquipmentType.cableMachinePulley:
        return 'Cable Machine';
      case EquipmentType.smithMachine:
        return 'Smith Machine';
      case EquipmentType.legPressMachine:
        return 'Leg Press';
      case EquipmentType.hackSquatMachine:
        return 'Hack Squat';
      case EquipmentType.legExtensionMachine:
        return 'Leg Extension';
      case EquipmentType.legCurlMachine:
        return 'Leg Curl';
      case EquipmentType.cardioTreadmill:
        return 'Treadmill';
      case EquipmentType.cardioStationaryBike:
        return 'Stationary Bike';
      case EquipmentType.cardioElliptical:
        return 'Elliptical';
      case EquipmentType.cardioRowingMachine:
        return 'Rowing Machine';
      case EquipmentType.openSpaceForRunningSprints:
        return 'Open Space';
      case EquipmentType.fitnessMat:
        return 'Fitness Mat';
      case EquipmentType.foamRollerMassageBall:
        return 'Foam Roller';
      case EquipmentType.abWheel:
        return 'Ab Wheel';
    }
  }

  /// Returns the string value (same as enum name) for storage/API.
  String get value => name;

  static EquipmentType fromValue(String value) {
    return EquipmentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EquipmentType.bodyweight,
    );
  }
}
