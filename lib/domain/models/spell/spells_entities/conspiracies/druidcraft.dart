import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Druidcraft extends Spell {
  @override
  String name = 'Искусство друидов';

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
  Duration duration = Duration.zero;

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
  String description(Player player, Specialization spec) => rawDescription;

  @override
  String get rawDescription =>
      '''Пошептавшись с духами природы, вы создаёте один из следующих эффектов в пределах дистанции:

Вы создаёте крохотный безвредный ощутимый эффект, предсказывающий погоду в текущем месте в течение следующих 24 часов. Это может быть золотистый шарик, означающий ясную погоду, облачко, означающее дождь, снежинка, и так далее. Эффект длится 1 раунд.
Вы мгновенно заставляете цветок распуститься, семечко прорасти, или почку раскрыться.
Вы создаёте мгновенный безвредный ощутимый эффект, такой как падающие листья, порыв ветра, звук маленького животного, или слабый запах скунса. Эффект должен находиться в кубе с длиной ребра 5 футов.
Вы мгновенно зажигаете или тушите свечу, факел или небольшой костёр.''';
}
