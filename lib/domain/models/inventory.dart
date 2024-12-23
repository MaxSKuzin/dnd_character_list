import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';

class Inventory {
  List<InventoryItem> items;

  Inventory({
    required this.items,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Inventory && other.items.equals(items);
  }

  @override
  int get hashCode => items.hashCode;

  Inventory copyWith({
    List<InventoryItem>? items,
  }) {
    return Inventory(
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((e) => e.toJson()).toList()};
  }

  factory Inventory.fromJson(Map<String, dynamic> json) => Inventory(
        items: List<InventoryItem>.from(
          json['items'].map((x) => InventoryItem.fromJson(x)),
        ),
      );
}

class InventoryItem {
  int quantity;
  dynamic item;

  InventoryItem({
    required this.quantity,
    required this.item,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InventoryItem && other.quantity == quantity && other.item == item;
  }

  @override
  int get hashCode => quantity.hashCode ^ item.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'item': {
        'itemType': item.runtimeType.toString(),
        ...(item.toJson() as Map<String, dynamic>),
      },
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        quantity: json['quantity'],
        item: switch (json['item']['itemType']) {
          'CustomInvetoryItem' => CustomInvetoryItem.fromJson(json['item']),
          'Weapon' => Weapon.fromJson(json['item']),
          'Armor' => Armor.fromJson(json['item']),
          _ => throw Exception('Unknown item type'),
        },
      );
}

class CustomInvetoryItem {
  String name;
  String description;

  CustomInvetoryItem({
    required this.name,
    required this.description,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomInvetoryItem && other.name == name && other.description == description;
  }

  @override
  int get hashCode => name.hashCode ^ description.hashCode;

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }

  factory CustomInvetoryItem.fromJson(Map<String, dynamic> json) => CustomInvetoryItem(
        name: json['name'],
        description: json['description'],
      );
}
