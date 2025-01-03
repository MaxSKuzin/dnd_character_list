import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ShockingGrasp extends Spell {
  @override
  String name = 'Электрошок';

  @override
  int distance = 0;

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
    ClassKind.wizard,
    ClassKind.inventor,
    ClassKind.sorcerer,
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

    final dice = Dice.k8;
    return '''Молния спрыгивает с вашей руки и ударяет существо, которого вы пытались коснуться. Совершите по цели рукопашную атаку заклинанием. Вы совершаете бросок атаки с преимуществом, если цель носит доспех из металла. При попадании цель получает $diceCount${dice.name} урона электричеством и до начала своего следующего хода не может совершать реакции''';
  }

  @override
  String get rawDescription =>
      '''Молния спрыгивает с вашей руки и ударяет существо, которого вы пытались коснуться. Совершите по цели рукопашную атаку заклинанием. Вы совершаете бросок атаки с преимуществом, если цель носит доспех из металла. При попадании цель получает 1к8 урона электричеством и до начала своего следующего хода не может совершать реакции.

Урон заклинания увеличивается на 1к8, когда вы достигаете 5-го уровня (2к8), 11-го уровня (3к8) и 17-го уровня (4к8).''';
}
