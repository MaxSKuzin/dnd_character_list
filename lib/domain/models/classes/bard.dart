import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

final class Bard extends Specialization {
  @override
  ClassKind get classKind => ClassKind.bard;

  @override
  final Map<StatKind, int> statBonuses;

  final List<StatKind> doubledSaveThrows;

  Bard._({
    required this.knownSpells,
    required super.level,
    required super.isMain,
    required this.inspirationDice,
    this.statBonuses = const {},
    this.doubledSaveThrows = const [],
  });

  @override
  String name = 'Бард';

  @override
  Dice hitDice = Dice.k8;

  @override
  int healthPerLevel = 5;

  @override
  int startHealth = 8;

  @override
  double magicLevelMultiplier = 1;

  Dice inspirationDice;

  @override
  late String classExtraDescription = '''
Своими словами или музыкой вы можете вдохновлять других. Для этого вы должны бонусным действием выбрать одно существо, отличное от вас, в пределах 60 футов, которое может вас слышать. Это существо получает кость бардовского вдохновения — ${inspirationDice.name}.

В течение следующих 10 минут это существо может один раз бросить эту кость и добавить результат к проверке характеристики, броску атаки или спасброску, который оно совершает. Существо может принять решение о броске кости вдохновения уже после броска к20, но должно сделать это прежде, чем Мастер объявит результат броска. Как только кость бардовского вдохновения брошена, она исчезает. Существо может иметь только одну такую кость одновременно.

Потраченные использования этого умения восстанавливаются после продолжительного отдыха.
''';

  @override
  StatKind spellKind = StatKind.charisma;

  @override
  final ClassExtras classExtra = ClassExtras.inspiration;

  @override
  int getClassExtrasCount(Player player) => player.charisma.bonus;

  @override
  late List<StatKind> chosenSaveThrows = [
    StatKind.dexterity,
    StatKind.charisma,
    ...doubledSaveThrows,
  ];

  @override
  final List<Spell> knownSpells;

  factory Bard.level1({
    required bool isMain,
    required List<Spell> knownSpells,
  }) =>
      Bard._(
        knownSpells: knownSpells,
        level: 1,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );

  factory Bard.level2({
    required bool isMain,
    required List<Spell> knownSpells,
  }) =>
      Bard._(
        knownSpells: knownSpells,
        level: 2,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );

  factory Bard.level3({
    required bool isMain,
    required List<StatKind> doubledSaveThrows,
    required List<Spell> knownSpells,
  }) =>
      Bard._(
        knownSpells: knownSpells,
        level: 3,
        isMain: isMain,
        inspirationDice: Dice.k6,
        doubledSaveThrows: doubledSaveThrows,
      );

  factory Bard.level4({
    required bool isMain,
    required Map<StatKind, int> statBonuses,
    required List<Spell> knownSpells,
  }) =>
      Bard._(
        knownSpells: knownSpells,
        level: 4,
        isMain: isMain,
        inspirationDice: Dice.k6,
        statBonuses: statBonuses,
      );

  factory Bard.level5({
    required bool isMain,
    required List<Spell> knownSpells,
  }) =>
      Bard._(
        knownSpells: knownSpells,
        level: 5,
        isMain: isMain,
        inspirationDice: Dice.k8,
      );
}
