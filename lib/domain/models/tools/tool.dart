import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';

/// Инструмент с https://5e14.ttg.club/items.
class Tool {
  final ToolCategory category;
  final String name;

  /// Описание инструмента в html, как на сайте.
  final String description;
  final Balance price;

  /// Вес в фунтах.
  final double? weight;

  const Tool({
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    this.weight,
  });

  @override
  bool operator ==(Object other) => other is Tool && other.category == category && other.name == name;

  @override
  int get hashCode => Object.hash(category, name);

  factory Tool.fromJson(Map<String, dynamic> json) => Tool(
        category: ToolCategory.values.byName(json['category']),
        name: json['name'],
        description: json['description'],
        price: Balance.fromJson(json['price']),
        weight: (json['weight'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'name': name,
        'description': description,
        'price': price.toJson(),
        'weight': weight,
      };
}
