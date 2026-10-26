import 'package:dnd_character_list/domain/models/balance.dart';

/// Предмет снаряжения из таблицы https://dnd.su/articles/inventory/98-equipment/.
class Gear {
  final String? id;
  final String name;

  /// Группа в таблице, например «Боеприпасы» или «Фокусировка друидов».
  final String? group;
  final Balance? cost;

  /// Вес как на сайте: «2 фнт.», «½ фнт.», «—».
  final String? weight;

  const Gear({
    this.id,
    required this.name,
    this.group,
    this.cost,
    this.weight,
  });

  @override
  bool operator ==(Object other) => other is Gear && other.name == name;

  @override
  int get hashCode => name.hashCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'group': group,
        'cost': cost?.toJson(),
        'weight': weight,
      };

  factory Gear.fromJson(Map<String, dynamic> json) => Gear(
        id: json['id'],
        name: json['name'],
        group: json['group'],
        cost: json['cost'] == null ? null : Balance.fromJson(json['cost']),
        weight: json['weight'],
      );
}

/// Набор снаряжения, например «Набор артиста»: хранится в инвентаре целиком со списком содержимого.
class EquipmentPack {
  final String? id;
  final String name;
  final Balance? cost;
  final List<String> contents;

  const EquipmentPack({
    this.id,
    required this.name,
    required this.contents,
    this.cost,
  });

  @override
  bool operator ==(Object other) => other is EquipmentPack && other.name == name;

  @override
  int get hashCode => name.hashCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cost': cost?.toJson(),
        'contents': contents,
      };

  factory EquipmentPack.fromJson(Map<String, dynamic> json) => EquipmentPack(
        id: json['id'],
        name: json['name'],
        cost: json['cost'] == null ? null : Balance.fromJson(json['cost']),
        contents: (json['contents'] as List).cast<String>(),
      );
}
