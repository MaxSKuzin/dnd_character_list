import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Message extends Spell {
  @override
  String name = 'Сообщение';

  @override
  int distance = 120;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('кусочек медной проволоки'),
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
    ClassKind.inventor,
    ClassKind.sorcerer,
  ];

  @override
  int? get durationInRounds => 1;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Вы указываете пальцем в направлении существа, находящегося в пределах дистанции, и шепчете послание. Цель (и только цель) слышит его, и может ответить шепотом, который услышите только вы.

Вы можете использовать это заклинание сквозь твердые препятствия, если вы знакомы с целью и знаете, что она находится за барьером. Магическая тишина, 1 фут камня, 1 дюйм обычного металла, тонкий лист свинца или 3 фута дерева блокируют заклинание. Заклинание не обязано идти по прямой линии, и может огибать углы и проходить через отверстия.''';
}
