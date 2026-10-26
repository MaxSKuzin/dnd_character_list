import 'package:dnd_character_list/domain/models/armor_kind.dart';
import 'package:dnd_character_list/domain/models/balance.dart';

/// Доспех из таблицы https://dnd.su/articles/inventory/95-armor_and_shields/ или созданный игроком.
class Armor {
  final String? id;
  final String name;

  /// Базовый класс доспеха.
  final int protection;

  /// Максимальный бонус Ловкости к КД; `null` — без ограничения, 0 — Ловкость не учитывается.
  final int? dexterityLimit;
  final int weight;
  final ArmorKind kind;
  final bool stealthDisadvantage;

  /// Минимальная Сила; без неё скорость уменьшается на 10 футов.
  final int? strengthRequirement;
  final Balance? cost;

  const Armor({
    this.id,
    required this.kind,
    required this.weight,
    required this.name,
    required this.protection,
    required this.dexterityLimit,
    this.stealthDisadvantage = false,
    this.strengthRequirement,
    this.cost,
  });

  @override
  operator ==(Object other) {
    return other is Armor &&
        other.id == id &&
        other.name == name &&
        other.protection == protection &&
        other.dexterityLimit == dexterityLimit &&
        other.kind == kind &&
        other.stealthDisadvantage == stealthDisadvantage &&
        other.strengthRequirement == strengthRequirement &&
        other.weight == weight;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        protection,
        dexterityLimit,
        weight,
        kind,
        stealthDisadvantage,
        strengthRequirement,
      ]);

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'weight': weight,
        'name': name,
        'protection': protection,
        'dexterityLimit': dexterityLimit,
        'stealthDisadvantage': stealthDisadvantage,
        'strengthRequirement': strengthRequirement,
        'cost': cost?.toJson(),
      };

  factory Armor.fromJson(Map<String, dynamic> json) => Armor(
        id: json['id'],
        kind: ArmorKind.values.byName(json['kind']),
        weight: json['weight'],
        name: json['name'],
        protection: json['protection'],
        dexterityLimit: json['dexterityLimit'],
        stealthDisadvantage: json['stealthDisadvantage'],
        strengthRequirement: json['strengthRequirement'],
        cost: json['cost'] == null ? null : Balance.fromJson(json['cost']),
      );
}
