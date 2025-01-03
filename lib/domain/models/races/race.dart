import 'package:dnd_character_list/domain/models/item_with_name.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/conspiracies/thaumaturgy.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

enum Race with ItemWithName {
  tiefling,
  tieflingFaerun,
  halfElf;

  @override
  String get name => switch (this) {
        tiefling => 'Тифлинг',
        tieflingFaerun => 'Тифлинг Фаэруна',
        halfElf => 'Полуэльф',
      };

  List<Language> get knownLanguages => switch (this) {
        tiefling => [Language.common, Language.infernal],
        tieflingFaerun => [Language.common, Language.infernal],
        halfElf => [Language.common, Language.elvish],
      };

  int get additionalLanguagesCount => switch (this) {
        tiefling => 0,
        tieflingFaerun => 0,
        halfElf => 1,
      };

  int get speed => switch (this) {
        tiefling => 30,
        tieflingFaerun => 30,
        halfElf => 30,
      };

  Map<StatKind, int> get statBonuses => switch (this) {
        tiefling => {
            StatKind.charisma: 2,
            StatKind.intelligence: 1,
          },
        tieflingFaerun => {
            StatKind.dexterity: 2,
            StatKind.intelligence: 1,
          },
        halfElf => {
            StatKind.charisma: 2,
          },
      };

  int get additionalStatsCount => switch (this) {
        tiefling => 0,
        tieflingFaerun => 0,
        halfElf => 2,
      };

  List<Peculiarity> get peculiarities => switch (this) {
        tiefling => [
            const Peculiarity(
              name: 'Адское сопротивление',
              description: 'Вы имеете сопротивление к урону от огня',
            ),
            const Peculiarity(
              name: 'Темное зрение',
              description: 'Вы видите в темноте на 60 футов',
            ),
          ],
        tieflingFaerun => [
            const Peculiarity(
              name: 'Адское сопротивление',
              description: 'Вы имеете сопротивление к урону от огня',
            ),
            const Peculiarity(
              name: 'Темное зрение',
              description: 'Вы видите в темноте на 60 футов',
            ),
            const Peculiarity(
              name: 'Крылатый',
              description: 'У персонажа из лопаток вырастают перепончатые крылья. '
                  'Персонаж получает скоростью полёта 30 футов, если не носит тяжёлый доспех.',
            ),
          ],
        halfElf => [
            const Peculiarity(
              name: 'Темное зрение',
              description:
                  'Благодаря вашей эльфийской крови, вы обладаете превосходным зрением в темноте и при тусклом освещении. На расстоянии в 60 футов вы при тусклом освещении можете видеть так, как будто это яркое освещение, и в темноте так, как будто это тусклое освещение. В темноте вы не можете различать цвета, только оттенки серого.',
            ),
            const Peculiarity(
              name: 'Наследие фей',
              description:
                  'Вы совершаете с преимуществом спасброски от состояния «очарованный», и вас невозможно магически усыпить.',
            ),
          ],
      };

  Map<SpellSlot, Spell> spellForLevel(int level) => switch (this) {
        tiefling => {
            1: {
              SpellSlot.conspiracy: Thaumaturgy(),
            },
          },
        tieflingFaerun => {
            1: {
              SpellSlot.conspiracy: Thaumaturgy(),
            },
          },
        halfElf => <int, Map<SpellSlot, Thaumaturgy>>{},
      }
          ._getSpellsMap(level);

  int get startSkillCount => switch (this) {
        halfElf => 2,
        _ => 0,
      };

  List<Skill> get availableSkills => switch (this) {
        halfElf => Skill.values,
        _ => [],
      };

  List<StatKind> get forbiddenStats => switch (this) {
        halfElf => [StatKind.charisma],
        _ => [],
      };
}

extension on Map<int, List<Spell>> {
  List<Spell> _getSpells(int level) {
    final spells = entries.fold(
      <Spell>[],
      (previousValue, element) {
        if (element.key <= level) {
          return [...previousValue, ...element.value];
        }
        return previousValue;
      },
    );
    return spells;
  }
}

extension on Map<int, Map<SpellSlot, Spell>> {
  Map<SpellSlot, Spell> _getSpellsMap(int level) {
    final spells = entries.fold(
      <MapEntry<SpellSlot, Spell>>[],
      (previousValue, element) {
        if (element.key <= level) {
          return [...previousValue, ...element.value.entries];
        }
        return previousValue;
      },
    );
    return Map.fromEntries(spells);
  }
}
