import 'package:dnd_character_list/domain/models/stat_kind.dart';

class Stat {
  final int value;
  final StatKind kind;

  Stat({
    required this.value,
    required this.kind,
  });

  int get bonus {
    final oddValue = value.isEven ? value : value - 1;
    return (oddValue - 10) ~/ 2;
  }
}
