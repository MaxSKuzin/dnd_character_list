import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class PoisonPray extends Spell {
  @override
  String name = 'Ядовитые брызги';

  @override
  int distance = 10;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
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
    ClassKind.wizard,
    ClassKind.driud,
    ClassKind.inventor,
    ClassKind.witch,
    ClassKind.sorcerer,
  ];

  @override
  int? durationInRounds;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) {
    final diceCount = spec.level >= 5
        ? 2
        : spec.level >= 11
            ? 3
            : spec.level >= 17
                ? 4
                : 1;

    final dice = Dice.k12;
    return '''Вы простираете руку к существу, видимому в пределах дистанции, и выпускаете из ладони клубы токсичного газа. Это существо должно преуспеть в спасброске Телосложения, иначе оно получит урон ядом $diceCount${dice.name}.''';
  }

  @override
  String get rawDescription =>
      '''Вы простираете руку к существу, видимому в пределах дистанции, и выпускаете из ладони клубы токсичного газа. Это существо должно преуспеть в спасброске Телосложения, иначе оно получит урон ядом 1к12.

Урон этого заклинания увеличивается на 1к12, когда вы достигаете 5-го уровня (2к12), 11-го уровня (3к12) и 17-го уровня (4к12).''';
}
