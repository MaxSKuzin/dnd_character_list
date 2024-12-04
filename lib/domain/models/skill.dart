import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@freezed
class Skill {
  final StatKind origin;
  final bool isChosen;
  final String name;

  Skill({
    required this.origin,
    required this.name,
    this.isChosen = false,
  });

  int getBonus(Player player) {
    var mainBonus = switch (origin) {
      StatKind.strength => player.strength.bonus,
      StatKind.dexterity => player.dexterity.bonus,
      StatKind.constitution => player.constitution.bonus,
      StatKind.intelligence => player.intelligence.bonus,
      StatKind.wisdom => player.wisdom.bonus,
      StatKind.charisma => player.charisma.bonus,
    };

    if (isChosen) {
      return mainBonus + player.proficiencyBonus;
    }
    return mainBonus;
  }
}
