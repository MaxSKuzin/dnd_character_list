import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ThornWhip extends Spell {
  @override
  String name = 'Терновый кнут';

  @override
  int distance = 30;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
  ];

  @override
  Duration duration = Duration.zero;

  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  bool isConcentration = false;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.driud,
    ClassKind.inventor,
  ];

  @override
  int? durationInRounds;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) {
    final diceCount = spec.level >= 5
        ? 2
        : spec.level >= 11
            ? 3
            : spec.level >= 17
                ? 4
                : 1;

    final dice = Dice.k6;
    return '''Вы создаёте длинный, похожий на лозу кнут, покрытый шипами, бьющий по вашей команде существо, находящееся в пределах дистанции. Совершите рукопашную атаку заклинанием по цели. Если атака попадает, существо получает колющий урон $diceCount${dice.name}, и, если размер существа не больше Большого, вы подтягиваете существо на расстояние до 10 футов к себе..''';
  }

  @override
  String get rawDescription =>
      '''Вы создаёте длинный, похожий на лозу кнут, покрытый шипами, бьющий по вашей команде существо, находящееся в пределах дистанции. Совершите рукопашную атаку заклинанием по цели. Если атака попадает, существо получает колющий урон 1к6, и, если размер существа не больше Большого, вы подтягиваете существо на расстояние до 10 футов к себе.

Урон этого заклинания увеличивается на 1к6, когда вы достигаете 5 уровня (2к6), 11 уровня (3к6) и 17 уровня (4к6).''';
}
