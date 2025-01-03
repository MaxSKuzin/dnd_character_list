import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Prestidigitation extends Spell {
  @override
  String name = 'Фокусы';

  @override
  int distance = 10;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
  ];

  @override
  Duration duration = const Duration(minutes: 60);

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
  int? durationInRounds;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Это заклинание — небольшой магический трюк, на котором практикуются начинающие заклинатели. Вы создаете один из следующих магических эффектов в пределах дистанции:

Вы создаете мгновенный безвредный сенсорный эффект, такой как сноп искр, порыв ветра, тихую мелодию, или необычный запах.
Вы мгновенно зажигаете или тушите свечу, факел или небольшой костер.
Вы мгновенно чистите или мараете предмет, размерами не превышающий 1 кубического фута.
Вы остужаете, нагреваете или придаете вкус 1 кубическому футу неживой материи на 1 час.
Вы создаёте на поверхности или предмете цвет, метку или символ, существующую 1 час.
Вы создаёте немагическую безделушку или иллюзорное изображение, помещающееся в вашу ладонь, и существующее до конца вашего следующего хода.

Если вы накладываете это заклинание несколько раз, вы можете иметь не более трёх немгновенных эффектов одновременно. Вы можете действием окончить один из этих эффектов.''';
}
