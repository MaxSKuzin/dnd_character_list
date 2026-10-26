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

  /// Страница класса на dnd.su. Классы без ссылки пока не поддерживаются.
  String? get dndSuLink => switch (this) {
        ClassKind.bard => '/class/88-bard/',
        ClassKind.barbarian => '/class/87-barbarian/',
        ClassKind.paladin => '/class/94-paladin/',
        ClassKind.thief => '/class/99-rogue/',
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
