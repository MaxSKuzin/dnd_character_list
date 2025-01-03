import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

class MagicMouth extends Spell {
  @override
  SpellTime castTimeType = SpellTime.action;

  @override
  int timeToCast = 1;

  @override
  List<ClassKind> allowedSpecializations = [
    ClassKind.bard,
    ClassKind.wizard,
    ClassKind.inventor,
  ];

  @override
  List<SpellComponent> components = [
    SpellComponent.v(),
    SpellComponent.s(),
    SpellComponent.m('кусочек медовых сот и порошок нефрита, стоящий как минимум 10 зм, расходуемые заклинанием'),
  ];

  @override
  int distance = 30;

  @override
  Duration? duration = Duration.zero;

  @override
  int? durationInRounds;

  @override
  bool isConcentration = false;

  @override
  String name = 'Волшебные уста';

  @override
  SpellSlot slot = SpellSlot.level2;

  @override
  String description(Player player, Specialization spec, SpellSlot slotToUse) => rawDescription;

  @override
  String get rawDescription =>
      '''Вы внедряете в предмет, находящийся в пределах дистанции, послание, которое будет произнесено, когда будут выполнены условия. Выберите видимый предмет, который не несет и не носит другое существо. Произнесите послание, которое может состоять не более чем из 25 слов, хотя его можно произносить в течение 10 минут. Затем определите условие, выполнение которого заставит заклинание передать ваше послание.

Когда условие будет выполнено, на предмете появляется магический рот, зачитывающий послание вашим голосом с той же самой громкостью. Если у выбранного вами предмета есть рот или что-то похожее на рот (например, рот статуи), магический рот появляется на его месте, и кажется, что слова исходят оттуда. При накладывании заклинания вы можете сделать так, что заклинание окончится, передав сообщение, или же останется активным и будет повторять сообщение при каждом срабатывании условия.

Вызывающее срабатывание условие может быть как общим, так и детализированным, но должно основываться на зрительных или слышимых условиях, происходящих в пределах 30 футов от предмета. Например, вы можете заставить рот говорить, когда в пределах 30 футов от него пройдет существо, или когда в пределах 30 футов от него зазвенит серебряный колокольчик.''';
}
