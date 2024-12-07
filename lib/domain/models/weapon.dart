import 'dart:math';

import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/domain/models/weapon_weight.dart';

class Weapon {
  final String name;
  final Dice damage;
  final DamageType damageType;
  final int damageMultiplier;
  final WeaponType type;
  final WeaponKind kind;
  final WeaponWeight weaponWeight;
  final Dice? twoHandedDamage;
  final int? minRange;
  final int? maxRange;
  final bool isFencing;
  final int? fixedDamage;

  const Weapon({
    required this.name,
    required this.damage,
    required this.damageType,
    required this.kind,
    required this.type,
    this.fixedDamage,
    this.damageMultiplier = 1,
    this.isFencing = false,
    this.weaponWeight = WeaponWeight.regular,
    this.twoHandedDamage,
    this.minRange,
    this.maxRange,
  });

  String getHitString(Player player) {
    final int bonus;
    if (isFencing) {
      bonus = max(player.dexterity.bonus, player.strength.bonus);
    } else {
      bonus = player.strength.bonus;
    }
    return '+${bonus + player.proficiencyBonus}';
  }

  String getDamageString({bool isTwoHanded = false}) {
    if (isTwoHanded) {
      return '$damageMultiplier${twoHandedDamage!.name}${fixedDamage != null ? '+$fixedDamage' : ''}';
    } else {
      return '$damageMultiplier${damage.name}${fixedDamage != null ? '+$fixedDamage' : ''}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is Weapon) {
      return name == other.name &&
          damage == other.damage &&
          damageType == other.damageType &&
          kind == other.kind &&
          type == other.type &&
          weaponWeight == other.weaponWeight &&
          twoHandedDamage == other.twoHandedDamage &&
          minRange == other.minRange &&
          isFencing == other.isFencing &&
          maxRange == other.maxRange;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([
        name,
        damage,
        damageType,
        kind,
        type,
        weaponWeight,
        twoHandedDamage,
        minRange,
        maxRange,
        isFencing,
      ]);

  factory Weapon.dagger() => Weapon(
        name: 'Кинжал',
        damage: Dice.k4,
        isFencing: true,
        minRange: 20,
        maxRange: 60,
        damageType: DamageType.pricking,
        kind: WeaponKind.simpleMelee,
        type: WeaponType.oneHanded,
        weaponWeight: WeaponWeight.light,
      );

  factory Weapon.throwingSpear() => Weapon(
        name: 'Метательное копье',
        damage: Dice.k6,
        maxRange: 30,
        minRange: 120,
        damageType: DamageType.pricking,
        kind: WeaponKind.simpleMelee,
        type: WeaponType.oneHanded,
      );

  factory Weapon.twoHandedSword() => Weapon(
        name: 'Двуручный меч',
        damage: Dice.k6,
        damageMultiplier: 2,
        damageType: DamageType.chopping,
        kind: WeaponKind.martialMelee,
        type: WeaponType.twoHanded,
        weaponWeight: WeaponWeight.heavy,
      );

  factory Weapon.bestNorthSword() => Weapon(
        name: 'Лучший меч Севера',
        damage: Dice.k6,
        damageMultiplier: 2,
        damageType: DamageType.chopping,
        kind: WeaponKind.martialMelee,
        type: WeaponType.twoHanded,
        weaponWeight: WeaponWeight.heavy,
        fixedDamage: 3,
      );

  factory Weapon.rapier() => Weapon(
        name: 'Рапира',
        isFencing: true,
        damage: Dice.k8,
        damageType: DamageType.pricking,
        kind: WeaponKind.martialMelee,
        type: WeaponType.oneHanded,
      );

  ///Секира
  factory Weapon.ax() => Weapon(
        name: 'Секира',
        damage: Dice.k12,
        damageType: DamageType.chopping,
        kind: WeaponKind.martialMelee,
        type: WeaponType.twoHanded,
        weaponWeight: WeaponWeight.heavy,
      );

  factory Weapon.longBow() => Weapon(
        name: 'Длинный лук',
        damage: Dice.k8,
        minRange: 150,
        maxRange: 600,
        damageType: DamageType.pricking,
        kind: WeaponKind.martialRanged,
        type: WeaponType.twoHanded,
        weaponWeight: WeaponWeight.heavy,
      );

  factory Weapon.spear() => Weapon(
        name: 'Копье',
        damage: Dice.k6,
        twoHandedDamage: Dice.k8,
        minRange: 20,
        maxRange: 60,
        damageType: DamageType.pricking,
        kind: WeaponKind.simpleMelee,
        type: WeaponType.universal,
      );
}
