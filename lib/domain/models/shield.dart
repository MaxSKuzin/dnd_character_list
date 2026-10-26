import 'package:dnd_character_list/domain/models/balance.dart';

class Shield {
  final String name;
  final int defense;
  final int weight;
  final Balance? cost;

  const Shield({
    required this.name,
    required this.defense,
    required this.weight,
    this.cost,
  });

  @override
  operator ==(Object other) =>
      other is Shield && other.name == name && other.defense == defense && other.weight == weight;

  @override
  int get hashCode => Object.hashAll([
        name,
        defense,
        weight,
      ]);

  Map<String, dynamic> toJson() => {
        'name': name,
        'defense': defense,
        'weight': weight,
        'cost': cost?.toJson(),
      };

  factory Shield.fromJson(Map<String, dynamic> json) => Shield(
        name: json['name'],
        defense: json['defense'],
        weight: json['weight'],
        cost: json['cost'] == null ? null : Balance.fromJson(json['cost']),
      );
}
