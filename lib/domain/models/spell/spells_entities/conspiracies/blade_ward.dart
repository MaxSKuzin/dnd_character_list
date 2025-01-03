import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class BladeWard extends Spell {
  @override
  String name = 'Защита от оружия';

  @override
  int distance = 0;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
  ];

  @override
  Duration? duration;

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
    ClassKind.witch,
    ClassKind.sorcerer,
  ];

  @override
  int? get durationInRounds => 1;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Вы протягиваете руку и рисуете в воздухе ограждающий знак. Вы получаете до конца своего следующего хода сопротивление дробящему, колющему и рубящему урону, причиненному атаками оружием.''';
}
