import 'package:dnd_character_list/data/ttg/ttg_class_mapper.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/class_option.dart';
import 'package:dnd_character_list/domain/models/classes/fighter.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/ttg_fixtures.dart';

final _shortbow = Weapon(
  id: '/weapons/shortbow',
  name: 'Короткий лук',
  damage: Dice.k6,
  damageType: DamageType.pricking,
  kind: WeaponKind.simpleRanged,
  type: WeaponType.twoHanded,
  isAmmunition: true,
);

Fighter _fighter({
  int level = 1,
  List<FightingStyle> styles = const [FightingStyle.defence],
  String? archetypeId,
  int actionSurgeUses = 0,
  int indomitableUses = 0,
}) =>
    Fighter(
      level: level,
      isMain: true,
      features: const [],
      fightingStyles: styles,
      archetypeId: archetypeId,
      archetypeName: archetypeId == null ? null : 'Архетип',
      actionSurgeUses: actionSurgeUses,
      indomitableUses: indomitableUses,
    );

// Сила 8 (−1), Ловкость 16 (+3), Телосложение 14 (+2).
Player _player(Fighter fighter) => playerFixture(
      spec: fighter,
      items: [
        InventoryItem(quantity: 1, item: longswordFixture),
        InventoryItem(quantity: 2, item: daggerFixture),
        InventoryItem(quantity: 1, item: _shortbow),
        InventoryItem(quantity: 1, item: chainmailFixture),
        InventoryItem(quantity: 1, item: shieldFixture),
      ],
    );

void main() {
  group('class table', () {
    final info = TtgClassMapper().map(ttgFixture('class_fighter'), subclasses: [ttgFixture('class_fighter_champion')]);

    test('reads features, archetype level and uses', () {
      expect(info.link, '/classes/fighter');
      expect(info.savingThrows, [StatKind.strength, StatKind.constitution]);
      expect(info.skillsCount, 2);
      expect(info.subclassLevel, 3);
      expect(info.subclass(Fighter.champion)!.featuresAt(3).map((e) => e.name), ['Улучшенные критические попадания']);
      expect(Fighter.featuresAt(info, 1).map((e) => e.name), ['БОЕВОЙ СТИЛЬ', 'ВТОРОЕ ДЫХАНИЕ']);
      expect(info.level(6).hasFeature(Fighter.abilityScoreImprovement), isTrue);
      expect(info.feature(Fighter.martialVersatility)?.isOptional, isTrue);

      // «Воинское оружие и щит» или «два воинских оружия» — выбор из категории, а не строка в инвентаре.
      final weaponChoice = info.startingEquipment[1].options;
      expect(weaponChoice.first.items.map((e) => (e.text, e.isChoice, e.quantity)),
          [('воинское оружие', true, 1), ('щит', false, 1)]);
      expect(weaponChoice.last.items.map((e) => (e.text, e.isChoice, e.quantity)), [('два воинских оружия', true, 2)]);

      expect([1, 2, 16, 17].map((e) => Fighter.usesAt(info, Fighter.actionSurgeFeature, e)), [0, 1, 1, 2]);
      expect([8, 9, 13, 17].map((e) => Fighter.usesAt(info, Fighter.indomitableFeature, e)), [0, 1, 2, 3]);
    });
  });

  test('base fighter sheet', () {
    final player = _player(_fighter());

    expect(player.maxHits, 10 + 2);
    expect(player.saveThrows.where((e) => e.isChosen).map((e) => e.origin), [StatKind.strength, StatKind.constitution]);
    expect(player.isProficientWith(longswordFixture), isTrue);
    expect(player.equipArmor(chainmailFixture).isArmorProficient, isTrue);
    expect(player.maxExtras, {ClassExtras.secondWind: 1});
    expect(player.attacksPerAction, 1);
    // «Оборона»: +1 к КД в доспехе.
    expect(player.equipArmor(chainmailFixture).protection, 16 + 1);
  });

  test('extra attack and resources by level, short rest keeps indomitable spent', () {
    final player = _player(_fighter(level: 17, actionSurgeUses: 2, indomitableUses: 3));

    expect(player.attacksPerAction, 3);
    expect(_player(_fighter(level: 20)).attacksPerAction, 4);
    expect(player.maxExtras, {ClassExtras.secondWind: 1, ClassExtras.actionSurge: 2, ClassExtras.indomitable: 3});

    final tired =
        player.useExtra(ClassExtras.secondWind).useExtra(ClassExtras.actionSurge).useExtra(ClassExtras.indomitable);
    final rested = tired.shortRest(0);
    expect(rested.currentExtras[ClassExtras.secondWind], 1);
    expect(rested.currentExtras[ClassExtras.actionSurge], 2);
    expect(rested.currentExtras[ClassExtras.indomitable], 2);
    expect(rested.longRest().currentExtras[ClassExtras.indomitable], 3);
  });

  test('archery and thrown weapon fighting', () {
    final archer = _player(_fighter(styles: [FightingStyle.archery])).equipWeapon(_shortbow, WeaponSlot.mainRange);
    // Ловкость +3, мастерство +2, «Стрельба» +2.
    expect(archer.attacks.single.attackBonus, 7);
    expect(archer.attacks.single.damage, '1к6 + 3');

    final thrower = _player(_fighter(styles: [FightingStyle.thrownWeaponFighting]))
        .equipWeapon(daggerFixture, WeaponSlot.mainHand)
        .equipWeapon(daggerFixture, WeaponSlot.mainRange);
    expect(thrower.attackWith(daggerFixture, WeaponSlot.mainHand).damage, '1к4 + 3');
    expect(thrower.attackWith(daggerFixture, WeaponSlot.mainRange).damage, '1к4 + 5');
  });

  test('unarmed fighting adds unarmed strike', () {
    expect(_player(_fighter()).attacks, isEmpty);

    final player = _player(_fighter(styles: [FightingStyle.unarmedFighting]));
    // Сила −1: «Сражение голыми руками» использует Силу.
    expect(player.attacks.single.weapon, unarmedStrike);
    expect(player.attacks.single.damage, '1к8 − 1');
    expect(player.equipWeapon(longswordFixture, WeaponSlot.mainHand).attacks.last.damage, '1к6 − 1');
  });

  test('champion: remarkable athlete and two fighting styles', () {
    final player = _player(
      _fighter(level: 10, archetypeId: Fighter.champion, styles: [FightingStyle.defence, FightingStyle.dueling]),
    );

    // Бонус мастерства +4 на 10 уровне: половина, округлённая вверх, — +2 к проверкам Силы, Ловкости, Телосложения.
    expect(Skill.athletics.getBonus(player), -1 + 2);
    expect(Skill.stealth.getBonus(player), 3 + 2);
    expect(Skill.perception.getBonus(player), 0);
    expect(player.initiative, 3 + 2);
    expect(player.fightingStyles, [FightingStyle.defence, FightingStyle.dueling]);
    // Со щитом длинный меч в одной руке — «Дуэлянт» +2.
    expect(
      player.equipWeapon(longswordFixture, WeaponSlot.mainHand).equipShield(shieldFixture).attacks.single.damage,
      '1к8 + 1',
    );
    // До 7 уровня «Выдающегося атлета» нет.
    expect(Skill.athletics.getBonus(_player(_fighter(level: 6, archetypeId: Fighter.champion))), -1);
  });

  test('battle master superiority dice and save', () {
    final player =
        _player(_fighter(level: 7, archetypeId: Fighter.battleMaster, styles: [FightingStyle.superiorTechnique]));

    expect(player.maxExtras[ClassExtras.superiorityDice], 5 + 1);
    expect(Fighter.superiorityDieAt(7), Dice.k8);
    expect(Fighter.superiorityDieAt(10), Dice.k10);

    final restored = Player.fromJson(player.toJson()).classes.single as Fighter;
    expect(restored.fightingStyles, [FightingStyle.superiorTechnique]);
    expect(restored.archetypeId, Fighter.battleMaster);
    expect(restored.name, 'Воин (Архетип)');
  });

  test('maneuvers: count by level, abilities and superiority dice description', () {
    expect(
        [2, 3, 7, 10, 15].map((e) => Fighter.maneuversCount(level: e, archetypeId: Fighter.battleMaster, styles: [])),
        [0, 3, 5, 7, 9]);
    expect(Fighter.maneuversCount(level: 1, styles: [FightingStyle.superiorTechnique]), 1);
    expect(Fighter.maneuversCount(level: 3, archetypeId: Fighter.champion, styles: [FightingStyle.archery]), 0);

    const riposte = Maneuver(
      link: '/options/riposte',
      name: 'Ответный удар',
      source: 'Книга игрока',
      descriptionHtml: '<p>Реакцией атакуйте.</p>',
    );
    final fighter = _fighter(level: 3, archetypeId: Fighter.battleMaster).copyWith(maneuvers: [riposte]);

    expect(fighter.abilities.last.name, 'ПРИЁМ: ОТВЕТНЫЙ УДАР');
    expect(fighter.abilities.last.isHtml, isTrue);
    final description = fighter.classExtraDescription(ClassExtras.superiorityDice);
    expect(description, contains('к8'));
    expect(description, contains('Ответный удар'));

    final restored = Player.fromJson(_player(fighter).toJson()).classes.single as Fighter;
    expect(restored.maneuvers, [riposte]);
    expect(restored.maneuvers.single.descriptionHtml, '<p>Реакцией атакуйте.</p>');
  });

  test('fighting style features show the chosen style', () {
    final info = TtgClassMapper().map(ttgFixture('class_fighter'), subclasses: [ttgFixture('class_fighter_champion')]);
    final fighter = _fighter(styles: [FightingStyle.archery]).copyWith(features: Fighter.featuresAt(info, 1));

    final style = fighter.abilities.first;
    expect(style.name, 'БОЕВОЙ СТИЛЬ: СТРЕЛЬБА');
    expect(style.description, startsWith('<p>${FightingStyle.archery.description}</p>'));
    // Ниже — текст умения с сайта; отдельной особенности стиля нет.
    expect(style.description, contains('Выберите один из следующих вариантов'));
    expect(fighter.abilities.where((e) => e.name.startsWith('БОЕВОЙ СТИЛЬ')), hasLength(1));

    // Второй стиль чемпиона — в «Дополнительном боевом стиле».
    final champion = _fighter(
      level: 10,
      archetypeId: Fighter.champion,
      styles: [FightingStyle.archery, FightingStyle.defence],
    ).copyWith(
      features: [
        ...Fighter.featuresAt(info, 1),
        ...Fighter.featuresAt(info, 10, archetypeId: Fighter.champion),
      ],
    );
    expect(champion.abilities.map((e) => e.name),
        containsAll(['БОЕВОЙ СТИЛЬ: СТРЕЛЬБА', 'ДОПОЛНИТЕЛЬНЫЙ БОЕВОЙ СТИЛЬ: ОБОРОНА']));

    // Без умения с сайта стиль показывается отдельной особенностью.
    expect(_fighter(styles: [FightingStyle.dueling]).abilities.single.name, 'БОЕВОЙ СТИЛЬ: ДУЭЛЯНТ');
  });
}
