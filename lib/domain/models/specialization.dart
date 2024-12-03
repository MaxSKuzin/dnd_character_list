import 'dart:math';

import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';

abstract class Specialization {
  final bool isMain;
  int _level;

  Specialization({
    required int level,
    required this.isMain,
  }) : _level = level;

  String get name;

  int get startHealth;

  int get healthPerLevel;

  int hitPoints(Player player) {
    return (isMain ? startHealth : 0) + player.constitution.bonus * _level + healthPerLevel * (_level - 1);
  }

  int get hitsToRestore {
    int value = 0;
    for (int i = 0; i < _level; i++) {
      value += max(hitDice.roll() ~/ 2, 1);
    }
    return value;
  }

  Dice get hitDice;

  int get level => _level;

  void levelUp() => _level++;
}
