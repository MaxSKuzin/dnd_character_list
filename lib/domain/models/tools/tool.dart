import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';

class Tool {
  final ToolCategory category;
  final String name;
  final String description;
  final Balance price;

  const Tool({
    required this.category,
    required this.name,
    required this.description,
    required this.price,
  });

@override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Tool &&
      other.category == category &&
      other.name == name &&
      other.description == description &&
      other.price == price;
  }

  @override
  int get hashCode => category.hashCode ^ name.hashCode ^ description.hashCode ^ price.hashCode;

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      category: ToolCategory.values[json['category']],
      name: json['name'],
      description: json['description'],
      price: Balance.fromJson(json['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.index,
      'name': name,
      'description': description,
      'price': price.toJson(),
    };
  }
}
