import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ThunderWave extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [ClassKind.bard];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
  ];

  @override
  String description(Player player, Specialization spec) {
    return '''
От вас исходит волна громовой силы. Все существа в кубе с длиной ребра 15 футов, исходящего от вас, должны совершить спасбросок Телосложения. При провале существо получает 2к8 урона звуком и отталкивается на 10 футов от вас. При успехе существо получает половину урона и не толкается.

Кроме того, незакреплённые предметы, оказавшиеся полностью в области эффекта, автоматически толкаются на 10 футов от вас эффектом заклинания, и заклинание издает громовой рокот, слышимый на расстоянии 300 футов.
''';
  }

  @override
  int distance = 15;

  @override
  Duration? duration = Duration.zero;

  @override
  int? durationInRounds;

  @override
  bool isConcentration = false;

  @override
  String name = 'Волна грома';

  @override
  SpellSlot slot = SpellSlot.level1;
}
