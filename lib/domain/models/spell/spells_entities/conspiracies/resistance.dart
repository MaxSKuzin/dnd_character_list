import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Resistance extends Spell {
  @override
  String name = 'Сопротивление';

  @override
  int distance = 0;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('крошечный плащ'),
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
    ClassKind.driud,
    ClassKind.cliric,
    ClassKind.inventor,
  ];

  @override
  int? durationInRounds;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Вы касаетесь одного согласного существа. Пока заклинание активно, цель может один раз бросить к4 и добавить выпавшее число к одному спасброску на свой выбор. Кость можно кидать до или после спасброска. После этого заклинание оканчивается.''';
}
