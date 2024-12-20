import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class PhantasmalForce extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.sorcerer,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('кусок овечьей шерсти'),
  ];

  @override
  int distance = 60;

  @override
  Duration? duration = const Duration(minutes: 1);

  @override
  int? durationInRounds;

  @override
  bool isConcentration = true;

  @override
  String name = 'Воображаемая сила';

  @override
  SpellSlot slot = SpellSlot.level2;

  @override
  String description(Player player, Specialization spec) => rawDescription;

  @override
  String get rawDescription =>
      '''Вы создаете иллюзию в сознании существа, видимого в пределах дистанции. Цель должна совершить спасбросок Интеллекта. При провале вы создаете воображаемый предмет, существо или другое видимое явление на свой выбор, помещающееся в куб с длиной ребра 10 футов, и воспринимаемое только целью, пока действует заклинание. Это заклинание не оказывает никакого эффекта на Нежить и Конструктов.

Иллюзия включает звуки, температуру и прочие раздражители, очевидные только для этого же существа.

Цель может действием исследовать иллюзию проверкой Интеллекта (Расследование) против Сл ваших заклинаний. Если проверка была успешной, цель понимает, что перед ней иллюзия, и заклинание оканчивается.

Пока цель находится под действием этого заклинания, она считает иллюзию настоящей. Она сама придумывает объяснения нелогичности взаимодействия с иллюзией. Например, попытавшись пройти по вымышленному мосту над провалом, она упадет вниз. Если цель выживет, она все равно будет считать, что мост существует, а пройти ей помешало что-то другое — её толкнули, она поскользнулась, или её сбил сильный порыв ветра.

Цель настолько уверена в существовании иллюзии, что даже будет получать от неё урон. Иллюзия в форме существа может атаковать цель. Иллюзия, выглядящая как огонь, бассейн с кислотой или лава, могут сжечь цель. Каждый раунд в ваш ход иллюзия может причинить цели 1к6 урона психической энергией, если та находится в области иллюзии или в пределах 5 футов от иллюзии существа или опасности, способной причинять урон, например, атаковав. Цель воспринимает урон того вида, что соответствует иллюзии.''';
}
