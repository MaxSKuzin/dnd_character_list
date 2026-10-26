import 'dart:math';

import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/equipment_kits.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/start_equipment.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/tools/musical_instruments.dart';
import 'package:dnd_character_list/domain/models/tools/thieves_tools.dart';
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
  sorcerer;

  StartEquipment get equipment => switch (this) {
        ClassKind.bard => StartEquipment(
            [
              EquipmentToSelect(
                quantity: 1,
                items: [
                  Weapon.rapier(),
                  Weapon.longSword(),
                  ...availableWeapons.where(
                    (element) => element.kind == WeaponKind.simpleMelee || element.kind == WeaponKind.simpleRanged,
                  ),
                ].map((e) => InventoryItem(quantity: 1, item: e)).toList(),
              ),
              EquipmentToSelect(
                quantity: 1,
                items: musicalInstruments.map((e) => InventoryItem(quantity: 1, item: e)).toList(),
              ),
              EquipmentToSelect(
                quantity: 2,
                items: [
                  Armor.leather(),
                  Weapon.dagger(),
                ].map((e) => InventoryItem(quantity: 1, item: e)).toList(),
              ),
            ],
            [
              artistSet,
              diplomaSet,
            ],
          ),
        ClassKind.paladin => StartEquipment(
            [
              EquipmentToSelect(
                quantity: 2,
                items: [
                  ...availableWeapons.where(
                    (element) => element.kind == WeaponKind.martialMelee || element.kind == WeaponKind.martialRanged,
                  ),
                  Shield.regular(),
                ]
                    .map(
                      (e) => InventoryItem(quantity: 1, item: e),
                    )
                    .toList(),
              ),
              EquipmentToSelect(
                quantity: 1,
                items: [
                  InventoryItem(
                    quantity: 5,
                    item: Weapon.throwingSpear(),
                  ),
                  ...availableWeapons
                      .where(
                        (element) => element.kind == WeaponKind.simpleMelee && element != Weapon.throwingSpear(),
                      )
                      .map(
                        (e) => InventoryItem(quantity: 1, item: e),
                      ),
                ],
              ),
              EquipmentToSelect(
                quantity: 2,
                items: [
                  InventoryItem(
                    quantity: 1,
                    item: Armor.chainmail(),
                  ),
                  InventoryItem(
                    quantity: 1,
                    item: 'Священный символ',
                  ),
                ],
              ),
            ],
            [
              travellersSet,
              priestSet,
            ],
          ),
        ClassKind.thief => StartEquipment(
            [
              EquipmentToSelect(
                quantity: 1,
                items: [
                  InventoryItem(
                    quantity: 1,
                    item: Weapon.rapier(),
                  ),
                  InventoryItem(
                    quantity: 1,
                    item: Weapon.shortSword(),
                  ),
                ],
              ),
              EquipmentToSelect(
                quantity: 2,
                items: [
                  InventoryItem(
                    quantity: 1,
                    item: Weapon.shortBow(),
                  ),
                  InventoryItem(
                    quantity: 20,
                    item: 'Стрела',
                  ),
                  InventoryItem(
                    quantity: 1,
                    item: Weapon.shortSword(),
                  ),
                ],
              ),
              EquipmentToSelect(
                quantity: 3,
                items: [
                  InventoryItem(
                    quantity: 1,
                    item: Armor.leather(),
                  ),
                  InventoryItem(quantity: 1, item: thievesTools.first),
                  InventoryItem(
                    quantity: 2,
                    item: Weapon.dagger(),
                  ),
                ],
              ),
            ],
            [
              dungeonExplorerSet,
              bulgartSet,
              travellersSet,
            ],
          ),
        _ => throw UnimplementedError(),
      };

  /// Страница класса на dnd.su. Классы без ссылки пока описаны только в коде.
  String? get dndSuLink => switch (this) {
        ClassKind.bard => '/class/88-bard/',
        _ => null,
      };

  int get startSkillCount => switch (this) {
        ClassKind.bard => 3,
        ClassKind.barbarian => 2,
        ClassKind.wizard => 2,
        ClassKind.paladin => 2,
        ClassKind.thief => 4,
        _ => throw UnimplementedError(),
      };

  List<Skill> get availableSkills => switch (this) {
        ClassKind.bard => Skill.values,
        ClassKind.barbarian => [
            Skill.athletics,
            Skill.intimidation,
            Skill.nature,
            Skill.perception,
            Skill.survival,
            Skill.animalHandling,
          ],
        ClassKind.wizard => [
            Skill.history,
            Skill.arcana,
            Skill.medicine,
            Skill.insight,
            Skill.investigation,
            Skill.religion,
          ],
        ClassKind.paladin => [
            Skill.athletics,
            Skill.intimidation,
            Skill.medicine,
            Skill.insight,
            Skill.religion,
            Skill.persuasion,
          ],
        ClassKind.thief => [
            Skill.acrobatics,
            Skill.athletics,
            Skill.perception,
            Skill.performance,
            Skill.intimidation,
            Skill.sleightOfHand,
            Skill.deception,
            Skill.insight,
            Skill.investigation,
            Skill.stealth,
            Skill.persuasion,
          ],
        _ => throw UnimplementedError(),
      };

  int knownSpellsCount(int level, int Function(StatKind) statBonus) => switch (this) {
        ClassKind.bard => 3 + level,
        ClassKind.barbarian => 0,
        ClassKind.wizard => max(1, level + statBonus(StatKind.intelligence)),
        ClassKind.paladin => level > 1 ? max(1, level ~/ 2 + statBonus(StatKind.charisma)) : 0,
        ClassKind.thief => 0,
        _ => throw UnimplementedError(),
      };

  int knownConspiracies(int level) => switch (this) {
        ClassKind.bard => {
            1: 2,
            4: 3,
            10: 4,
          }._getValue(level),
        ClassKind.barbarian => 0,
        ClassKind.paladin => 0,
        ClassKind.wizard => {
            1: 3,
            4: 4,
            10: 5,
          }._getValue(level),
        ClassKind.thief => 0,
        _ => throw UnimplementedError(),
      };

  double get magicLevelMultiplier => switch (this) {
        ClassKind.bard => 1,
        ClassKind.barbarian => 0,
        ClassKind.wizard => 1,
        ClassKind.paladin => 0.5,
        ClassKind.thief => 0,
        _ => throw UnimplementedError(),
      };

  int getDoubledSkillPoints(int level) => switch (this) {
        ClassKind.bard => level == 3 || level == 10 ? 2 : 0,
        ClassKind.thief => level == 1 || level == 6 ? 2 : 0,
        _ => 0,
      };

  int getStatsBonus(int level) => level % 4 == 0 ? 2 : 0;
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
