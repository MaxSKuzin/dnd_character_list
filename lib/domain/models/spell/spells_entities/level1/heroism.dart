import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Heroism extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.paladin,
    ClassKind.bard,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
  ];

  @override
  int distance = 0;

  @override
  Duration duration = const Duration(minutes: 60);

  @override
  int? durationInRounds;

  @override
  bool isConcentration = true;

  @override
  String name = 'Героизм';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  bool get hasEffectOnHigherLevels => true;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) {
    final target = switch (slotToUse) {
      SpellSlot.conspiracy => throw UnimplementedError(),
      SpellSlot.level1 => 'Согласное существо, которого вы касаетесь, наполняется храбростью',
      SpellSlot.level2 => 'Два согласных существа, которых вы касаетесь, наполняются храбростью',
      SpellSlot.level3 => 'Три согласных существа, которых вы касаетесь, наполняются храбростью',
      SpellSlot.level4 => 'Четыре согласных существа, которых вы касаетесь, наполняются храбростью',
      SpellSlot.level5 => 'Пять согласных существ, которых вы касаетесь, наполняются храбростью',
      SpellSlot.level6 => 'Шесть согласных существ, которых вы касаетесь, наполняются храбростью',
      SpellSlot.level7 => 'Семь согласных существ, которых вы касаетесь, наполняются храбростью',
      SpellSlot.level8 => 'Восемь согласных существ, которых вы касаетесь, наполняются храбростью',
      SpellSlot.level9 => 'Девять согласных существ, которых вы касаетесь, наполняются храбростью',
    };

    return '''$target. Пока заклинание активно, существо получает иммунитет к состоянию испуга, и в начале каждого своего хода получает временные хиты, равные модификатору вашей базовой характеристики. Когда это заклинание оканчивается, цель теряет все временные хиты, оставшиеся от этого заклинания.''';
  }

  @override
  String get rawDescription =>
      '''Согласное существо, которого вы касаетесь, наполняется храбростью. Пока заклинание активно, существо получает иммунитет к состоянию испуга, и в начале каждого своего хода получает временные хиты, равные модификатору вашей базовой характеристики. Когда это заклинание оканчивается, цель теряет все временные хиты, оставшиеся от этого заклинания.
      
      На больших уровнях. Если вы накладываете это заклинание, используя ячейку 2-го уровня или выше, вы можете сделать целью одно дополнительное существо за каждый уровень ячейки выше первого.''';
}
