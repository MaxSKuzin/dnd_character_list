import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

final class Barbarian extends Specialization {
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
  final ClassExtras classExtra = ClassExtras.rage;

  @override
  int getClassExtrasCount(Player player) => _rageInfoTable[level]!.count;

  @override
  String get classExtraDescription => '''
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
      return 10 + player.dexterity.bonus + player.constitution.bonus;
    }
    return super.getProtection(player);
  }

  @override
  double magicLevelMultiplier = 0;


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
