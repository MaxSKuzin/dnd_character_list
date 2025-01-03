import 'dart:math';

import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

final class Barbarian extends Specialization {
  @override
  ClassKind get classKind => ClassKind.barbarian;

  @override
  final Map<StatKind, int> statBonuses;

  Barbarian({
    required super.level,
    required super.isMain,
    this.statBonuses = const {},
  });

  @override
  String name = 'Варвар';

  @override
  Dice hitDice = Dice.k12;

  @override
  int healthPerLevel = 7;

  @override
  int startHealth = 12;

  @override
  final List<ClassExtras> classExtras = [
    ClassExtras.rage,
  ];

  @override
  int getClassExtrasCount(Player player, ClassExtras extra) => _rageInfoTable[level]!.count;

  @override
  String classExtraDescription(ClassExtras extra) => '''
В состоянии ярости вы получаете следующие преимущества, если не носите тяжёлый доспех:

  · Вы совершаете с преимуществом проверки и спасброски Силы.
  · Если вы совершаете рукопашную атаку оружием, используя Силу, вы получаете бонус к броску урона +${_rageInfoTable[level]!.damage}.
  · Вы получаете сопротивление дробящему, колющему и рубящему урону.
  · Если вы способны накладывать заклинания, то вы не можете накладывать или концентрироваться на заклинаниях, пока находитесь в состоянии ярости.

Ваша ярость длится 1 минуту. Она прекращается раньше, если вы потеряли сознание или если вы закончили свой ход, не получив урон или не атаковав враждебное по отношению к вам существо с момента окончания вашего прошлого хода. Также вы можете прекратить свою ярость бонусным действием.
''';

  @override
  List<StatKind> get chosenSaveThrows => [
        StatKind.strength,
        StatKind.constitution,
      ];

  @override
  int getProtection(Player player) {
    if (player.armor == null) {
      final dexterityBonus = max(0, player.dexterity.bonus);
      final constitutionBonus = max(0, player.constitution.bonus);
      return 10 + dexterityBonus + constitutionBonus;
    }
    return super.getProtection(player);
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'knownSpells': knownSpells.map((e) => e.toJson()).toList(),
        'level': level,
        'isMain': isMain,
        'statBonuses': statBonuses.map((key, value) => MapEntry(key.toJson(), value)),
      };

  static Barbarian fromJson(Map<String, dynamic> json) => Barbarian(
        level: json['level'],
        isMain: json['isMain'],
        statBonuses: (json['statBonuses'] as Map).map((key, value) => MapEntry(StatKind.fromJson(key), value)),
      );

  static const _rageInfoTable = {
    1: (count: 2, damage: 2),
    2: (count: 2, damage: 2),
    3: (count: 3, damage: 2),
    4: (count: 3, damage: 2),
    5: (count: 3, damage: 2),
    6: (count: 4, damage: 2),
    7: (count: 4, damage: 2),
    8: (count: 4, damage: 2),
    9: (count: 4, damage: 2),
    10: (count: 4, damage: 2),
    11: (count: 4, damage: 2),
    12: (count: 5, damage: 2),
    13: (count: 5, damage: 2),
    14: (count: 5, damage: 2),
    15: (count: 5, damage: 2),
    16: (count: 5, damage: 2),
    17: (count: 6, damage: 2),
    18: (count: 6, damage: 2),
    19: (count: 6, damage: 2),
    20: (count: 6, damage: 2),
  };
}
