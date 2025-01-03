import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class DetectEvilAndGood extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

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
  String name = 'Обнаружение добра и зла';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Пока заклинание активно, вы знаете, есть ли в пределах 30 футов от вас Аберрации, Исчадия, Небожители, Нежить, Феи или Элементали, а также их местоположение. Кроме того, вы знаете, есть ли в пределах 30 футов от вас место или предмет, который был магически освящён или осквернён.

Заклинание проницает большую часть барьеров, но блокируется 1 футом камня, 1 дюймом обычного металла, тонким листом свинца или 3 футами дерева или земли.''';
}
