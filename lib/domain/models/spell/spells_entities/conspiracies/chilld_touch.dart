import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ChilldTouch extends Spell {
  @override
  String name = 'Леденящее прикосновение';

  @override
  int distance = 120;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
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
    ClassKind.wizard,
    ClassKind.witch,
    ClassKind.sorcerer,
  ];

  @override
  int durationInRounds = 1;

  @override
  String description(Player player, Specialization spec) {
    final diceCount = spec.level >= 5
        ? 2
        : spec.level >= 11
            ? 3
            : spec.level >= 17
                ? 4
                : 1;

    final dice = Dice.k8;
    return '''Вы создаете призрачную руку скелета в пространстве существа, находящегося в пределах дистанции. Совершите дальнобойную атаку заклинанием по существу, чтобы окутать его могильным холодом. При попадании цель получает $diceCount${dice.name} урона некротической энергией и не может восстанавливать хиты до начала вашего следующего хода. Все это время рука держится за цель.

Если вы попадаете по Нежити, то она также совершает по вам броски атаки с помехой до конца вашего следующего хода.''';
  }

  @override
  String get rawDescription =>
      '''Вы создаете призрачную руку скелета в пространстве существа, находящегося в пределах дистанции. Совершите дальнобойную атаку заклинанием по существу, чтобы окутать его могильным холодом. При попадании цель получает 1к8 урона некротической энергией и не может восстанавливать хиты до начала вашего следующего хода. Все это время рука держится за цель.

Если вы попадаете по Нежити, то она также совершает по вам броски атаки с помехой до конца вашего следующего хода.

Урон этого заклинания увеличивается на 1к8, когда вы достигаете 5-го уровня (2к8), 11-го уровня (3к8) и 17-го уровня (4к8).''';
}
