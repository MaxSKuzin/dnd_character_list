import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/start_equipment.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';

enum ClassKind {
  bard,
  barbarian;

  StartEquipment get equipment => switch (this) {
        ClassKind.bard => StartEquipment(
            weapons: {
              Weapon.rapier(),
              Weapon.longSword(),
              ...availableWeapons.where(
                (element) => element.kind == WeaponKind.simpleMelee || element.kind == WeaponKind.simpleRanged,
              ),
            }.toList(),
            secondWeapons: [
              Weapon.dagger(),
            ],
            armor: Armor.leather(),
          ),
        ClassKind.barbarian => StartEquipment(
            weapons: {
              Weapon.ax(),
              ...availableWeapons.where(
                (element) => element.kind == WeaponKind.martialMelee,
              ),
            }.toList(),
            secondWeapons: {
              ...availableWeapons.where(
                (element) => element.kind == WeaponKind.simpleMelee || element.kind == WeaponKind.simpleRanged,
              ),
            }.toList(),
            armor: null,
          ),
      };

  String get name => switch (this) {
        ClassKind.bard => 'Бард',
        ClassKind.barbarian => 'Варвар',
      };

  int get startSkillCount => switch (this) {
        ClassKind.bard => 3,
        ClassKind.barbarian => 2,
      };

  List<Skill> get availableSkills => switch (this) {
        ClassKind.bard => Skill.values,
        ClassKind.barbarian => [
            Skill.athletics,
            Skill.harassment,
            Skill.nature,
            Skill.perception,
            Skill.surviving,
            Skill.animalTaming,
          ],
      };

  int knownSpellsCount(int level) {
    switch (this) {
      case ClassKind.bard:
        return 3 + level;
      case ClassKind.barbarian:
        return 0;
    }
  }

  int knownConspiracies(int level) {
    switch (this) {
      case ClassKind.bard:
        return {
          1: 2,
          2: 2,
          3: 2,
          4: 3,
          5: 3,
          6: 3,
          7: 3,
          8: 3,
          9: 3,
          10: 4,
          11: 4,
          12: 4,
          13: 4,
          14: 4,
          15: 4,
          16: 4,
          17: 4,
          18: 4,
          19: 4,
          20: 4,
        }[level]!;
      case ClassKind.barbarian:
        return 0;
    }
  }
}
