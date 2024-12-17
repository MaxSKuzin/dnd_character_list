import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Friends extends Spell {
  @override
  String name = 'Дружба';

  @override
  int distance = 0;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.m('небольшое количество грима, наносимое на лицо при накладывании этого заклинания'),
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
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.witch,
    ClassKind.sorcerer,
  ];

  @override
  int? get durationInRounds => null;

  @override
  String description(Player player, Specialization spec) => rawDescription;

  @override
  String get rawDescription =>
      '''Пока заклинание активно, вы совершаете с преимуществом все проверки Харизмы, направленные на одно выбранное вами существо, не враждебное по отношению к вам. Когда заклинание оканчивается, существо понимает, что вы влияли на её отношение с помощью магии, и становится враждебным по отношению к вам. Существо, склонное к насилию, может напасть на вас. Другие могут требовать другого возмездия (решает Мастер), в зависимости от отношений, сложившихся между вами.''';
}
