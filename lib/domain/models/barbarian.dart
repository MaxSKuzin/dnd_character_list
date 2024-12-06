import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

final class Barbarian extends Specialization {
  Barbarian({
    required super.level,
    required super.isMain,
  });

  @override
  String name = 'Варвар';

  @override
  Dice hitDice = Dice.k12;

  @override
  int healthPerLevel = 7;

  @override
  int startHealth = 12;

  @override
  List<StatKind> get chosenSaveThrows => [
        StatKind.strength,
        StatKind.constitution,
      ];

  @override
  int getProtection(Player player) {
    if (player.armor == null) {
      return 10 + player.dexterity.bonus + player.constitution.bonus;
    }
    return super.getProtection(player);
  }

  @override
  double magicLevelMultiplier = 0;

  @override
  Specialization copyWith({int? level, bool? isMain}) => Barbarian(
        level: level ?? this.level,
        isMain: isMain ?? this.isMain,
      );
}
