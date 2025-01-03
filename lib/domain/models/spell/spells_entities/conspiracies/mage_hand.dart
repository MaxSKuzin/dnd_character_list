import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class MageHand extends Spell {
  @override
  String name = 'Волшебная рука';

  @override
  int distance = 30;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
  ];

  @override
  Duration duration = const Duration(minutes: 1);

  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  bool isConcentration = false;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.inventor,
    ClassKind.witch,
    ClassKind.sorcerer,
  ];

  @override
  int? get durationInRounds => null;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''В точке, выбранной вами в пределах дистанции, появляется призрачная парящая рука. Рука существует, пока заклинание активно или пока вы не отпустите её действием. Рука исчезает, если окажется более чем в 30 футах от вас или если вы повторно наложите это заклинание.

Вы можете действием контролировать руку. С её помощью вы можете манипулировать предметами, открывать незапертые двери и контейнеры, убирать предметы в открытые контейнеры и доставать их оттуда или выливать содержимое флаконов. При каждом использовании руки вы можете переместить её на 30 футов.

Рука не может совершать атаки, активировать магические предметы и переносить более 10 фунтов (4,5 кг).
''';
}
