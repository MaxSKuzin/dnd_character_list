import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class SearingSmite extends Spell {
  @override
  SpellTime castTimeType = SpellTime.bonusAction;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.paladin,
    ClassKind.ranger,
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
  String name = 'Палящая кара';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec) => rawDescription;

  @override
  String get rawDescription =>
      '''Когда вы в следующий раз попадёте по существу рукопашной атакой оружием, пока заклинание активно, ваше оружие вспыхивает ярким белым светом, и атака причиняет цели дополнительный 1к6 урона огнём и поджигает её. Пока заклинание активно, цель в начале каждого своего хода должна совершать спасбросок Телосложения. При провале она получает <b>1к6</b> урона огнём. При успехе заклинание заканчивается. Если цель или существо, находящееся в пределах 5 футов от неё, потратит действие на тушение пламени, или если какой-то другой эффект потушит пламя (например, погружение в воду), заклинание тоже закончится.''';
}
