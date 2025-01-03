import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Bless extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.paladin,
    ClassKind.cliric,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('капля святой воды'),
  ];

  @override
  int distance = 30;

  @override
  Duration duration = const Duration(minutes: 60);

  @override
  int? durationInRounds;

  @override
  bool isConcentration = true;

  @override
  String name = 'Благословение';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  bool get hasEffectOnHigherLevels => true;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) {
    final String count = switch (slotToUse) {
      SpellSlot.level1 => 'трёх',
      SpellSlot.level2 => 'четырёх',
      SpellSlot.level3 => 'пяти',
      SpellSlot.level4 => 'шести',
      SpellSlot.level5 => 'семи',
      SpellSlot.level6 => 'восьми',
      SpellSlot.level7 => 'девяти',
      SpellSlot.level8 => 'десяти',
      SpellSlot.level9 => 'одиннадцати',
      _ => throw UnimplementedError()
    };
    return '''Вы благословляете до $count существ на свой выбор в пределах дистанции. Каждый раз, когда до окончания заклинания цель совершает бросок атаки или спасбросок, она может бросить <b>к4</b> и добавить выпавшее число к результату.''';
  }

  @override
  String get rawDescription =>
      '''Вы благословляете до трёх существ на свой выбор в пределах дистанции. Каждый раз, когда до окончания заклинания цель совершает бросок атаки или спасбросок, она может бросить <b>к4</b> и добавить выпавшее число к результату.
      
      <b>На больших уровнях</b>. Если вы накладываете это заклинание, используя ячейку 2-го уровня или выше, вы можете сделать целью одно дополнительное существо за каждый уровень ячейки выше 1-го.''';
}
