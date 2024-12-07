import 'dart:math';

import 'package:dnd_character_list/domain/models/class_extras.dart';
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

  int getProtection(Player player) {
    if (player.armor == null) {
      return 10 + player.dexterity.bonus;
    }

    var protection = player.armor!.protection;
    final limit = player.armor!.dexterityLimit;
    if (limit != null) {
      protection += min(player.dexterity.bonus, limit);
    } else {
      protection += player.dexterity.bonus;
    }

    return protection;
  }

  int additionalDamage(Player player) => 0;

  int hitPoints(Player player) {
    return (isMain ? startHealth : 0) + player.constitution.bonus * level + healthPerLevel * (level - 1);
  }

  Specialization copyWith({
    int? level,
    bool? isMain,
  });

  Dice get hitDice;

  List<StatKind> get chosenSaveThrows;

  double get magicLevelMultiplier;

  StatKind? get spellKind => null;

  ClassExtras? get classExtra => null;

  String get classExtraDescription => '';

  int getClassExtrasCount(Player player) => 0;

  Map<StatKind, int> get statBonuses;

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
