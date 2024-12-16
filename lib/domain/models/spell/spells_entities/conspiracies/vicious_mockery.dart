import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class ViciousMockery extends Spell {
  @override
  String name = 'Злая насмешка';

  @override
  int distance = 60;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [SpellComponent.v()];

  @override
  Duration duration = Duration.zero;

  @override
  bool isConcentration = false;

  @override
  List<ClassKind> allowedSpecializations = [ClassKind.bard];

  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  int? get durationInRounds => null;

  @override
  String description(Player player, Specialization spec) {
    final diceCount = spec.level >= 5
        ? 2
        : spec.level >= 11
            ? 3
            : spec.level >= 17
                ? 4
                : 1;

    final dice = Dice.k4;
    return 'Вы испускаете на существо, видимое в пределах дистанции, поток оскорблений вперемешку с тонкой магией. Если цель слышит вас (при этом она не обязана вас понимать), она должна преуспеть в спасброске Мудрости, иначе получит урон психической энергией $diceCount${dice.name}, и следующий бросок атаки до конца своего следующего хода совершит с помехой.';
  }
}
