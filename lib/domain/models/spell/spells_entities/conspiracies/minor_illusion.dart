import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class MinorIllusion extends Spell {
  @override
  String name = 'Малая иллюзия';

  @override
  int distance = 30;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.s(),
    SpellComponent.m('кусок овечьей шерсти)'),
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
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.witch,
    ClassKind.sorcerer,
  ];

  @override
  int? get durationInRounds => null;

  @override
  String description(Player player, Specialization spec) {
    final spellKind = spec.spellKind;
    final spellStat = player.spellKinds.firstWhere((e) => e.statKind == spellKind);
    return '''Вы создаёте звук или образ предмета в пределах дистанции, существующий, пока активно заклинание. Иллюзия также оканчивается, если вы отпустите её действием или используете это заклинание ещё раз.

Если вы создаёте звук, его громкость может быть как шепотом, так и криком. Это может быть ваш голос, чей-то другой голос, львиный рык, бой барабанов или любой другой звук по вашему выбору. Звук звучит всю длительность заклинания, или вы можете создавать отдельные звуки в разное время, пока заклинание активно.

Если вы создаёте образ предмета — например, стул, отпечаток в грязи, или небольшой сундук — он должен помещаться в куб с длиной ребра 5 футов. Образ не может издавать звуки, свет, запах или прочие сенсорные эффекты. Физическое взаимодействие с образом даёт понять, что это иллюзия, потому что сквозь него все проходит.

Если существо действием исследует звук или образ, оно может понять, что это иллюзия, совершив успешную проверку Интеллекта (Расследование) против ${spellStat.saveThrow}. Если существо распознает иллюзию, она для него становится нечёткой.''';
  }

  @override
  String get rawDescription =>
      '''Вы создаёте звук или образ предмета в пределах дистанции, существующий, пока активно заклинание. Иллюзия также оканчивается, если вы отпустите её действием или используете это заклинание ещё раз.

Если вы создаёте звук, его громкость может быть как шепотом, так и криком. Это может быть ваш голос, чей-то другой голос, львиный рык, бой барабанов или любой другой звук по вашему выбору. Звук звучит всю длительность заклинания, или вы можете создавать отдельные звуки в разное время, пока заклинание активно.

Если вы создаёте образ предмета — например, стул, отпечаток в грязи, или небольшой сундук — он должен помещаться в куб с длиной ребра 5 футов. Образ не может издавать звуки, свет, запах или прочие сенсорные эффекты. Физическое взаимодействие с образом даёт понять, что это иллюзия, потому что сквозь него все проходит.

Если существо действием исследует звук или образ, оно может понять, что это иллюзия, совершив успешную проверку Интеллекта (Расследование) против Сл ваших заклинаний. Если существо распознает иллюзию, она для него становится нечёткой.''';
}
