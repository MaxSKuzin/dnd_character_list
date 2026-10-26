import 'package:dnd_character_list/data/ttg/ttg_class_mapper.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/sorcerer.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/language.dart';
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

    expect(player.spells.values.single.map((e) => e.link), ['/spells/fire_bolt', '/spells/magic_missile', '/spells/shield']);
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
      expect(Sorcerer.spellListsFor(Sorcerer.divineSoul), [ClassKind.sorcerer, ClassKind.cliric]);
    });

    test('features of level 1 include origin features', () {
      final features = Sorcerer.featuresAt(info, 1, originId: Sorcerer.draconicBloodline).map((e) => e.name);
      expect(features, ['ИСПОЛЬЗОВАНИЕ ЗАКЛИНАНИЙ', 'ДРАКОНИЙ ПРЕДОК', 'ДРАКОНЬЯ УСТОЙЧИВОСТЬ']);
    });
  });
}
