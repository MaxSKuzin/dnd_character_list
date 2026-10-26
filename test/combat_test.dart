import 'package:dnd_character_list/domain/models/classes/barbarian.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  group('armor class', () {
    test('depends on armor kind and dexterity', () {
      final player = playerFixture();

      expect(player.armorClass.value, 10 + 3);
      expect(player.equipArmor(leatherFixture).armorClass.value, 11 + 3);
      expect(player.equipArmor(leatherFixture).armorClass.parts, [('Кожаный', 11), ('Ловкость', 3)]);
      expect(player.equipArmor(scaleFixture).armorClass.value, 14 + 2, reason: 'Средний доспех: Ловкость не больше 2');
      expect(player.equipArmor(chainmailFixture).armorClass.value, 16, reason: 'Тяжёлый доспех без Ловкости');
      expect(player.equipArmor(leatherFixture).equipShield(shieldFixture).armorClass.value, 11 + 3 + 2);
    });

    test('negative dexterity lowers armor class', () {
      expect(playerFixture(dexterity: 8).equipArmor(leatherFixture).armorClass.value, 11 - 1);
    });

    test('barbarian unarmored defense adds constitution', () {
      final barbarian = playerFixture(spec: Barbarian(level: 1, isMain: true));

      expect(barbarian.armorClass.value, 10 + 3 + 2);
      expect(barbarian.equipShield(shieldFixture).armorClass.value, 10 + 3 + 2 + 2);
      expect(barbarian.equipArmor(leatherFixture).armorClass.value, 11 + 3);
    });

    test('heavy armor without proficiency and strength', () {
      final player = playerFixture().equipArmor(chainmailFixture).equipShield(shieldFixture);

      expect(player.isArmorProficient, isFalse, reason: 'Бард владеет только лёгкими доспехами');
      expect(player.isShieldProficient, isFalse);
      expect(player.isArmorTooHeavy, isTrue);
      expect(player.speed, 20);
    });
  });

  group('attacks', () {
    test('finesse weapon uses dexterity and proficiency', () {
      final attack = playerFixture().equipWeapon(rapierFixture, WeaponSlot.mainHand).attacks.single;

      expect(attack.ability, StatKind.dexterity);
      expect(attack.isProficient, isTrue);
      expect(attack.attackBonus, 3 + 2);
      expect(attack.damage, '1к8 + 3');
    });

    test('weapon without proficiency does not add proficiency bonus', () {
      final attack = playerFixture().equipWeapon(greatswordFixture, WeaponSlot.mainHand).attacks.single;

      expect(attack.ability, StatKind.strength);
      expect(attack.isProficient, isFalse);
      expect(attack.attackBonus, -1);
      expect(attack.damage, '2к6 − 1');
    });

    test('versatile weapon is used two-handed when the other hand is free', () {
      final player = playerFixture().equipWeapon(longswordFixture, WeaponSlot.mainHand);

      expect(player.attacks.single.damage, '1к10 − 1');
      expect(player.equipShield(shieldFixture).attacks.single.damage, '1к8 − 1');
    });

    test('off-hand weapon gets no positive modifier without two-weapon fighting', () {
      final player = playerFixture().equipWeapon(daggerFixture, WeaponSlot.mainHand).equipWeapon(daggerFixture, WeaponSlot.secondHand);

      expect(player.attacks.map((e) => e.damage), ['1к4 + 3', '1к4']);
    });

    test('weapon master grants proficiency with chosen weapons', () {
      final feat = ChosenFeat(
        feat: const Feat(
          id: 122,
          link: '/feats/122-weapon-master/',
          name: 'Мастер оружия',
          nameEn: 'Weapon master',
          requirementText: null,
          requirement: FeatRequirement(),
          descriptionHtml: '',
          statIncreaseOptions: [StatKind.strength, StatKind.dexterity],
        ),
        increasedStat: StatKind.strength,
        // У двуручного меча нет якоря на dnd.su — владение хранится по названию.
        weapons: [greatswordFixture.proficiencyKey],
      );
      final bard = Bard(
        level: 4,
        isMain: true,
        knownSpells: const [],
        features: const [],
        inspirationDice: Dice.k6,
        improvements: [AbilityScoreImprovement(level: 4, feat: feat)],
      );
      final player = playerFixture(spec: bard);

      expect(feat.feat.weaponChoices, 4);
      expect(player.isProficientWith(greatswordFixture), isTrue);
      expect(player.equipWeapon(greatswordFixture, WeaponSlot.mainHand).attacks.single.attackBonus, -1 + 2);
      expect(ChosenFeat.fromJson(feat.toJson()).weapons, ['Двуручный меч']);
    });

    test('dueling adds 2 to damage, not to attack', () {
      final swords = Bard(
        level: 3,
        isMain: true,
        knownSpells: const [],
        features: const [],
        inspirationDice: Dice.k6,
        collegeId: Bard.swordsCollege,
        fightingStyle: FightingStyle.dueling,
      );
      final attack = playerFixture(spec: swords).equipWeapon(rapierFixture, WeaponSlot.mainHand).attacks.single;

      expect(attack.attackBonus, 3 + 2);
      expect(attack.damage, '1к8 + 5');
    });
  });

  group('equipping', () {
    test('two-handed weapon frees the other hand', () {
      final player = playerFixture().equipWeapon(daggerFixture, WeaponSlot.mainHand).equipWeapon(daggerFixture, WeaponSlot.secondHand);
      final withGreatsword = player.equipShield(shieldFixture).equipWeapon(greatswordFixture, WeaponSlot.mainHand);

      expect(withGreatsword.secondWeapon, isNull);
      expect(withGreatsword.shield, isNull);
      expect(withGreatsword.canUseShield, isFalse);
    });

    test('shield replaces off-hand weapon', () {
      final player = playerFixture().equipWeapon(daggerFixture, WeaponSlot.mainHand).equipWeapon(daggerFixture, WeaponSlot.secondHand);

      expect(player.equipShield(shieldFixture).secondWeapon, isNull);
    });

    test('off-hand requires light weapons and free copies', () {
      final withRapier = playerFixture().equipWeapon(rapierFixture, WeaponSlot.mainHand);
      expect(withRapier.cannotEquip(daggerFixture, WeaponSlot.secondHand), isNotNull);

      final withDagger = playerFixture().equipWeapon(daggerFixture, WeaponSlot.mainHand);
      expect(withDagger.cannotEquip(daggerFixture, WeaponSlot.secondHand), isNull);

      final oneDagger = playerFixture(items: [InventoryItem(quantity: 1, item: daggerFixture)]).equipWeapon(daggerFixture, WeaponSlot.mainHand);
      expect(oneDagger.cannotEquip(daggerFixture, WeaponSlot.secondHand), 'Все экземпляры уже экипированы');
    });

    test('changing main weapon drops off-hand weapon that is no longer allowed', () {
      final twoDaggers = playerFixture().equipWeapon(daggerFixture, WeaponSlot.mainHand).equipWeapon(daggerFixture, WeaponSlot.secondHand);

      final withRapier = twoDaggers.equipWeapon(rapierFixture, WeaponSlot.mainHand);

      expect(withRapier.mainWeapon, rapierFixture);
      expect(withRapier.secondWeapon, isNull, reason: 'Рапира не лёгкая — сражаться двумя оружиями нельзя');
      expect(twoDaggers.equipWeapon(daggerFixture, WeaponSlot.mainHand).secondWeapon, daggerFixture);
    });

    test('dagger thrown after switching to rapier is only in ranged slot', () {
      final player = playerFixture()
          .equipWeapon(daggerFixture, WeaponSlot.mainHand)
          .equipWeapon(daggerFixture, WeaponSlot.secondHand)
          .equipWeapon(rapierFixture, WeaponSlot.mainHand)
          .equipWeapon(daggerFixture, WeaponSlot.mainRange);

      expect(WeaponSlot.values.where((slot) => player.weaponIn(slot) == daggerFixture), [WeaponSlot.mainRange]);
    });

    test('thrown melee weapons can be used in ranged slot', () {
      final player = playerFixture();

      expect(player.cannotEquip(daggerFixture, WeaponSlot.mainRange), isNull);
      expect(player.cannotEquip(rapierFixture, WeaponSlot.mainRange), isNotNull);
      expect(player.equipWeapon(daggerFixture, WeaponSlot.mainRange).attacks.single.ability, StatKind.dexterity);
    });

    test('removing the last copy unequips the item', () {
      final player = playerFixture().equipWeapon(rapierFixture, WeaponSlot.mainHand).equipArmor(leatherFixture);
      final item = player.inventory.items.firstWhere((e) => e.item == rapierFixture);

      final result = player.removeItem(item);

      expect(result.mainWeapon, isNull);
      expect(result.armor, leatherFixture);
    });
  });
}
