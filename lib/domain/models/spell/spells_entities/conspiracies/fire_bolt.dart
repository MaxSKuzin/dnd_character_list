import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class FireBolt extends Spell {
  @override
  String name = 'Огненный снаряд';

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

    final dice = Dice.k10;
    return '''Вы кидаете сгусток огня в существо или предмет в пределах дистанции. Совершите по цели дальнобойную атаку заклинанием. При попадании цель получает урон огнём $diceCount${dice.name}. Горючие предметы, по которым попало это заклинание, воспламеняются, если их никто не несет и не носит.''';
  }

  @override
  String get rawDescription =>
      '''Вы кидаете сгусток огня в существо или предмет в пределах дистанции. Совершите по цели дальнобойную атаку заклинанием. При попадании цель получает урон огнём 1к10. Горючие предметы, по которым попало это заклинание, воспламеняются, если их никто не несет и не носит.

Урон этого заклинания увеличивается на 1к10, когда вы достигаете 5-го уровня (2к10), 11-го уровня (3к10), 17-го уровня (4к10).''';
}
