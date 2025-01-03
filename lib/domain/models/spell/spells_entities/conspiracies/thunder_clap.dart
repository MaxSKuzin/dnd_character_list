import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ThunderClap extends Spell {
  @override
  String name = 'Раскат грома';

  @override
  int distance = 5;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.s(),
  ];

  @override
  Duration duration = Duration.zero;

  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  bool isConcentration = false;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.sorcerer,
    ClassKind.inventor,
    ClassKind.driud,
    ClassKind.witch,
  ];

  @override
  int? get durationInRounds => null;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) {
    final diceCount = spec.level >= 5
        ? 2
        : spec.level >= 11
            ? 3
            : spec.level >= 17
                ? 4
                : 1;

    final dice = Dice.k6;
    return '''Вы вызываете оглушительный раскат грома, который слышен на расстоянии до 100 футов. Все существа кроме вас в пределах дистанции должны совершить спасбросок Телосложения. При провале существо получает $diceCount${dice.name} урона звуком.''';
  }

  @override
  String get rawDescription =>
      '''Вы вызываете оглушительный раскат грома, который слышен на расстоянии до 100 футов. Все существа кроме вас в пределах дистанции должны совершить спасбросок Телосложения. При провале существо получает 1к6 урона звуком.

Урон заклинания увеличивается на 1к6, когда вы достигаете 5-го уровня (2к6), 11-го уровня (3к6) и 17-го уровня (4к6).''';
}
