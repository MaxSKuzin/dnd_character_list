import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';

final class Barbarian extends Specialization {
  Barbarian({
    required super.level,
    required super.isMain,
  });

  @override
  String get name => 'Варвар';

  @override
  Dice hitDice = Dice.k12;

  @override
  int healthPerLevel = 7;

  @override
  int startHealth = 12;
}
