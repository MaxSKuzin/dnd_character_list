import 'package:dnd_character_list/data/ttg/ttg_class_mapper.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/ranger.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/ttg_fixtures.dart';

Spell _spell(String slug, SpellSlot slot) => Spell(
      link: '/spells/$slug',
      name: slug,
      nameEn: slug,
      slot: slot,
      school: 'прорицание',
      isConcentration: false,
      isRitual: false,
      components: const [SpellComponent.verbal],
      allowedSpecializations: const [],
    );

Ranger _ranger({int level = 1, Set<String> tce = const {}, List<Skill> expertise = const []}) => Ranger(
      level: level,
      isMain: true,
      features: const [],
      tceFeatures: tce,
      favoredEnemies: tce.contains(Ranger.favoredFoe) ? const [] : const ['Нежить'],
      favoredTerrains: tce.contains(Ranger.deftExplorer) ? const [] : const ['Леса'],
      languages: const [Language.abyssal],
      expertise: expertise,
      fightingStyle: level >= 2 ? FightingStyle.archery : null,
    );

void main() {
  final info = TtgClassMapper().map(ttgFixture('class_ranger'), subclasses: [ttgFixture('class_ranger_gloom_stalker')]);

  group('class table', () {
    test('reads proficiencies, spells and archetype level', () {
      expect(info.link, '/classes/ranger');
      expect(info.savingThrows, [StatKind.strength, StatKind.dexterity]);
      expect(info.skillsCount, 3);
      expect(info.subclassLevel, 3);
      expect(info.level(1).spellsKnown, isNull);
      expect(info.level(2).spellsKnown, 2);
      expect(info.level(5).maxSpellLevel, 2);

      // «Длинный лук и колчан с 20 стрелами» — три предмета.
      final bow = info.startingEquipment.last.options.single.items;
      expect(
          bow.map((e) => (e.id, e.quantity)), [('/weapons/longbow', 1), ('/items/quiver', 1), ('/items/arrows', 20)]);
      // «Два простых рукопашных оружия» — выбор из категории.
      expect(info.startingEquipment[1].options.last.items.single.isChoice, isTrue);
    });

    test('takes either the PHB feature or its TCE replacement', () {
      expect(Ranger.featuresAt(info, 1).map((e) => e.name), ['ИЗБРАННЫЙ ВРАГ', 'ИССЛЕДОВАТЕЛЬ ПРИРОДЫ']);
      expect(
        Ranger.featuresAt(info, 1, tceFeatures: {Ranger.favoredFoe, Ranger.deftExplorer}).map((e) => e.name),
        ['ПРЕДПОЧТИТЕЛЬНЫЙ ПРОТИВНИК', 'ИСКУСНЫЙ ИССЛЕДОВАТЕЛЬ', 'ХИТРЕЦ'],
      );
      expect(Ranger.featuresAt(info, 6).map((e) => e.name), isNot(contains('БРОДЯГА')));
      expect(Ranger.featuresAt(info, 6, tceFeatures: {Ranger.deftExplorer}).map((e) => e.name), contains('БРОДЯГА'));
      expect(
          Ranger.featuresAt(info, 3, tceFeatures: {Ranger.primalAwareness}).map((e) => e.name), ['ИЗНАЧАЛЬНОЕ ЧУТЬЕ']);
      expect(Ranger.featuresAt(info, 3, archetypeId: 'gloom_stalker').map((e) => e.name),
          ['ПЕРВОЗДАННАЯ ОСВЕДОМЛЁННОСТЬ', 'УГРОЗА ИЗ ЗАСАДЫ', 'ТЕНЕВОЙ ВЗОР']);
    });

    test('granted spells: archetype table and primal awareness', () {
      expect(Ranger.grantedSpellLinks(info, 5, archetypeId: 'gloom_stalker', primal: false),
          ['/spells/disguise_self', '/spells/rope_trick']);
      expect(Ranger.grantedSpellLinks(info, 5, primal: true), ['/spells/speak_with_animals', '/spells/beast_sense']);
    });
  });

  test('half casters use their own table, multiclass rounds down', () {
    MapEntry<double, int> ranger(int level) => MapEntry(ClassKind.ranger.magicLevelMultiplier, level);
    MapEntry<double, int> wizard(int level) => MapEntry(ClassKind.bard.magicLevelMultiplier, level);
    expect([1, 2, 3, 5, 9, 20].map((e) => SpellSlot.casterLevel([ranger(e)])), [0, 1, 2, 3, 5, 10]);
    expect(SpellSlot.casterLevel([ranger(3), wizard(2)]), 1 + 2);
    // Следопыт 3 уровня: 3 ячейки 1 уровня, как в таблице класса.
    expect(SpellSlot.getSpellCells({ClassKind.ranger: 3}), {SpellSlot.level1: 3});
    expect(SpellSlot.getSpellCells({ClassKind.paladin: 1}), isEmpty);
  });

  test('base ranger sheet', () {
    final player = playerFixture(spec: _ranger());

    expect(player.maxHits, 10 + 2);
    expect(player.saveThrows.where((e) => e.isChosen).map((e) => e.origin), [StatKind.strength, StatKind.dexterity]);
    expect(player.isProficientWith(longswordFixture), isTrue);
    expect(player.equipArmor(scaleFixture).isArmorProficient, isTrue);
    expect(player.equipArmor(chainmailFixture).isArmorProficient, isFalse);
    expect(player.spellCells, isEmpty);
    expect(player.knownLanguages, contains(Language.abyssal));
    expect(player.maxExtras, isEmpty);
  });

  test('spellcasting, extra attack and fighting style', () {
    final ranger = Ranger(
      level: 5,
      isMain: true,
      features: const [],
      fightingStyle: FightingStyle.druidicWarrior,
      chosenSpells: [_spell('hunters_mark', SpellSlot.level1)],
      druidicCantrips: [_spell('guidance', SpellSlot.conspiracy)],
      grantedSpells: [_spell('speak_with_animals', SpellSlot.level1), _spell('hunters_mark', SpellSlot.level1)],
    );
    final player = playerFixture(spec: ranger);

    expect(player.spellCells, {SpellSlot.level1: 4, SpellSlot.level2: 2});
    expect(player.spellKinds.single.statKind, StatKind.wisdom);
    expect(player.attacksPerAction, 2);
    expect(ranger.knownSpells.map((e) => e.link),
        ['/spells/hunters_mark', '/spells/guidance', '/spells/speak_with_animals']);
  });

  test('TCE features: favored foe, canny, roving and tireless', () {
    final player = playerFixture(
      spec: _ranger(level: 10, tce: {Ranger.favoredFoe, Ranger.deftExplorer}, expertise: [Skill.stealth]),
    );
    final ranger = player.classes.single as Ranger;

    // Бонус мастерства +4 на 10 уровне.
    expect(player.maxExtras, {ClassExtras.favoredFoe: 4, ClassExtras.tireless: 4});
    expect(ranger.favoredFoeDice.name, 'к6');
    expect(player.speed, 30 + Ranger.rovingSpeed);
    // «Хитрец»: навык Скрытность с удвоенным бонусом мастерства (Ловкость +3).
    expect(Skill.stealth.getBonus(player.copyWith(chosenSkills: [Skill.stealth])), 3 + 4 * 2);
    // «Неутомимый» и «Предпочтительный противник» — только продолжительным отдыхом.
    final tired = player.useExtra(ClassExtras.favoredFoe).useExtra(ClassExtras.tireless);
    expect(tired.shortRest(0).currentExtras, tired.currentExtras);
    expect(tired.longRest().currentExtras, player.maxExtras);
  });

  test('saves and restores ranger', () {
    final player = playerFixture(spec: _ranger(level: 2, tce: {Ranger.favoredFoe}));
    final restored = Player.fromJson(player.toJson()).classes.single as Ranger;

    expect(restored.tceFeatures, {Ranger.favoredFoe});
    expect(restored.favoredTerrains, ['Леса']);
    expect(restored.languages, [Language.abyssal]);
    expect(restored.fightingStyle, FightingStyle.archery);
    expect(restored.name, 'Следопыт');
  });

  test('two humanoid races as favored enemy', () {
    final enemies = ['Нежить', Ranger.humanoidsEnemy('орки', 'гноллы')];

    expect(enemies.last, 'Гуманоиды: орки и гноллы');
    expect(Ranger.chosenHumanoids(enemies), ['орки', 'гноллы']);
    expect(Ranger.chosenHumanoids(['Нежить']), isEmpty);
    expect(Ranger.enemyTypes, contains(Ranger.twoHumanoidRaces));
  });

  test('fighting style feature shows the chosen style', () {
    final ranger = Ranger(
      level: 2,
      isMain: true,
      features: Ranger.featuresAt(info, 2),
      fightingStyle: FightingStyle.druidicWarrior,
    );

    expect(ranger.abilities.map((e) => e.name), contains('БОЕВОЙ СТИЛЬ: ВОИН-ДРУИД'));
    expect(ranger.abilities.where((e) => e.name.startsWith('БОЕВОЙ СТИЛЬ')), hasLength(1));
  });
}
