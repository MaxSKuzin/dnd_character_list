import 'dart:math';

import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
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
  final List<ElementalDamage> elementalDamage;

  const Weapon({
    required this.name,
    required this.damage,
    required this.damageType,
    required this.kind,
    required this.type,
    this.elementalDamage = const [],
    this.fixedDamage,
    this.damageMultiplier = 1,
    this.isFencing = false,
    this.weaponWeight = WeaponWeight.regular,
    this.twoHandedDamage,
    this.minRange,
    this.maxRange,
  });

  String getHitString(Player player) {
    int bonus;
    if (isFencing || kind.isRanged) {
      bonus = max(player.dexterity.bonus, player.strength.bonus);
    } else {
      bonus = player.strength.bonus;
    }
    if (player.secondWeapon == null &&
        player.fightingStyles.contains(FightingStyle.dueling) &&
        type == WeaponType.oneHanded) {
      bonus += 2;
    }
    return '+${bonus + player.proficiencyBonus}';
  }

  String getDamageString(
    Player player, {
    required bool isTwoHanded,
    required bool isMain,
  }) {
    int bonus;
    if (isFencing || kind.isRanged) {
      bonus = max(player.dexterity.bonus, player.strength.bonus);
    } else {
      bonus = player.strength.bonus;
    }
    var elementalDamage = this.elementalDamage.fold<String>(
          '',
          (previousValue, element) => '$previousValue + ${element.count}${element.damage.name}',
        );
    if (elementalDamage.isNotEmpty) {
      elementalDamage = elementalDamage;
    }
    if (isTwoHanded && type == WeaponType.universal) {
      final damageValue = (fixedDamage ?? 0) + bonus;
      return '$damageMultiplier${twoHandedDamage!.name}$elementalDamage${damageValue != 0 ? ' + $damageValue' : ''}';
    } else {
      if (!isMain && !player.canUseTwoWeapons) {
        bonus = 0;
      }

      final damageValue = (fixedDamage ?? 0) + bonus;
      return '$damageMultiplier${damage.name}$elementalDamage${damageValue != 0 ? ' + $damageValue' : ''}';
    }
  }

  String getRawDamageString({bool isTwoHanded = false}) {
    if (isTwoHanded) {
      return '$damageMultiplier${twoHandedDamage!.name}${(fixedDamage ?? 0) != 0 ? '+$fixedDamage' : ''}';
    } else {
      return '$damageMultiplier${damage.name}${(fixedDamage ?? 0) != 0 ? '+$fixedDamage' : ''}';
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'damage': damage.toJson(),
        'damageType': damageType.index,
        'kind': kind.index,
        'type': type.index,
        'fixedDamage': fixedDamage,
        'damageMultiplier': damageMultiplier,
        'isFencing': isFencing,
        'weaponWeight': weaponWeight.index,
        'twoHandedDamage': twoHandedDamage?.toJson(),
        'minRange': minRange,
        'maxRange': maxRange,
      };

  factory Weapon.fromJson(Map<String, dynamic> json) => Weapon(
        name: json['name'],
        damage: Dice.fromJson(json['damage']),
        damageType: DamageType.values[json['damageType']],
        kind: WeaponKind.values[json['kind']],
        type: WeaponType.values[json['type']],
        fixedDamage: json['fixedDamage'],
        damageMultiplier: json['damageMultiplier'],
        isFencing: json['isFencing'],
        weaponWeight: WeaponWeight.values[json['weaponWeight']],
        twoHandedDamage: json['twoHandedDamage'] == null ? null : Dice.fromJson(json['twoHandedDamage']),
        minRange: json['minRange'],
        maxRange: json['maxRange'],
      );

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

  factory Weapon.longSword() => Weapon(
        name: 'Длинный меч',
        damage: Dice.k8,
        twoHandedDamage: Dice.k10,
        damageType: DamageType.chopping,
        kind: WeaponKind.martialMelee,
        type: WeaponType.universal,
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

  factory Weapon.stuff() => Weapon(
        name: 'Боевой посох',
        damage: Dice.k6,
        twoHandedDamage: Dice.k8,
        damageType: DamageType.crushing,
        kind: WeaponKind.simpleMelee,
        type: WeaponType.universal,
      );
}

final availableWeapons = [
  Weapon.dagger(),
  Weapon.throwingSpear(),
  Weapon.twoHandedSword(),
  Weapon.bestNorthSword(),
  Weapon.rapier(),
  Weapon.longSword(),
  Weapon.ax(),
  Weapon.longBow(),
  Weapon.spear(),
];

class ElementalDamage {
  final ElementalType type;
  final Dice damage;
  final int count;

  const ElementalDamage({
    required this.type,
    required this.damage,
    required this.count,
  });

  @override
  bool operator ==(Object other) {
    if (other is ElementalDamage) {
      return type == other.type && damage == other.damage && count == other.count;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([type, damage, count]);

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'damage': damage.toJson(),
        'count': count,
      };

  factory ElementalDamage.fromJson(Map<String, dynamic> json) => ElementalDamage(
        type: ElementalType.values[json['type']],
        damage: Dice.fromJson(json['damage']),
        count: json['count'],
      );
}

enum ElementalType {
  fire,
  cold,
  acid,
  lightning,
  thunder,
  poison,
  necrotic,
  radiant,
  psychic;

  String get name => switch (this) {
        ElementalType.fire => 'Огонь',
        ElementalType.cold => 'Холод',
        ElementalType.acid => 'Кислота',
        ElementalType.lightning => 'Молния',
        ElementalType.thunder => 'Гром',
        ElementalType.poison => 'Яд',
        ElementalType.necrotic => 'Некротический',
        ElementalType.radiant => 'Лучистый',
        ElementalType.psychic => 'Психический',
      };
}
