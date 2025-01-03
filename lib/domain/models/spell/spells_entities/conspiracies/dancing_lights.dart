import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class DancingLights extends Spell {
  @override
  String name = 'Пляшущие огоньки';

  @override
  int distance = 120;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.s(),
    SpellComponent.v(),
    SpellComponent.m('кусочек фосфора, гнилушка или светлячок'),
  ];

  @override
  Duration duration = const Duration(minutes: 1);

  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  bool isConcentration = true;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.witch,
    ClassKind.sorcerer,
  ];

  @override
  int? get durationInRounds => null;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Вы создаете до четырёх огоньков размером с факел в пределах дистанции, делая их похожими на факелы, фонари или светящиеся сферы, парящие в воздухе. Вы можете также объединить четыре огонька в одну светящуюся человекоподобную фигуру Среднего размера. Какую бы форму вы ни выбрали, каждый огонёк излучает тусклый свет в радиусе 10 футов.

Вы можете бонусным действием в свой ход переместить огоньки на 60 футов в новое место в пределах дистанции. Каждый огонёк должен находиться в пределах 20 футов от другого огонька, созданного этим заклинанием, и огонёк тухнет, если оказывается за пределами дистанции заклинания.''';
}
