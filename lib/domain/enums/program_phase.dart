enum ProgramPhase {
  base,
  intensification,
  realization,
}

extension ProgramPhaseExtension on ProgramPhase {
  String get displayName {
    switch (this) {
      case ProgramPhase.base:
        return 'Base Phase';
      case ProgramPhase.intensification:
        return 'Intensification';
      case ProgramPhase.realization:
        return 'Realization / Peak';
    }
  }

  String get value {
    switch (this) {
      case ProgramPhase.base:
        return 'base';
      case ProgramPhase.intensification:
        return 'intensification';
      case ProgramPhase.realization:
        return 'realization';
    }
  }

  static ProgramPhase fromValue(String value) {
    return ProgramPhase.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProgramPhase.base,
    );
  }
}
