import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class DetectPoisonAndDisease extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.driud,
    ClassKind.cliric,
    ClassKind.paladin,
    ClassKind.ranger,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('лист тиса'),
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
  String name = 'Обнаружение болезней и яда';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Пока заклинание активно, вы можете ощущать присутствие и местонахождение ядов, ядовитых существ и болезней в пределах 30 футов от себя. Вы также распознаёте вид яда, ядовитого существа или болезни.

Заклинание проницает большую часть барьеров, но блокируется 1 футом камня, 1 дюймом обычного металла, тонким листом свинца или 3 футами дерева или земли.''';
}
