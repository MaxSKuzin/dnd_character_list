import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

final class Wisard extends Specialization {
  Wisard({
    required super.level,
    required super.isMain,
  });

  @override
  String name = 'Волшебник';

  @override
  Dice hitDice = Dice.k6;

  @override
  int healthPerLevel = 4;

  @override
  int startHealth = 6;

  @override
  double magicLevelMultiplier = 1;

  @override
  StatKind spellKind = StatKind.intelligence;

  @override
  List<StatKind> get chosenSaveThrows => [
        StatKind.intelligence,
        StatKind.wisdom,
      ];

  @override
  Specialization copyWith({int? level, bool? isMain}) => Wisard(
        level: level ?? this.level,
        isMain: isMain ?? this.isMain,
      );
}
