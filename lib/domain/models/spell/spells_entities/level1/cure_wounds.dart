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
  String name = 'Лечение ран';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  bool get hasEffectOnHigherLevels => true;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) {
    final stat = spec.spellKind!;
    final bonus = player.stats[stat]!.bonus;
    return '''Существо, которого вы касаетесь, восстанавливает количество хитов, равное <b>${slotToUse.index}к8+$bonus</b>. Это заклинание не оказывает никакого эффекта на Нежить и Конструктов.''';
  }

  @override
  String get rawDescription =>
      '''Существо, которого вы касаетесь, восстанавливает количество хитов, равное <b>1к8</b> + ваш модификатор базовой характеристики. Это заклинание не оказывает никакого эффекта на Нежить и Конструктов.
      
      <b>На больших уровнях<b>. Если вы накладываете это заклинание, используя ячейку 2-го уровня или выше, лечение увеличивается на <b>1к8</b> за каждый уровень ячейки выше первого.''';
}
