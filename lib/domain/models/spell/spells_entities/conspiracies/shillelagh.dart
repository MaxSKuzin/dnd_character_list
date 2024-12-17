import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class Shillelagh extends Spell {
  @override
  String name = 'Дубинка';

  @override
  int distance = 0;

  @override
  SpellSlot slot = SpellSlot.conspiracy;

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('омела, лист клевера и дубинка или боевой посох'),
  ];

  @override
  Duration duration = const Duration(minutes: 1);

  @override
  SpellTime castTimeType = SpellTime.bonusAction;

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
      '''Дерево дубинки или боевого посоха, который вы держите, наполняется силой природы. Пока заклинание активно, вы можете использовать свою базовую заклинательную характеристику вместо Силы для бросков рукопашной атаки и урона при использовании этого оружия, и кость урона становится равной к8. Если оружие не было магическим, оно становится им. Заклинание оканчивается, если вы наложите его ещё раз или выпустите оружие из рук.''';
}
