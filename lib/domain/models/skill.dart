import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

/// Навыки; имена значений совпадают с кодами ttg.club в camelCase (`SLEIGHT_OF_HAND` → `sleightOfHand`).
enum Skill {
  athletics(StatKind.strength),
  acrobatics(StatKind.dexterity),
  sleightOfHand(StatKind.dexterity),
  stealth(StatKind.dexterity),
  history(StatKind.intelligence),
  arcana(StatKind.intelligence),
  nature(StatKind.intelligence),
  investigation(StatKind.intelligence),
  religion(StatKind.intelligence),
  perception(StatKind.wisdom),
  survival(StatKind.wisdom),
  medicine(StatKind.wisdom),
  insight(StatKind.wisdom),
  animalHandling(StatKind.wisdom),
  performance(StatKind.charisma),
  intimidation(StatKind.charisma),
  deception(StatKind.charisma),
  persuasion(StatKind.charisma);

  const Skill(this.origin);

  final StatKind origin;

  /// Модификатор характеристики плюс бонус мастерства при владении (двойной при компетентности).
  /// Без владения добавляется половина бонуса, если у персонажа есть «Мастер на все руки».
  int getBonus(Player player) {
    final statBonus = player.stats[origin]!.bonus;
    if (player.expertiseSkills.contains(this)) {
      return statBonus + player.proficiencyBonus * 2;
    }
    if (player.chosenSkills.contains(this)) {
      return statBonus + player.proficiencyBonus;
    }
    return statBonus + player.unskilledCheckBonus;
  }
}
