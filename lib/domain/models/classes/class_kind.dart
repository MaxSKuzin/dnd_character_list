import 'dart:math';

import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

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

  /// Класс на ttg.club. Классы без ссылки пока не поддерживаются.
  String? get ttgLink => switch (this) {
        ClassKind.bard => '/classes/bard',
        ClassKind.barbarian => '/classes/barbarian',
        ClassKind.paladin => '/classes/paladin',
        ClassKind.thief => '/classes/rogue',
        ClassKind.sorcerer => '/classes/sorcerer',
        _ => null,
      };

  /// Персонажа этого класса можно создать: для него есть описание на ttg.club и механики в коде.
  bool get canCreate => ttgLink != null;

  /// Повышение уровня реализовано.
  bool get canLevelUp => switch (this) {
        ClassKind.bard || ClassKind.barbarian || ClassKind.paladin || ClassKind.thief || ClassKind.sorcerer => true,
        _ => false,
      };

  /// Идентификатор класса в фильтре заклинаний ttg.club (`POST /filters/spells`).
  int? get ttgSpellsFilterId => switch (this) {
        ClassKind.bard => 1,
        ClassKind.wizard => 2,
        ClassKind.driud => 3,
        ClassKind.cliric => 4,
        ClassKind.witch => 5,
        ClassKind.paladin => 6,
        ClassKind.ranger => 7,
        ClassKind.sorcerer => 8,
        ClassKind.inventor => 14,
        _ => null,
      };

  int get startSkillCount => switch (this) {
        ClassKind.bard => 3,
        ClassKind.barbarian => 2,
        ClassKind.wizard => 2,
        ClassKind.paladin => 2,
        ClassKind.thief => 4,
        ClassKind.sorcerer => 2,
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
        ClassKind.sorcerer => [
            Skill.intimidation,
            Skill.arcana,
            Skill.deception,
            Skill.insight,
            Skill.religion,
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
        ClassKind.sorcerer => level < 11 ? level + 1 : min(15, 11 + (level - 9) ~/ 2),
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
        ClassKind.sorcerer => {
            1: 4,
            4: 5,
            10: 6,
          }._getValue(level),
        _ => throw UnimplementedError(),
      };

  double get magicLevelMultiplier => switch (this) {
        ClassKind.bard => 1,
        ClassKind.barbarian => 0,
        ClassKind.wizard => 1,
        ClassKind.paladin => 0.5,
        ClassKind.thief => 0,
        ClassKind.sorcerer => 1,
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
