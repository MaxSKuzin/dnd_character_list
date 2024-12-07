import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

final class Bard extends Specialization {
  Bard._({
    required super.level,
    required super.isMain,
    required this.inspirationDice,
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
  String get classExtraDescription => '''
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
  List<StatKind> get chosenSaveThrows => [
        StatKind.dexterity,
        StatKind.charisma,
      ];

  @override
  Specialization copyWith({int? level, bool? isMain}) => Bard._(
        level: level ?? this.level,
        isMain: isMain ?? this.isMain,
        inspirationDice: inspirationDice,
      );

  factory Bard.level1({required bool isMain}) => Bard._(
        level: 1,
        isMain: isMain,
        inspirationDice: Dice.k6,
      );
}
