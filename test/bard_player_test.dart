import 'dart:convert';

import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_replacement.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:flutter_test/flutter_test.dart';

const _entertainer = Background(
  id: 757,
  link: '/backgrounds/entertainer',
  name: 'Артист',
  nameEn: 'Entertainer',
  descriptionHtml: '<p>Вам нравится выступать на публике.</p>',
  skills: [Skill.acrobatics, Skill.performance],
  tools: [],
  languagesCount: 0,
  equipment: ['Костюм'],
  gold: 15,
  featureName: 'По многочисленным просьбам',
  featureHtml: '<p>Вы всегда можете найти место для выступления.</p>',
  tables: [],
);

Feat _feat(String slug, {List<StatKind> statIncrease = const []}) => Feat(
      id: slug.hashCode,
      link: '/feats/$slug',
      name: slug,
      nameEn: slug,
      requirementText: null,
      requirement: const FeatRequirement(),
      descriptionHtml: '<p>$slug</p>',
      statIncreaseOptions: statIncrease,
    );

Player _player(Bard bard) => Player(
      knownLanguages: const [Language.elvish],
      personality: Personality(
        eyesColor: 'карие',
        hairColor: 'чёрные',
        skinColor: 'красная',
        name: 'Лира',
        age: 20,
        height: 170,
        weight: 60,
        story: 'Бродячий музыкант',
        traits: const {
          'Черта характера': 'Для любой ситуации я найду подходящий рассказ.',
        },
      ),
      race: Race.tiefling,
      strength: 8,
      dexterity: 14,
      constitution: 12,
      intelligence: 10,
      wisdom: 13,
      charisma: 15,
      classes: [bard],
      chosenSkills: const [Skill.deception, Skill.persuasion, Skill.insight],
      armor: null,
      shield: null,
      mainWeapon: null,
      secondWeapon: null,
      mainRangeWeapon: null,
      secondRangeWeapon: null,
      inventory: Inventory(items: [], balance: Balance.fromGold(15)),
      background: _entertainer,
      raceSpells: const {},
      toolProficiencies: const ['Лютня', 'Флейта', 'Барабан'],
    );

Bard _bard({
  int level = 1,
  List<Skill> expertise = const [],
  List<AbilityScoreImprovement> improvements = const [],
  String? collegeId,
}) =>
    Bard(
      level: level,
      isMain: true,
      knownSpells: const [],
      features: const [Peculiarity(name: 'ВДОХНОВЕНИЕ БАРДА', description: '<p>к6</p>', isHtml: true)],
      inspirationDice: Dice.k6,
      expertise: expertise,
      improvements: improvements,
      collegeId: collegeId,
    );

void main() {
  test('proficient skills come from choices and background', () {
    final player = _player(_bard());

    expect(player.chosenSkills, containsAll([Skill.deception, Skill.performance, Skill.acrobatics]));
    // Харизма 15 + 2 от тифлинга = 17 (+3), бонус мастерства +2.
    expect(Skill.performance.getBonus(player), 5);
    // Без «Мастера на все руки» на 1 уровне навыки без владения получают только модификатор.
    expect(Skill.athletics.getBonus(player), -1);
    expect(player.initiative, 2);
  });

  test('jack of all trades and expertise from level 2-3', () {
    final player = _player(_bard(level: 3, expertise: const [Skill.performance]));

    expect(Skill.performance.getBonus(player), 3 + 2 * 2);
    expect(Skill.athletics.getBonus(player), -1 + 1, reason: 'Половина бонуса мастерства без владения');
    expect(player.initiative, 2 + 1);
    expect(player.passivePerception, 10 + 1 + 1);
  });

  test('ability score improvement and feats change the sheet', () {
    final player = _player(
      _bard(
        level: 8,
        improvements: [
          const AbilityScoreImprovement(level: 4, stats: {StatKind.charisma: 2}),
          AbilityScoreImprovement(
            level: 8,
            feat: ChosenFeat(
                feat: _feat('resilient', statIncrease: StatKind.values), increasedStat: StatKind.constitution),
          ),
        ],
      ),
    );

    expect(player.charisma.value, 15 + 2 + 2);
    expect(player.constitution.value, 13);
    expect(player.saveThrows.firstWhere((e) => e.origin == StatKind.constitution).isChosen, isTrue);
    expect(player.feats.single.feat.slug, 'resilient');
    expect(player.abilities.map((e) => e.name), contains('ЧЕРТА: RESILIENT'));
    expect(player.abilities.map((e) => e.name), contains('ПО МНОГОЧИСЛЕННЫМ ПРОСЬБАМ'));
  });

  test('feat effects', () {
    final plain = _player(_bard(level: 4));
    final player = _player(
      _bard(
        level: 4,
        improvements: [
          AbilityScoreImprovement(level: 4, feat: ChosenFeat(feat: _feat('tough'))),
          AbilityScoreImprovement(level: 4, feat: ChosenFeat(feat: _feat('alert'))),
          AbilityScoreImprovement(level: 4, feat: ChosenFeat(feat: _feat('mobile'))),
          AbilityScoreImprovement(level: 4, feat: ChosenFeat(feat: _feat('observant'))),
          AbilityScoreImprovement(
            level: 4,
            feat: ChosenFeat(feat: _feat('linguist'), languages: const [Language.draconic]),
          ),
          AbilityScoreImprovement(level: 4, feat: ChosenFeat(feat: _feat('moderately_armored'))),
        ],
      ),
    );

    expect(player.maxHits, plain.maxHits + 2 * 4);
    expect(player.initiative, plain.initiative + 5);
    expect(player.speed, 40);
    expect(player.passivePerception, plain.passivePerception + 5);
    expect(player.knownLanguages, contains(Language.draconic));
    expect(player.armorProficiencies, containsAll([ArmorProficiency.light, ArmorProficiency.medium]));
  });

  test('college proficiencies and inspiration uses', () {
    final valor = _player(_bard(level: 3, collegeId: Bard.valorCollege));

    expect(valor.armorProficiencies, {ArmorProficiency.light, ArmorProficiency.medium, ArmorProficiency.shields});
    expect(valor.maxExtras.values.single, 3, reason: 'Модификатор Харизмы, но не меньше одного');
  });

  test('player with bard survives json roundtrip', () {
    final player = _player(
      _bard(
        level: 4,
        expertise: const [Skill.performance],
        improvements: [
          AbilityScoreImprovement(
            level: 4,
            feat: ChosenFeat(
                feat: _feat('athlete', statIncrease: const [StatKind.strength, StatKind.dexterity]),
                increasedStat: StatKind.dexterity),
          ),
        ],
      ),
    );

    final restored = Player.fromJson(jsonDecode(jsonEncode(player.toJson())));

    expect(jsonEncode(restored.toJson()), jsonEncode(player.toJson()));
    expect(restored.dexterity.value, player.dexterity.value);
    expect(restored.background.name, 'Артист');
    expect(restored.personality.traits, player.personality.traits);
    expect(restored.toolProficiencies, player.toolProficiencies);
    expect((restored.classes.single as Bard).expertise, [Skill.performance]);
  });

  test('spell replacement keeps order and swaps only the replaced spell', () {
    Spell spell(String slug) => Spell(
          link: '/spells/$slug',
          name: slug,
          nameEn: slug,
          slot: SpellSlot.level1,
          school: 'очарование',
          isConcentration: false,
          isRitual: false,
          components: const [SpellComponent.verbal],
          allowedSpecializations: const [],
        );
    final replacement = SpellReplacement(replaced: spell('charm_person'), learned: spell('sleep'));

    expect(
      replacement.applyTo([spell('heroism'), spell('charm_person'), spell('thunderwave')]).map((e) => e.link),
      ['/spells/heroism', '/spells/sleep', '/spells/thunderwave'],
    );
  });

  test('college of swords fighting style is shown in abilities', () {
    final bard = Bard(
      level: 3,
      isMain: true,
      knownSpells: const [],
      features: const [Peculiarity(name: 'ВДОХНОВЕНИЕ БАРДА', description: '<p>Вдохновение.</p>', isHtml: true)],
      inspirationDice: Dice.k6,
      collegeId: Bard.swordsCollege,
      fightingStyle: FightingStyle.dueling,
    );

    expect(bard.abilities.map((e) => e.name), ['БОЕВОЙ СТИЛЬ: ДУЭЛЯНТ', 'ВДОХНОВЕНИЕ БАРДА']);
  });
}
