import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class CureWounds extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.bard,
    ClassKind.driud,
    ClassKind.cliric,
    ClassKind.inventor,
    ClassKind.paladin,
    ClassKind.ranger,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
  ];

  @override
  int distance = 0;

  @override
  Duration duration = Duration.zero;

  @override
  int? durationInRounds;

  @override
  bool isConcentration = false;

  @override
  String name = 'Защита от зла и добра';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec) {
    final stat = spec.spellKind!;
    final bonus = player.stats[stat]!.bonus;
    return '''Существо, которого вы касаетесь, восстанавливает количество хитов, равное 1к8+$bonus. Это заклинание не оказывает никакого эффекта на Нежить и Конструктов.

На больших уровнях. Если вы накладываете это заклинание, используя ячейку 2-го уровня или выше, лечение увеличивается на 1к8 за каждый уровень ячейки выше первого.''';
  }

  @override
  String get rawDescription =>
      '''Существо, которого вы касаетесь, восстанавливает количество хитов, равное 1к8 + ваш модификатор базовой характеристики. Это заклинание не оказывает никакого эффекта на Нежить и Конструктов.''';
}
