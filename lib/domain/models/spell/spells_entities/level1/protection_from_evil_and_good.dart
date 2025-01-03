import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ProtectionFromEvilAndGood extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.paladin,
    ClassKind.wizard,
    ClassKind.witch,
    ClassKind.driud,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('святая вода или порошок серебра и железа, расходуемые заклинанием'),
  ];

  @override
  int distance = 0;

  @override
  Duration duration = const Duration(minutes: 10);

  @override
  int? durationInRounds;

  @override
  bool isConcentration = true;

  @override
  String name = 'Защита от зла и добра';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Пока заклинание активно, одно согласное существо, которого вы коснулись, защищено от существ следующих видов: Аберрации, Исчадия, Небожители, Нежить, Феи и Элементали.

Защита предоставляет несколько преимуществ. Данные существа совершают с помехой броски атаки по цели. Цель также не может быть <b>очарована</b>, <b>испугана</b> и <b>одержима</b> ими. Если цель уже <b>очарована</b>, <b>испугана</b> или <b>одержима</b> таким существом, цель совершает последующие спасброски от таких эффектов с преимуществом.''';
}
