import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Suggestion extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.witch,
    ClassKind.sorcerer,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('язык змеи и либо кусочек медовых сот, либо капля сладкого масла'),
  ];

  @override
  int distance = 30;

  @override
  Duration? duration = const Duration(hours: 8);

  @override
  int? durationInRounds;

  @override
  bool isConcentration = true;

  @override
  String name = 'Внушение';

  @override
  SpellSlot slot = SpellSlot.level2;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Вы внушаете определенный курс действий (ограниченный одной-двумя фразами) существу, видимому в пределах дистанции, способному слышать и понимать вас. Существа, которые не могут быть очарованы, обладают иммунитетом к этому эффекту. Внушение должно быть сформировано так, чтобы действие звучало разумным. Просьбы ударить себя мечом, броситься на копьё, сжечь себя, или как-то иначе причинить себе вред оканчивают заклинание.

Цель должна совершить спасбросок Мудрости. При провале она следует заданному курсу действий. Внушённые действия могут продолжаться всю длительность заклинания. Если внушённую деятельность можно выполнить за меньший срок, заклинание оканчивается, когда субъект оканчивает порученную задачу.

Вы можете также указать условие, которое запустит особое действие во время действия заклинания. Например, вы можете внушить рыцарю, чтобы он отдал своего боевого коня первому встреченному нищему. Если до окончания действия условие не будет выполнено, деятельность не совершается.

Если вы или кто-то из ваших спутников причиняете урон цели, заклинание оканчивается.''';
}
