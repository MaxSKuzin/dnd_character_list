import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class HealingWord extends Spell {
  @override
  SpellTime castTimeType = SpellTime.bonusAction;

  @override
  int timeToCast = 1;

  @override
  List<Type> allowedSpecializations = [Bard];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
  ];

  @override
  String description(Player player, Specialization spec) {
    final stat = spec.spellKind!;
    final bonus = player.stats[stat]!.bonus;

    return 'Существо на ваш выбор, видимое в пределах дистанции, восстанавливает количество хитов, равное 1к4+$bonus(${stat.name.substring(0, 3)}). Это заклинание не оказывает никакого эффекта на Нежить и Конструктов.';
  }

  @override
  int distance = 60;

  @override
  Duration? duration = Duration.zero;

  @override
  int? durationInRounds;

  @override
  bool isConcentration = false;

  @override
  String name = 'Лечащее слово';

  @override
  SpellSlot slot = SpellSlot.level1;
}
