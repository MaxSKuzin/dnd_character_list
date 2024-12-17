import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class EldritchBlast extends Spell {
  @override
  String name = 'Мистический заряд';

  @override
  int distance = 120;

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
    ClassKind.witch,
  ];

  @override
  int? durationInRounds;

  @override
  String description(Player player, Specialization spec) {
    final raysCount = spec.level >= 5
        ? 2
        : spec.level >= 11
            ? 3
            : spec.level >= 17
                ? 4
                : 1;

    final dice = Dice.k10;
    return '''К существу, находящемуся в пределах дистанции, устремляется луч потрескивающей энергии. Совершите дальнобойную атаку заклинанием по цели. При попадании цель получает урон силовым полем 1${dice.name}.

Вы можете направить лучи(x$raysCount) в одну цель или в разные. Для каждого луча совершите свой бросок атаки.''';
  }

  @override
  String get rawDescription =>
      '''К существу, находящемуся в пределах дистанции, устремляется луч потрескивающей энергии. Совершите дальнобойную атаку заклинанием по цели. При попадании цель получает урон силовым полем 1к10.

Заклинание создаёт ещё один луч, когда вы достигаете больших уровней: два луча на 5-м уровне, три луча на 11-м уровне и четыре луча на 17-м уровне.

Вы можете направить лучи в одну цель или в разные. Для каждого луча совершите свой бросок атаки.''';
}
