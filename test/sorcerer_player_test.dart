import 'package:dnd_character_list/data/ttg/ttg_class_mapper.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/sorcerer.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/class_option.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/ttg_fixtures.dart';

Spell _spell(String slug, SpellSlot slot) => Spell(
      link: '/spells/$slug',
      name: slug,
      nameEn: slug,
      slot: slot,
      school: 'воплощение',
      isConcentration: false,
      isRitual: false,
      components: const [SpellComponent.verbal],
      allowedSpecializations: const [],
    );

const _sage = Background(
  id: 1,
  link: '/backgrounds/sage',
  name: 'Мудрец',
  nameEn: 'Sage',
  descriptionHtml: '',
  skills: [Skill.history, Skill.arcana],
  tools: [],
  languagesCount: 2,
  equipment: [],
  gold: 10,
  featureName: null,
  featureHtml: null,
  tables: [],
);

Player _player(Sorcerer sorcerer) => Player(
      knownLanguages: const [Language.sylvan],
      personality: Personality(
        eyesColor: 'зелёные',
        hairColor: 'серебристые',
        skinColor: 'светлая',
        name: 'Ирис',
        age: 25,
        height: 175,
        weight: 60,
        story: '',
        traits: const {},
      ),
      race: Race.halfElf,
      strength: 8,
      dexterity: 14,
      constitution: 14,
      intelligence: 10,
      wisdom: 12,
      // +2 от полуэльфа.
      charisma: 15,
      classes: [sorcerer],
      chosenSkills: const [Skill.deception, Skill.persuasion],
      armor: null,
      shield: null,
      mainWeapon: null,
      secondWeapon: null,
      mainRangeWeapon: null,
      secondRangeWeapon: null,
      inventory: Inventory(items: [], balance: Balance.fromGold(10)),
      background: _sage,
      raceSpells: const {},
      toolProficiencies: const [],
    );

Sorcerer _sorcerer({String? originId, DragonAncestor? ancestor, List<Spell> originSpells = const []}) => Sorcerer(
      level: 1,
      isMain: true,
      chosenSpells: [_spell('fire_bolt', SpellSlot.conspiracy), _spell('magic_missile', SpellSlot.level1)],
      originSpells: originSpells,
      features: const [],
      originId: originId,
      originName: originId == null ? null : 'Происхождение',
      dragonAncestor: ancestor,
    );

void main() {
  test('base sorcerer sheet', () {
    final player = _player(_sorcerer(originId: 'wild_magic'));

    // 6 + модификатор Телосложения.
    expect(player.maxHits, 6 + 2);
    expect(player.protection, 10 + 2);
    expect(player.saveThrows.where((e) => e.isChosen).map((e) => e.origin), [StatKind.constitution, StatKind.charisma]);
    expect(player.spellKinds.single.statKind, StatKind.charisma);
    expect(player.spellCells[SpellSlot.level1], 2);
    expect(player.isProficientWith(daggerFixture), isTrue);
    expect(player.isProficientWith(rapierFixture), isFalse);
    expect(player.armorProficiencies, isEmpty);
    expect(player.classes.single.name, 'Чародей (Происхождение)');
  });

  test('draconic bloodline: hit points, armor class and language', () {
    final sorcerer = _sorcerer(originId: Sorcerer.draconicBloodline, ancestor: DragonAncestor.red);
    final player = _player(sorcerer);

    expect(player.maxHits, 6 + 2 + 1);
    expect(player.armorClass.parts.map((e) => e.$1), ['Драконья чешуя', 'Ловкость']);
    expect(player.protection, 13 + 2);
    expect(player.knownLanguages, containsAll([Language.draconic, Language.common, Language.elvish]));
    expect(sorcerer.dragonAncestor!.damageType, ElementalType.fire);

    // С доспехом «Драконья устойчивость» не действует.
    expect(player.equipArmor(leatherFixture).protection, 11 + 2);
  });

  test('origin spells are known but stored apart from chosen spells', () {
    final shield = _spell('shield', SpellSlot.level1);
    final sorcerer = _sorcerer(originId: Sorcerer.lunarSorcery, originSpells: [shield]);
    final player = _player(sorcerer);

    expect(player.spells.values.single.map((e) => e.link),
        ['/spells/fire_bolt', '/spells/magic_missile', '/spells/shield']);
    expect(sorcerer.chosenSpells, hasLength(2));
  });

  test('saves and restores sorcerer', () {
    final player = _player(_sorcerer(originId: Sorcerer.draconicBloodline, ancestor: DragonAncestor.gold));

    final restored = Player.fromJson(player.toJson());
    final sorcerer = restored.classes.single as Sorcerer;

    expect(sorcerer.dragonAncestor, DragonAncestor.gold);
    expect(sorcerer.originId, Sorcerer.draconicBloodline);
    expect(sorcerer.chosenSpells.map((e) => e.link), ['/spells/fire_bolt', '/spells/magic_missile']);
    expect(restored.maxHits, player.maxHits);
  });

  test('level 4 sorcerer: metamagic, ability score improvement and sorcery points', () {
    const careful = Metamagic(
      link: '/options/careful_spell',
      name: 'Аккуратное заклинание',
      source: 'Книга игрока',
      descriptionHtml: '<p>Аккуратно.</p>',
    );
    const twinned = Metamagic(
      link: '/options/twinned_spell',
      name: 'Удвоенное заклинание',
      source: 'Книга игрока',
      descriptionHtml: '<p>Дважды.</p>',
    );
    final sorcerer = _sorcerer().copyWith(
      level: 4,
      metamagic: [careful, twinned],
      improvements: [
        const AbilityScoreImprovement(level: 4, stats: {StatKind.charisma: 2}),
      ],
      sorceryPoints: 4,
    );
    final player = _player(sorcerer);

    expect(player.charisma.value, 15 + 2 + 2);
    expect(player.maxExtras, {ClassExtras.sorceryPoints: 4});
    expect(
      sorcerer.abilities.map((e) => e.name),
      ['ВАРИАНТ МЕТАМАГИИ: АККУРАТНОЕ ЗАКЛИНАНИЕ', 'ВАРИАНТ МЕТАМАГИИ: УДВОЕННОЕ ЗАКЛИНАНИЕ'],
    );
    expect(sorcerer.abilities.first.isHtml, isTrue);
    // До 2 уровня единиц чародейства нет.
    expect(_player(_sorcerer()).maxExtras, isEmpty);

    final restored = Player.fromJson(player.toJson()).classes.single as Sorcerer;
    expect(restored.metamagic, [careful, twinned]);
    expect(restored.metamagic.first.descriptionHtml, '<p>Аккуратно.</p>');
    expect(restored.improvements.single.stats, {StatKind.charisma: 2});
    expect(restored.sorceryPoints, 4);
  });

  test('spell slots are spent and restored by level', () {
    final player = _player(_sorcerer().copyWith(level: 3));

    expect(player.spellCells, {SpellSlot.level1: 4, SpellSlot.level2: 2});
    expect(player.currentSpellSlots, player.spellCells);

    final spent =
        player.spendSpellSlot(SpellSlot.level2).spendSpellSlot(SpellSlot.level2).spendSpellSlot(SpellSlot.level2);
    expect(spent.currentSpellSlots[SpellSlot.level2], 0);
    expect(spent.availableSpellSlots(SpellSlot.level1), [SpellSlot.level1]);
    expect(spent.availableSpellSlots(SpellSlot.level2), isEmpty);

    // Восстановить можно только до максимума по таблице.
    final restored =
        spent.restoreSpellSlot(SpellSlot.level2).restoreSpellSlot(SpellSlot.level2).restoreSpellSlot(SpellSlot.level2);
    expect(restored.currentSpellSlots[SpellSlot.level2], 2);
    expect(spent.takeDamage(3).longRest().currentSpellSlots, player.spellCells);

    // Отдых нужен, только когда что-то ниже максимума; созданные сверх максимума ячейки не в счёт.
    expect(player.canRestOnLongRest, isFalse);
    expect(spent.canRestOnLongRest, isTrue);
    expect(player.takeDamage(1).canRestOnLongRest, isTrue);
    expect(spent.longRest().canRestOnLongRest, isFalse);
  });

  test('font of magic converts spell slots and sorcery points', () {
    final player = _player(_sorcerer().copyWith(level: 3, sorceryPoints: 3));
    expect(player.currentSorceryPoints, 3);

    // Единиц не может стать больше максимума.
    expect(player.canConvertToSorceryPoints(SpellSlot.level1), isFalse);

    final created = player.createSpellSlot(SpellSlot.level1);
    expect(created.currentSorceryPoints, 1);
    expect(created.currentSpellSlots[SpellSlot.level1], 5);
    expect(created.canCreateSpellSlot(SpellSlot.level1), isFalse);

    final converted = created.convertSpellSlotToSorceryPoints(SpellSlot.level2);
    expect(converted.currentSorceryPoints, 3);
    expect(converted.currentSpellSlots[SpellSlot.level2], 1);

    final afterMetamagic = converted.spendSorceryPoints(2);
    expect(afterMetamagic.currentSorceryPoints, 1);
    expect(afterMetamagic.spendSorceryPoints(2).currentSorceryPoints, 1);

    // После продолжительного отдыха созданные ячейки исчезают, единицы восстанавливаются.
    // Ячейка сверх максимума отдыха не требует, а потраченные единицы — требуют.
    expect(created.canRestOnLongRest, isTrue);
    final rested = afterMetamagic.longRest();
    expect(rested.currentSpellSlots, player.spellCells);
    expect(rested.currentSorceryPoints, 3);
    expect(Sorcerer.spellSlotCost.keys.last, SpellSlot.level5);
  });

  group('origin spells', () {
    final info = TtgClassMapper().map(
      ttgFixture('class_sorcerer'),
      subclasses: [ttgFixture('class_sorcerer_draconic')],
    );
    final aberrant = ClassInfo.fromJson({
      ...info.toJson(),
      'subclasses': [
        const Subclass(
          id: 'aberrant_mind',
          name: 'Аберрантный разум',
          source: null,
          descriptionHtml: '',
          features: [],
          spells: {
            1: ['/spells/arms_of_hadar', '/spells/mind_sliver'],
            3: ['/spells/calm_emotions'],
          },
        ).toJson(),
      ],
    });

    test('come from the subclass spell table', () {
      expect(Sorcerer.originSpellLinks(aberrant, 1, originId: 'aberrant_mind'), [
        '/spells/arms_of_hadar',
        '/spells/mind_sliver',
      ]);
      expect(Sorcerer.originSpellLinks(aberrant, 3, originId: 'aberrant_mind'), hasLength(3));
      expect(Sorcerer.originSpellLinks(info, 1, originId: Sorcerer.draconicBloodline), isEmpty);
    });

    test('come from origin mechanics', () {
      expect(
        Sorcerer.originSpellLinks(info, 1, originId: Sorcerer.divineSoul, divineAffinity: DivineAffinity.law),
        ['/spells/bless'],
      );
      expect(Sorcerer.originSpellLinks(info, 1, originId: Sorcerer.lunarSorcery), contains('/spells/sacred_flame'));
      expect(Sorcerer.originSpellLinks(info, 1, originId: Sorcerer.lunarSorcery), hasLength(4));
      expect(Sorcerer.originSpellLinks(info, 3, originId: Sorcerer.lunarSorcery), hasLength(7));
      expect(Sorcerer.originSpellLinks(info, 9, originId: Sorcerer.lunarSorcery), hasLength(16));
      expect(Sorcerer.originSpellLinks(info, 2, originId: Sorcerer.shadowMagic), isEmpty);
      expect(Sorcerer.originSpellLinks(info, 3, originId: Sorcerer.shadowMagic), ['/spells/darkness']);
      expect(Sorcerer.spellListsFor(Sorcerer.divineSoul), [ClassKind.sorcerer, ClassKind.cliric]);
    });

    test('features of level 1 include origin features', () {
      final features = Sorcerer.featuresAt(info, 1, originId: Sorcerer.draconicBloodline).map((e) => e.name);
      expect(features, ['ИСПОЛЬЗОВАНИЕ ЗАКЛИНАНИЙ', 'ДРАКОНИЙ ПРЕДОК', 'ДРАКОНЬЯ УСТОЙЧИВОСТЬ']);
    });
  });
}
