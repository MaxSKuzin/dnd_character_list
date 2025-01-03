import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ComprehendLanguages extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  bool isRitual = true;

  @override
  List<ClassKind> allowedSpecializations = [ClassKind.bard];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('щепотка сажи или соли'),
  ];

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Пока заклинание активно, вы понимаете буквальный смысл всех услышанных речей на любых языках. Вы также понимаете письмена на любых языках, но вы должны касаться поверхности, на которой записаны слова. Требуется примерно 1 минута для чтения одной страницы текста.

Это заклинание не расшифровывает тайные послания в текстах и символы, такие как магические знаки, не являющиеся частью текста.''';

  @override
  int distance = 0;

  @override
  Duration? duration = const Duration(hours: 1);

  @override
  int? durationInRounds;

  @override
  bool isConcentration = false;

  @override
  String name = 'Понимание языков';

  @override
  SpellSlot slot = SpellSlot.level1;
}
