enum Mechanics {
  openChain,
  closedChain,
}

extension MechanicsExtension on Mechanics {
  String get displayName {
    switch (this) {
      case Mechanics.openChain:
        return 'Open Chain';
      case Mechanics.closedChain:
        return 'Closed Chain';
    }
  }

  String get value {
    switch (this) {
      case Mechanics.openChain:
        return 'open_chain';
      case Mechanics.closedChain:
        return 'closed_chain';
    }
  }

  static Mechanics fromValue(String value) {
    return Mechanics.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Mechanics.openChain,
    );
  }
}
