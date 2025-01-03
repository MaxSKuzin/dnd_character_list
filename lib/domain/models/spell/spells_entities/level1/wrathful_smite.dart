import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class WrathfulSmite extends Spell {
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
  String name = 'Гневная кара';

  @override
  SpellSlot slot = SpellSlot.level1;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''В следующий раз, когда вы попадёте рукопашной атакой оружием, пока активно это заклинание, ваша атака причиняет дополнительный <b>1к6</b> урона психической энергией. Кроме того, если цель — существо, оно должно совершить спасбросок Мудрости, иначе оно станет <b>испуганным</b> до окончания действия заклинания. Существо может действием совершить проверку Мудрости против Сл ваших заклинаний, чтобы успокоиться и окончить это заклинание.''';
}
