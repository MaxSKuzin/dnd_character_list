import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class SeeInvisibility extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.inventor,
    ClassKind.sorcerer,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('щепотка талька и толченого серебра'),
  ];

  @override
  int distance = 0;

  @override
  Duration? duration = const Duration(minutes: 60);

  @override
  int? durationInRounds;

  @override
  bool isConcentration = false;

  @override
  String name = 'Видение невидимого';

  @override
  SpellSlot slot = SpellSlot.level2;

  @override
  String description(Player player, Specialization spec) => rawDescription;

  @override
  String get rawDescription =>
      '''Пока заклинание активно, вы видите невидимых существ и предметы, как если бы они были видимы, и ваше зрение простирается на Эфирный план. Эфирные существа и предметы выглядят призрачными и полупрозрачными.''';
}
