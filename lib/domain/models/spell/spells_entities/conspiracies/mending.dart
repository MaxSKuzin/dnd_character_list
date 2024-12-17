import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Mending extends Spell {
  @override
  String name = 'Починка';

  @override
  int distance = 0;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.s(),
    SpellComponent.v(),
    SpellComponent.m('два магнетита'),
  ];

  @override
  Duration duration =  Duration.zero;

  @override
  SpellTime castTimeType = SpellTime.minute;

  @override
  int timeToCast = 1;

  @override
  bool isConcentration = false;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.sorcerer,
    ClassKind.inventor,
    ClassKind.driud,
    ClassKind.cliric,
  ];

  @override
  int? get durationInRounds => null;

  @override
  String description(Player player, Specialization spec) => rawDescription;

  @override
  String get rawDescription =>
      '''Это заклинание чинит одно повреждение или разрыв на предмете, которого касаетесь, например, разорванное звено цепи, две половинки сломанного ключа, порванный плащ или протекающий бурдюк. Если повреждение или разрыв не больше 1 фута в любом измерении, вы чините его, не оставляя следов.

Это заклинание может физически починить магический предмет или Конструкта, но не может восстановить магию в таких предметах.''';
}
