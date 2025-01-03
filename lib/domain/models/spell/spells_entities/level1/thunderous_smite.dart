import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ThunderousSmite extends Spell {
  @override
  SpellTime castTimeType = SpellTime.bonusAction;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.paladin,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
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
  String name = 'Громовая кара';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''В первый раз, когда вы попадаете рукопашной атакой оружием, пока заклинание активно, ваше оружие издаёт громовой рокот, слышимый с расстояния 300 футов, и атака причиняет цели дополнительный урон звуком <b>2к6</b>. Кроме того, если цель — существо, она должна преуспеть в спасброске Силы, иначе она будет оттолкнута на 10 футов от вас и <b>сбита с ног</b>.''';
}
