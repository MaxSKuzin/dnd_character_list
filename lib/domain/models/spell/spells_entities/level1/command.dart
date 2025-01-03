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
  bool get hasEffectOnHigherLevels => true;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) {
    final target = switch (slotToUse) {
      SpellSlot.conspiracy => throw UnimplementedError(),
      SpellSlot.level1 => 'Одному существу',
      SpellSlot.level2 => 'Двум существам',
      SpellSlot.level3 => 'Трем существам',
      SpellSlot.level4 => 'Четырем существам',
      SpellSlot.level5 => 'Пяти существам',
      SpellSlot.level6 => 'Шести существам',
      SpellSlot.level7 => 'Семи существам',
      SpellSlot.level8 => 'Восьми существам',
      SpellSlot.level9 => 'Девяти существам',
    };

    return '''Вы произносите команду из одного слова $target, в пределах видимости и дистанции. Цель должна преуспеть в спасброске Мудрости, иначе в свой следующий ход будет исполнять эту команду. Заклинание не оказывает эффект, если цель — Нежить, если цель не понимает ваш язык, или если ваша команда ему напрямую вредит.

Ниже описаны самые типичные команды и их эффекты. Вы можете отдавать и другие команды. В этом случае поведение цели определяет Мастер. Если цель не может выполнить вашу команду, заклинание оканчивается.

<b>Брось</b>. Цель роняет то, что держит, и оканчивает ход.

<b>Падай.</b>. Цель падает ничком и оканчивает ход.

<b>Подойди</b>. Цель перемещается ближе к вам по кратчайшему и самому прямому маршруту, оканчивая ход, если оказывается в пределах 5 футов от вас.

<b>Стой</b>. Цель не перемещается и не совершает никаких действий. Летающее существо продолжает лететь, при условии, что может это делать. Если оно должно лететь, чтобы не упасть, то пролетает минимально необходимое расстояние.

<b>Убегай</b>. Цель тратит ход на то, что перемещается прочь от вас самым быстрым способом.''';
  }

  @override
  String get rawDescription =>
      '''Вы произносите команду из одного слова существу, которое видите в пределах дистанции. Цель должна преуспеть в спасброске Мудрости, иначе в свой следующий ход будет исполнять эту команду. Заклинание не оказывает эффект, если цель — Нежить, если цель не понимает ваш язык, или если ваша команда ему напрямую вредит.

Ниже описаны самые типичные команды и их эффекты. Вы можете отдавать и другие команды. В этом случае поведение цели определяет Мастер. Если цель не может выполнить вашу команду, заклинание оканчивается.

<b>Брось</b>. Цель роняет то, что держит, и оканчивает ход.

<b>Падай.</b>. Цель падает ничком и оканчивает ход.

<b>Подойди</b>. Цель перемещается ближе к вам по кратчайшему и самому прямому маршруту, оканчивая ход, если оказывается в пределах 5 футов от вас.

<b>Стой</b>. Цель не перемещается и не совершает никаких действий. Летающее существо продолжает лететь, при условии, что может это делать. Если оно должно лететь, чтобы не упасть, то пролетает минимально необходимое расстояние.

<b>Убегай</b>. Цель тратит ход на то, что перемещается прочь от вас самым быстрым способом.

<b>На больших уровнях</b>. Если вы накладываете это заклинание, используя ячейку 2-го уровня или выше, вы можете воздействовать на одно дополнительное существо за каждый уровень ячейки выше первого. Существа должны находиться в пределах 30 футов друг от друга, чтобы стать целями.''';
}
