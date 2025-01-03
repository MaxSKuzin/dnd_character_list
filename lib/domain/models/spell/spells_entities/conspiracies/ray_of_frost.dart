import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class RayOfFrost extends Spell {
  @override
  String name = 'Луч холода';

  @override
  int distance = 60;

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
    ClassKind.inventor,
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

    final dice = Dice.k8;
    return '''Холодный сине-белый луч устремляется к существу, находящемуся в пределах дистанции. Совершите по цели дальнобойную атаку заклинанием. При попадании она получает урон холодом $diceCount${dice.name}, а скорость до начала вашего следующего хода уменьшается на 10 футов.''';
  }

  @override
  String get rawDescription =>
      '''Холодный сине-белый луч устремляется к существу, находящемуся в пределах дистанции. Совершите по цели дальнобойную атаку заклинанием. При попадании она получает урон холодом 1к8, а скорость до начала вашего следующего хода уменьшается на 10 футов.

Урон от заклинания увеличивается на 1к8, когда вы достигаете 5-го уровня (2к8), 11-го уровня (3к8) и 17-го уровня (4к8).''';
}
