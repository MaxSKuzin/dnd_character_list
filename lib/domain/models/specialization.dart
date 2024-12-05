import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

abstract class Specialization {
  final bool isMain;
  final int level;

  Specialization({
    required this.level,
    required this.isMain,
  });

  String get name;

  int get startHealth;

  int get healthPerLevel;

  int hitPoints(Player player) {
    return (isMain ? startHealth : 0) + player.constitution.bonus * level + healthPerLevel * (level - 1);
  }

  Specialization copyWith({
    int? level,
    bool? isMain,
  });

  Dice get hitDice;

  Specialization levelUp() => copyWith(
        level: level + 1,
      );

  List<StatKind> get chosenSaveThrows;

  @override
  bool operator ==(Object other) {
    if (other is Specialization) {
      return name == other.name && runtimeType == other.runtimeType && level == other.level && isMain == other.isMain;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([name, runtimeType, level, isMain]);
}
