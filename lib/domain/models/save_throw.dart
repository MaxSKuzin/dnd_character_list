import 'package:dnd_character_list/domain/models/stat_kind.dart';

class SaveThrow {
  final StatKind origin;
  final bool isChosen;
  final int bonus;

  SaveThrow({
    required this.origin,
    required this.isChosen,
    required this.bonus,
  });

  @override
  bool operator ==(Object other) =>
      other is SaveThrow && origin == other.origin && isChosen == other.isChosen && bonus == other.bonus;

  @override
  int get hashCode => Object.hashAll([origin, isChosen, bonus]);
}
