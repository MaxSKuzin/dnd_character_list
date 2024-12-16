import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class TrueStrike extends Spell {
  @override
  String name = 'Меткий удар';

  @override
  int distance = 30;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [SpellComponent.s()];

  @override
  Duration duration = const Duration(minutes: 1);

  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  bool isConcentration = true;

  @override
  List<ClassKind> allowedSpecializations = [ClassKind.bard];

  @override
  int? get durationInRounds => null;

  @override
  String description(Player player, Specialization spec) {
    return 'Вы вытягиваете руку и указываете пальцем на цель, находящуюся в пределах дистанции. Ваша магия даёт краткое понимание защиты цели. В своем следующем ходу вы совершаете с преимуществом первый бросок атаки по цели, при условии, что заклинание к тому моменту не окончится.';
  }
}
