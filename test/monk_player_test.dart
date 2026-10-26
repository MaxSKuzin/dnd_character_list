import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/monk.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

final _shortsword = Weapon(
  id: '/weapons/shortsword',
  name: 'Короткий меч',
  damage: Dice.k6,
  damageType: DamageType.pricking,
  kind: WeaponKind.martialMelee,
  type: WeaponType.oneHanded,
);

final _quarterstaff = Weapon(
  id: '/weapons/quarterstaff',
  name: 'Боевой посох',
  damage: Dice.k6,
  twoHandedDamage: Dice.k8,
  damageType: DamageType.crushing,
  kind: WeaponKind.simpleMelee,
  type: WeaponType.universal,
);

Monk _monk({int level = 1, String? traditionId, Dice? dice, int kiPoints = 0, int movement = 0}) => Monk(
      level: level,
      isMain: true,
      features: const [],
      traditionId: traditionId,
      traditionName: traditionId == null ? null : 'Путь',
      martialArtsDice: dice ?? Dice.k4,
      kiPoints: kiPoints,
      unarmoredMovement: movement,
    );

// Сила 8 (−1), Ловкость 16 (+3), Телосложение 14 (+2).
Player _player(Monk monk) => playerFixture(
      spec: monk,
      items: [
        InventoryItem(quantity: 1, item: _shortsword),
        InventoryItem(quantity: 1, item: _quarterstaff),
        InventoryItem(quantity: 1, item: greatswordFixture),
        InventoryItem(quantity: 1, item: leatherFixture),
        InventoryItem(quantity: 1, item: shieldFixture),
      ],
    );

void main() {
  test('base monk sheet', () {
    final player = _player(_monk());

    expect(player.maxHits, 8 + 2);
    expect(player.saveThrows.where((e) => e.isChosen).map((e) => e.origin), [StatKind.strength, StatKind.dexterity]);
    expect(player.isProficientWith(_shortsword), isTrue);
    expect(player.isProficientWith(_quarterstaff), isTrue);
    expect(player.isProficientWith(greatswordFixture), isFalse);
    expect(player.armorProficiencies, isEmpty);
    expect(player.spellCells, isEmpty);
    expect(player.maxExtras, isEmpty);
    expect(player.classes.single.name, 'Монах');
  });

  test('unarmored defense needs neither armor nor shield', () {
    final player = _player(_monk());

    // Мудрость 10 у тестового персонажа: 10 + 3 + 0.
    expect(player.armorClass.parts.map((e) => e.$1), ['Защита без доспехов', 'Ловкость', 'Мудрость']);
    expect(player.protection, 13);
    expect(player.equipArmor(leatherFixture).protection, 11 + 3);
    // Со щитом защита без доспехов не действует: 10 + Ловкость + щит.
    expect(player.equipShield(shieldFixture).protection, 10 + 3 + 2);
  });

  test('unarmored movement adds speed without armor and shield', () {
    final player = _player(_monk(level: 6, movement: 15));

    expect(player.speed, 45);
    expect(player.equipArmor(leatherFixture).speed, 30);
    expect(player.equipShield(shieldFixture).speed, 30);
  });

  test('martial arts: dexterity, martial arts die and unarmed strike', () {
    final player = _player(_monk(level: 5, dice: Dice.k6)).equipMainWeapon(_shortsword);

    final sword = player.attacks.first;
    expect(sword.ability, StatKind.dexterity);
    expect(sword.attackBonus, 3 + 3);
    expect(sword.damage, '1к6 + 3');

    final unarmed = player.attacks.last;
    expect(unarmed.weapon, unarmedStrike);
    expect(unarmed.ability, StatKind.dexterity);
    expect(unarmed.isProficient, isTrue);
    expect(unarmed.damage, '1к6 + 3');

    // Кость боевых искусств больше кости посоха одной рукой.
    final staff = _player(_monk(level: 11, dice: Dice.k8)).attackWith(_quarterstaff, WeaponSlot.mainHand);
    expect(staff.damage, '1к8 + 3');

    // В доспехе боевые искусства не работают: Сила и 1 + Сила у безоружного удара.
    final armored = player.equipArmor(leatherFixture);
    expect(armored.attacks.first.ability, StatKind.strength);
    expect(armored.attacks.last.damage, '1');
    // Двуручное тяжёлое оружие — не монашеское.
    expect(player.martialArtsDiceFor(greatswordFixture), isNull);
  });

  test('only monks get unarmed strike in attacks', () {
    expect(playerFixture().attacks, isEmpty);
  });

  test('ki points recover on short rest, diamond soul gives all saves', () {
    final monk = _monk(level: 14, kiPoints: 14);
    final player = _player(monk);

    expect(player.maxExtras, {ClassExtras.ci: 14});
    expect(player.saveThrows.every((e) => e.isChosen), isTrue);
    // Владение спасброском Ловкости не удваивается.
    expect(player.saveThrows.firstWhere((e) => e.origin == StatKind.dexterity).bonus, 3 + player.proficiencyBonus);

    final tired = player.useExtra(ClassExtras.ci).useExtra(ClassExtras.ci).takeDamage(5);
    expect(tired.canRestOnShortRest, isTrue);
    final rested = tired.shortRest(3);
    expect(rested.currentExtras[ClassExtras.ci], 14);
    expect(rested.currentHits, player.maxHits - 2);
  });

  test('short rest restores bard inspiration only from 5th level', () {
    Player bard(int level) => playerFixture(
          spec: Bard(level: level, isMain: true, knownSpells: const [], features: const [], inspirationDice: Dice.k8),
        ).useExtra(ClassExtras.inspiration);

    // Харизма 17: три вдохновения, одно потрачено.
    expect(bard(4).canRestOnShortRest, isFalse);
    expect(bard(4).shortRest(0).currentExtras[ClassExtras.inspiration], 2);
    expect(bard(5).shortRest(0).currentExtras[ClassExtras.inspiration], 3);
  });

  test('traditions grant skills and monk is saved', () {
    final player = _player(_monk(level: 3, traditionId: Monk.mercy, kiPoints: 3, movement: 10));

    expect(player.chosenSkills, containsAll([Skill.insight, Skill.medicine]));

    final restored = Player.fromJson(player.toJson()).classes.single as Monk;
    expect(restored.traditionId, Monk.mercy);
    expect(restored.martialArtsDice, Dice.k4);
    expect(restored.kiPoints, 3);
    expect(restored.unarmoredMovement, 10);
    expect(restored.name, 'Монах (Путь)');
  });
}
