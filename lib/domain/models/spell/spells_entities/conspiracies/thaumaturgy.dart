import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Thaumaturgy extends Spell {
  @override
  String name = 'Чудотворство';

  @override
  int distance = 30;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
  ];

  @override
  Duration duration = const Duration(minutes: 1);

  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  bool isConcentration = false;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.cliric,
  ];

  @override
  int? durationInRounds;

  @override
  String description(Player player, Specialization spec) => rawDescription;

  @override
  String get rawDescription =>
      '''Вы создаёте небольшое чудо, знак сверхъестественной силы. Вы создаёте один из следующих магических эффектов в пределах дистанции:

Ваш голос в течение 1 минуты звучит в три раза громче.
Вы заставляете пламя в течение 1 минуты мерцать, светить ярче или тусклее, или изменять цвет.
Вы вызываете безвредную дрожь в полу в течение 1 минуты.
Вы создаёте мгновенный звук, исходящий из выбранной вами точки в пределах дистанции, такой как раскат грома, крик ворона или зловещий шёпот.
Вы мгновенно заставляете незапертое окно или дверь распахнуться или захлопнуться.
Вы на 1 минуту изменяете внешний вид своих глаз.
Если вы накладываете это заклинание несколько раз, у вас может быть до трёх активных эффектов с длительностью в 1 минуту, и вы можете оканчивать такие эффекты действием.''';
}
