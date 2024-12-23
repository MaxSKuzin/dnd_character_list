import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Command extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [ClassKind.bard];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
  ];

  @override
  int distance = 60;

  @override
  Duration? duration;

  @override
  int? durationInRounds = 1;

  @override
  bool isConcentration = false;

  @override
  String name = 'Приказ';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec) => rawDescription;

  @override
  String get rawDescription =>
      '''Вы произносите команду из одного слова существу, которое видите в пределах дистанции. Цель должна преуспеть в спасброске Мудрости, иначе в свой следующий ход будет исполнять эту команду. Заклинание не оказывает эффект, если цель — Нежить, если цель не понимает ваш язык, или если ваша команда ему напрямую вредит.

Ниже описаны самые типичные команды и их эффекты. Вы можете отдавать и другие команды. В этом случае поведение цели определяет Мастер. Если цель не может выполнить вашу команду, заклинание оканчивается.

<b>Брось</b>. Цель роняет то, что держит, и оканчивает ход.

<b>Падай.</b>. Цель падает ничком и оканчивает ход.

<b>Подойди</b>. Цель перемещается ближе к вам по кратчайшему и самому прямому маршруту, оканчивая ход, если оказывается в пределах 5 футов от вас.

<b>Стой</b>. Цель не перемещается и не совершает никаких действий. Летающее существо продолжает лететь, при условии, что может это делать. Если оно должно лететь, чтобы не упасть, то пролетает минимально необходимое расстояние.

<b>Убегай</b>. Цель тратит ход на то, что перемещается прочь от вас самым быстрым способом.''';
}
