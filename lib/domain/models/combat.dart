import 'dart:math';

import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';

/// Владение оружием: категории и отдельные виды по [Weapon.proficiencyKey] (`weapon.rapier`).
class WeaponProficiency {
  final bool simple;
  final bool martial;
  final Set<String> weapons;

  const WeaponProficiency({this.simple = false, this.martial = false, this.weapons = const {}});

  static const none = WeaponProficiency();

  bool covers(Weapon weapon) =>
      (weapon.kind.isSimple ? simple : martial) || weapons.contains(weapon.proficiencyKey);

  WeaponProficiency operator +(WeaponProficiency other) => WeaponProficiency(
        simple: simple || other.simple,
        martial: martial || other.martial,
        weapons: {...weapons, ...other.weapons},
      );
}

/// Места для оружия: рукопашный и дальнобойный комплекты переключаются в бою.
enum WeaponSlot {
  mainHand,
  secondHand,
  mainRange,
  secondRange;

  bool get isMain => this == mainHand || this == mainRange;
}

/// Класс доспеха и из чего он складывается, например «Кожаный 11», «Ловкость +2», «Щит +2».
class ArmorClass {
  final int value;
  final List<(String, int)> parts;

  ArmorClass.of(this.parts) : value = parts.fold(0, (sum, e) => sum + e.$2);

  ArmorClass operator +((String, int) part) => ArmorClass.of([...parts, part]);
}

/// Атака экипированным оружием.
class WeaponAttack {
  final Weapon weapon;
  final WeaponSlot slot;
  final StatKind ability;
  final bool isProficient;
  final int attackBonus;

  /// Урон с модификаторами, например «1к8 + 3».
  final String damage;
  final bool isTwoHanded;

  const WeaponAttack({
    required this.weapon,
    required this.slot,
    required this.ability,
    required this.isProficient,
    required this.attackBonus,
    required this.damage,
    required this.isTwoHanded,
  });
}

extension PlayerCombat on Player {
  /// Владение от классов и от черты «Мастер оружия».
  WeaponProficiency get weaponProficiency =>
      classes.fold(WeaponProficiency.none, (sum, e) => sum + e.weaponProficiency) +
      WeaponProficiency(weapons: feats.expand((e) => e.weapons).toSet());

  bool isProficientWith(Weapon weapon) => weaponProficiency.covers(weapon);

  bool get isArmorProficient => armor == null || armorProficiencies.contains(armor!.kind.proficiency);

  bool get isShieldProficient => shield == null || armorProficiencies.contains(ArmorProficiency.shields);

  /// Без нужной Силы тяжёлый доспех уменьшает скорость на 10 футов.
  bool get isArmorTooHeavy => armor?.strengthRequirement != null && strength.value < armor!.strengthRequirement!;

  /// Лучший из вариантов защиты классов (например, защита без доспехов варвара), щит и стиль «Оборона».
  ArmorClass get armorClass {
    var result = classes.map((e) => e.armorClass(this)).reduce((a, b) => a.value >= b.value ? a : b);
    if (shield != null) result += (shield!.name, shield!.defense);
    if (armor != null && fightingStyles.contains(FightingStyle.defence)) result += ('Стиль «Оборона»', 1);
    return result;
  }

  Weapon? weaponIn(WeaponSlot slot) => switch (slot) {
        WeaponSlot.mainHand => mainWeapon,
        WeaponSlot.secondHand => secondWeapon,
        WeaponSlot.mainRange => mainRangeWeapon,
        WeaponSlot.secondRange => secondRangeWeapon,
      };

  List<WeaponAttack> get attacks => WeaponSlot.values
      .map((slot) => (slot, weaponIn(slot)))
      .where((e) => e.$2 != null)
      .map((e) => attackWith(e.$2!, e.$1))
      .toList();

  /// Характеристика атаки: Ловкость у дальнобойного, лучшая из Силы и Ловкости у фехтовального,
  /// иначе Сила (в том числе при метании рукопашного оружия).
  StatKind abilityFor(Weapon weapon) {
    if (weapon.kind.isRanged) return StatKind.dexterity;
    if (weapon.isFencing && dexterity.bonus > strength.bonus) return StatKind.dexterity;
    return StatKind.strength;
  }

  WeaponAttack attackWith(Weapon weapon, WeaponSlot slot) {
    final ability = abilityFor(weapon);
    final modifier = stats[ability]!.bonus;
    final isProficient = isProficientWith(weapon);

    // Универсальное оружие держат двумя руками, если вторая рука свободна.
    final isTwoHanded = weapon.type == WeaponType.twoHanded ||
        (weapon.type == WeaponType.universal && slot == WeaponSlot.mainHand && secondWeapon == null && shield == null);

    var damageBonus = modifier + (weapon.fixedDamage ?? 0);
    // Второе оружие не получает положительный модификатор без стиля «Сражение двумя оружиями».
    if (!slot.isMain && modifier > 0 && !fightingStyles.contains(FightingStyle.twoWeaponFighting)) {
      damageBonus -= modifier;
    }
    if (slot == WeaponSlot.mainHand &&
        !isTwoHanded &&
        secondWeapon == null &&
        fightingStyles.contains(FightingStyle.dueling)) {
      damageBonus += 2;
    }

    final dice = isTwoHanded && weapon.twoHandedDamage != null ? weapon.twoHandedDamage : weapon.damage;
    final elemental = weapon.elementalDamage.map((e) => ' + ${e.count}${e.damage.name}').join();
    final String damage;
    if (dice == null && weapon.fixedDamage == null) {
      damage = '—';
    } else if (dice == null) {
      damage = '${max(1, damageBonus)}$elemental';
    } else {
      final bonus = damageBonus == 0 ? '' : (damageBonus > 0 ? ' + $damageBonus' : ' − ${-damageBonus}');
      damage = '${weapon.damageMultiplier}${dice.name}$bonus$elemental';
    }

    return WeaponAttack(
      weapon: weapon,
      slot: slot,
      ability: ability,
      isProficient: isProficient,
      attackBonus: modifier + (isProficient ? proficiencyBonus : 0),
      damage: damage,
      isTwoHanded: isTwoHanded,
    );
  }

  /// Почему оружие нельзя взять в слот, или `null`, если можно. Во вторую руку берут лёгкое
  /// оружие при лёгком основном (с чертой «Использование двух оружий» — любое одноручное),
  /// в дальний бой — стрелковое или метательное оружие.
  String? cannotEquip(Weapon weapon, WeaponSlot slot) {
    final isRangedSlot = slot == WeaponSlot.mainRange || slot == WeaponSlot.secondRange;
    if (isRangedSlot && !weapon.kind.isRanged && !weapon.isThrown) return 'Только стрелковое или метательное оружие';
    if (!isRangedSlot && !weapon.kind.isMelee) return 'Только рукопашное оружие';

    final count = inventory.items.where((e) => e.item == weapon).fold(0, (sum, e) => sum + e.quantity);
    final used = WeaponSlot.values.where((e) => e != slot && weaponIn(e) == weapon).length;
    if (count <= used) return 'Все экземпляры уже экипированы';

    if (slot.isMain) return null;
    if (weapon.type == WeaponType.twoHanded) return 'Двуручное оружие держат обеими руками';
    final main = weaponIn(slot == WeaponSlot.secondHand ? WeaponSlot.mainHand : WeaponSlot.mainRange);
    if (main == null) return 'Сначала возьмите оружие в основную руку';
    if (main.type == WeaponType.twoHanded) return 'Основное оружие двуручное';
    final hasDualWielder = feats.any((e) => e.feat.slug == 'dual_wielder');
    if (!hasDualWielder && !(weapon.isLight && main.isLight)) return 'Для двух оружий оба должны быть лёгкими';
    return null;
  }

  /// Щит занимает вторую руку: нельзя держать двуручное оружие.
  bool get canUseShield => mainWeapon?.type != WeaponType.twoHanded;
}
