import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ProduceFlame extends Spell {
  @override
  String name = 'Сотворение пламени';

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
  Duration duration = const Duration(minutes: 10);

  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  bool isConcentration = false;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.driud,
  ];

  @override
  int? durationInRounds;

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
    return '''В вашей ладони появляется мерцающее пламя. Оно остаётся там, пока заклинание активно, и не вредит ни вам, ни вашему снаряжению. Огонь испускает яркий свет в радиусе 10 футов и тусклый свет в пределах ещё 10 футов. Заклинание оканчивается, если вы оканчиваете его действием или накладываете ещё раз.

Вы можете атаковать этим пламенем, но это тоже оканчивает заклинание. Когда вы накладываете это заклинание, или другим действием в одном из последующих ходов вы можете метнуть пламя в существо, находящееся в пределах 30 футов от вас. Совершите дальнобойную атаку заклинанием. При попадании цель получает урон огнём $diceCount${dice.name}.''';
  }

  @override
  String get rawDescription =>
      '''В вашей ладони появляется мерцающее пламя. Оно остаётся там, пока заклинание активно, и не вредит ни вам, ни вашему снаряжению. Огонь испускает яркий свет в радиусе 10 футов и тусклый свет в пределах ещё 10 футов. Заклинание оканчивается, если вы оканчиваете его действием или накладываете ещё раз.

Вы можете атаковать этим пламенем, но это тоже оканчивает заклинание. Когда вы накладываете это заклинание, или другим действием в одном из последующих ходов вы можете метнуть пламя в существо, находящееся в пределах 30 футов от вас. Совершите дальнобойную атаку заклинанием. При попадании цель получает урон огнём 1к8.

Урон этого заклинания увеличивается на 1к8, когда вы достигаете 5-го уровня (2к8), 11-го уровня (3к8) и 17-го уровня (4к8).''';
}
