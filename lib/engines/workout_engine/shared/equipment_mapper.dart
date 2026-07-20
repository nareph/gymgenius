import 'package:gymgenius/engines/workout_engine/shared/exercise_pool_entry.dart';

class EquipmentMapper {
  static EquipmentType fromString(String equipment) {
    final normalized = equipment.toLowerCase().trim();
    if (normalized.contains('bodyweight') || normalized == 'bw') {
      return EquipmentType.bodyweight;
    } else if (normalized.contains('barbell')) {
      return EquipmentType.barbell;
    } else if (normalized.contains('dumbbell')) {
      return EquipmentType.dumbbell;
    } else if (normalized.contains('kettlebell')) {
      return EquipmentType.kettlebell;
    } else if (normalized.contains('resistance')) {
      return EquipmentType.resistanceBand;
    } else if (normalized.contains('cable')) {
      return EquipmentType.cable;
    } else if (normalized.contains('machine')) {
      return EquipmentType.machine;
    } else if (normalized.contains('pull')) {
      return EquipmentType.pullUpBar;
    } else if (normalized.contains('bench')) {
      return EquipmentType.bench;
    } else {
      // Default to bodyweight if unknown (safe fallback)
      return EquipmentType.bodyweight;
    }
  }

  static List<EquipmentType> fromList(List<String> equipmentList) {
    return equipmentList.map(fromString).toSet().toList();
  }
}
