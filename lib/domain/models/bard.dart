import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

final class Bard extends Specialization {
  Bard({
    required super.level,
    required super.isMain,
  });

  @override
  String name = 'Бард';

  @override
  Dice hitDice = Dice.k8;

  @override
  int healthPerLevel = 5;

  @override
  int startHealth = 8;

  @override
  List<StatKind> get chosenSaveThrows => [
        StatKind.dexterity,
        StatKind.charisma,
      ];
}
