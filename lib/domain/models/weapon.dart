import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/domain/models/weapon_weight.dart';

/// Оружие из таблицы https://dnd.su/articles/inventory/96-arms/ или созданное игроком.
class Weapon {
  /// Якорь на dnd.su, например `weapon.rapier`. Есть не у всех видов оружия.
  final String? id;
  final String name;

  /// Кость урона; `null` — оружие без урона (сеть) или с фиксированным уроном (духовая трубка).
  final Dice? damage;

  /// Количество костей урона: 2 для «2к6».
  final int damageMultiplier;
  final DamageType? damageType;
  final WeaponType type;
  final WeaponKind kind;
  final WeaponWeight weaponWeight;

  /// Урон двумя руками у универсального оружия.
  final Dice? twoHandedDamage;

  /// Нормальная и максимальная дистанция метательного или стрелкового оружия, в футах.
  final int? minRange;
  final int? maxRange;

  /// Свойство «фехтовальное»: для атаки и урона можно использовать Ловкость.
  final bool isFencing;
  final bool isThrown;
  final bool isReach;
  final bool isAmmunition;
  final bool isLoading;
  final bool isSpecial;

  final Balance? cost;

  /// Вес в фунтах.
  final double? weight;

  /// Бонус к урону магического или самодельного оружия.
  final int? fixedDamage;
  final List<ElementalDamage> elementalDamage;

  const Weapon({
    this.id,
    required this.name,
    required this.damage,
    required this.damageType,
    required this.kind,
    required this.type,
    this.elementalDamage = const [],
    this.fixedDamage,
    this.damageMultiplier = 1,
    this.isFencing = false,
    this.isThrown = false,
    this.isReach = false,
    this.isAmmunition = false,
    this.isLoading = false,
    this.isSpecial = false,
    this.weaponWeight = WeaponWeight.regular,
    this.twoHandedDamage,
    this.minRange,
    this.maxRange,
    this.cost,
    this.weight,
  });

  /// Ключ для владения отдельным видом оружия: якорь dnd.su или название, если якоря нет.
  String get proficiencyKey => id ?? name;

  bool get isLight => weaponWeight == WeaponWeight.light;

  bool get isHeavy => weaponWeight == WeaponWeight.heavy;

  /// Урон без модификаторов, например «1к8» или «1к10» двумя руками у универсального оружия.
  String getRawDamageString({bool isTwoHanded = false}) {
    final dice = isTwoHanded && twoHandedDamage != null ? twoHandedDamage : damage;
    final fixed = fixedDamage ?? 0;
    if (dice == null) return fixed == 0 ? '—' : '$fixed';
    return '$damageMultiplier${dice.name}${fixed != 0 ? ' + $fixed' : ''}';
  }

  @override
  bool operator ==(Object other) {
    if (other is Weapon) {
      return name == other.name &&
          id == other.id &&
          damage == other.damage &&
          damageMultiplier == other.damageMultiplier &&
          damageType == other.damageType &&
          kind == other.kind &&
          type == other.type &&
          weaponWeight == other.weaponWeight &&
          twoHandedDamage == other.twoHandedDamage &&
          minRange == other.minRange &&
          maxRange == other.maxRange &&
          isFencing == other.isFencing &&
          fixedDamage == other.fixedDamage;
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        damage,
        damageMultiplier,
        damageType,
        kind,
        type,
        weaponWeight,
        twoHandedDamage,
        minRange,
        maxRange,
        isFencing,
        fixedDamage,
      ]);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'damage': damage?.toJson(),
        'damageType': damageType?.name,
        'kind': kind.name,
        'type': type.name,
        'fixedDamage': fixedDamage,
        'damageMultiplier': damageMultiplier,
        'isFencing': isFencing,
        'isThrown': isThrown,
        'isReach': isReach,
        'isAmmunition': isAmmunition,
        'isLoading': isLoading,
        'isSpecial': isSpecial,
        'weaponWeight': weaponWeight.name,
        'twoHandedDamage': twoHandedDamage?.toJson(),
        'minRange': minRange,
        'maxRange': maxRange,
        'cost': cost?.toJson(),
        'weight': weight,
        'elementalDamage': elementalDamage.map((e) => e.toJson()).toList(),
      };

  factory Weapon.fromJson(Map<String, dynamic> json) => Weapon(
        id: json['id'],
        name: json['name'],
        damage: json['damage'] == null ? null : Dice.fromJson(json['damage']),
        damageType: json['damageType'] == null ? null : DamageType.values.byName(json['damageType']),
        kind: WeaponKind.values.byName(json['kind']),
        type: WeaponType.values.byName(json['type']),
        fixedDamage: json['fixedDamage'],
        damageMultiplier: json['damageMultiplier'],
        isFencing: json['isFencing'],
        isThrown: json['isThrown'],
        isReach: json['isReach'],
        isAmmunition: json['isAmmunition'],
        isLoading: json['isLoading'],
        isSpecial: json['isSpecial'],
        weaponWeight: WeaponWeight.values.byName(json['weaponWeight']),
        twoHandedDamage: json['twoHandedDamage'] == null ? null : Dice.fromJson(json['twoHandedDamage']),
        minRange: json['minRange'],
        maxRange: json['maxRange'],
        cost: json['cost'] == null ? null : Balance.fromJson(json['cost']),
        weight: (json['weight'] as num?)?.toDouble(),
        elementalDamage: (json['elementalDamage'] as List).map((e) => ElementalDamage.fromJson(e)).toList(),
      );
}

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
        'type': type.name,
        'damage': damage.toJson(),
        'count': count,
      };

  factory ElementalDamage.fromJson(Map<String, dynamic> json) => ElementalDamage(
        type: ElementalType.values.byName(json['type']),
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
  psychic,
}
