import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ShieldOfFaith extends Spell {
  @override
  SpellTime castTimeType = SpellTime.bonusAction;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.cliric,
    ClassKind.paladin,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('небольшой пергамент со святыми письменами'),
  ];

  @override
  int distance = 60;

  @override
  Duration duration = const Duration(minutes: 10);

  @override
  int? durationInRounds;

  @override
  bool isConcentration = true;

  @override
  String name = 'Щит веры';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Появляется мерцающее поле, окружающее существо, выбранное вами в пределах дистанции, даруя ему на время длительности бонус <b>+2</b> к КД.''';
}
