import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class DetectMagic extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.driud,
    ClassKind.cliric,
    ClassKind.inventor,
    ClassKind.paladin,
    ClassKind.ranger,
    ClassKind.sorcerer,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
  ];

  @override
  int distance = 0;

  @override
  Duration duration = const Duration(minutes: 10);

  @override
  int? durationInRounds;

  @override
  bool isConcentration = true;

  @override
  String name = 'Обнаружение магии';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec) => rawDescription;

  @override
  String get rawDescription =>
      '''Пока заклинание активно, вы чувствуете присутствие магии в пределах 30 футов. Если вы почувствовали за счет этого заклинания присутствие магии, вы можете действием увидеть слабую ауру вокруг видимого существа или предмета, несущего на себе магию, а также узнать школу этой магии, если она есть.

Заклинание проницает большую часть барьеров, но блокируется 1 футом камня, 1 дюймом обычного металла, тонким листом свинца или 3 футами дерева или земли.''';
}
