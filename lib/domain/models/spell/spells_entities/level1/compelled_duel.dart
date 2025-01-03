import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class CompelledDuel extends Spell {
  @override
  SpellTime castTimeType = SpellTime.bonusAction;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.paladin,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
  ];

  @override
  int distance = 30;

  @override
  Duration duration = const Duration(minutes: 60);

  @override
  int? durationInRounds;

  @override
  bool isConcentration = true;

  @override
  String name = 'Вызов на дуэль';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Вы пытаетесь вызвать существо на дуэль. Одно существо, которое вы видите в пределах дистанции, должно совершить спасбросок Мудрости. При провале существо концентрирует своё внимание на вас, следуя вашему божественному требованию. Пока заклинание активно, это существо совершает с помехой броски атаки по всем существам кроме вас, и должно совершать спасброски Мудрости каждый раз, когда пытается переместиться в пространство, находящееся более чем в 30 футах от вас; в случае успеха это заклинание не ограничивает перемещения цели в этот ход.

Заклинание оканчивается, если вы атакуете другое существо, если вы накладываете заклинание, нацеленное на враждебное существо, но не на цель, если дружественное вам существо причиняет цели урон или накладывает на неё вредоносное заклинание, или если вы оканчиваете ход далее, чем в 30 футах от цели.''';
}
