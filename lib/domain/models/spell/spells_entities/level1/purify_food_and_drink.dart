import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class PurifyFoodAndDrink extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.driud,
    ClassKind.cliric,
    ClassKind.inventor,
    ClassKind.paladin,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
  ];

  @override
  int distance = 10;

  @override
  Duration duration = Duration.zero;

  @override
  int? durationInRounds;

  @override
  bool isConcentration = true;

  @override
  String name = 'Очищение пищи и питья';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec) => rawDescription;

  @override
  String get rawDescription =>
      '''Вся немагическая еда и питьё в пределах сферы с радиусом 5 футов с центром на точке, выбранной вами в пределах дистанции, очищается и избавляется от ядов и болезней.''';
}
