import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';

final class Bard extends Specialization {
  Bard({
    required super.level,
    required super.isMain,
  });

  @override
  String get name => 'Бард';

  @override
  Dice hitDice = Dice.k8;

  @override
  int healthPerLevel = 5;

  @override
  int startHealth = 8;
}
