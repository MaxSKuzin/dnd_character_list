import 'dart:math';

import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/start_equipment.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';

enum ClassKind {
  bard,
  barbarian,
  warrior,
  wizard,
  driud,
  cliric,
  inventor,
  witch,
  monk,
  paladin,
  thief,
  ranger,
  sorcerer,
  ;

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
        ClassKind.wizard => StartEquipment(
            weapons: {
              Weapon.stuff(),
              Weapon.dagger(),
            }.toList(),
            secondWeapons: null,
            armor: null,
          ),
        _ => throw UnimplementedError(),
      };

  String get name => switch (this) {
        ClassKind.bard => 'Бард',
        ClassKind.barbarian => 'Варвар',
        ClassKind.warrior => 'Воин',
        ClassKind.wizard => 'Волшебник',
        ClassKind.driud => 'Друид',
        ClassKind.cliric => 'Жрец',
        ClassKind.inventor => 'Изобретатель',
        ClassKind.witch => 'Колдун',
        ClassKind.monk => 'Монах',
        ClassKind.paladin => 'Паладин',
        ClassKind.thief => 'Плут',
        ClassKind.ranger => 'Следопыт',
        ClassKind.sorcerer => 'Чародей',
      };

  int get startSkillCount => switch (this) {
        ClassKind.bard => 3,
        ClassKind.barbarian => 2,
        ClassKind.wizard => 2,
        _ => throw UnimplementedError(),
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
        ClassKind.wizard => [
            Skill.history,
            Skill.magic,
            Skill.medicine,
            Skill.insight,
            Skill.investigation,
            Skill.religion,
          ],
        _ => throw UnimplementedError(),
      };

  int knownSpellsCount(int level, int Function(StatKind) statBonus) => switch (this) {
        ClassKind.bard => 3 + level,
        ClassKind.barbarian => 0,
        ClassKind.wizard => max(1, level + statBonus(StatKind.intelligence)),
        _ => throw UnimplementedError(),
      };

  int knownConspiracies(int level) => switch (this) {
        ClassKind.bard => {
            1: 2,
            4: 3,
            10: 4,
          }._getValue(level),
        ClassKind.barbarian => 0,
        ClassKind.wizard => {
            1: 3,
            4: 4,
            10: 5,
          }._getValue(level),
        _ => throw UnimplementedError(),
      };
}

extension on Map<int, int> {
  int _getValue(int level) {
    final key = keys.lastWhere(
      (e) => e <= level,
      orElse: () => 0,
    );
    return this[key] ?? 0;
  }
}
