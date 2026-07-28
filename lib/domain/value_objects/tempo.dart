// lib/domain/value_objects/tempo.dart

class Tempo {
  final int eccentric;
  final int pause;
  final int concentric;
  final int? pauseAfter;

  const Tempo({
    required this.eccentric,
    required this.pause,
    required this.concentric,
    this.pauseAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'eccentric': eccentric,
      'pause': pause,
      'concentric': concentric,
      if (pauseAfter != null) 'pauseAfter': pauseAfter,
    };
  }

  factory Tempo.fromMap(Map<String, dynamic> map) {
    return Tempo(
      eccentric: map['eccentric'] as int,
      pause: map['pause'] as int,
      concentric: map['concentric'] as int,
      pauseAfter: map['pauseAfter'] as int?,
    );
  }

  @override
  String toString() =>
      '$eccentric-$pause-$concentric${pauseAfter != null ? '-$pauseAfter' : ''}';
}
