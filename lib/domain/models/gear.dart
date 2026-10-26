import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/starting_equipment.dart';

/// Предмет снаряжения с https://5e14.ttg.club/items.
class Gear {
  /// Ссылка на ttg.club, например `/items/backpack`.
  final String? id;
  final String name;

  /// Группа в таблице, например «Боеприпасы» или «Фокусировка друидов».
  final String? group;
  final Balance? cost;

  /// Вес как на сайте: «2 фнт.», «½ фнт.», «—». В каталоге ttg.club не указывается.
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

/// Набор снаряжения, например «Набор артиста». В инвентарь не попадает: при добавлении распаковывается
/// в отдельные предметы (`EquipmentCatalog.unpack`), чтобы расходуемые вещи можно было считать.
class EquipmentPack {
  final String? id;
  final String name;
  final Balance? cost;

  /// Вещи набора: ссылка на предмет, текст как на сайте и количество.
  final List<EquipmentRef> contents;

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
        'contents': contents.map((e) => e.toJson()).toList(),
      };

  factory EquipmentPack.fromJson(Map<String, dynamic> json) => EquipmentPack(
        id: json['id'],
        name: json['name'],
        cost: json['cost'] == null ? null : Balance.fromJson(json['cost']),
        contents: (json['contents'] as List).map((e) => EquipmentRef.fromJson(e)).toList(),
      );
}
