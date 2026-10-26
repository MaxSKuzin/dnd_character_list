import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/gear.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';

class Inventory {
  final Balance balance;
  late final List<InventoryItem> items;

  Inventory({
    required List<InventoryItem> items,
    required this.balance,
  }) {
    final newItems = <InventoryItem>[];
    for (final item in items) {
      final existingItem = newItems.firstWhereOrNull((e) => e.item == item.item);
      if (existingItem != null) {
        newItems.remove(existingItem);
        newItems.add(
          InventoryItem(
            quantity: existingItem.quantity + item.quantity,
            item: item.item,
          ),
        );
      } else {
        newItems.add(item);
      }
    }
    this.items = newItems;
  }

  Inventory spendBalance(Balance value) {
    return copyWith(
      balance: balance - value,
    );
  }

  Inventory addBalance(Balance value) {
    return copyWith(
      balance: balance + value,
    );
  }

  Inventory removeItem(InventoryItem item) {
    return copyWith(
      items: items
          .map((e) {
            if (e == item) {
              final newQuantity = e.quantity - 1;
              if (newQuantity == 0) {
                return null;
              }
              return InventoryItem(
                quantity: newQuantity,
                item: e.item,
              );
            }
            return e;
          })
          .nonNulls
          .toList(),
    );
  }

  /// Задаёт количество предмета; 0 убирает его из инвентаря.
  Inventory setItemQuantity(InventoryItem item, int quantity) => copyWith(
        items: [
          for (final e in items)
            if (e != item)
              e
            else if (quantity > 0)
              InventoryItem(quantity: quantity, item: e.item),
        ],
      );

  Inventory addItemQuantity(InventoryItem item) {
    return copyWith(
      items: items.map((e) {
        if (e == item) {
          final newQuantity = e.quantity + 1;
          return InventoryItem(
            quantity: newQuantity,
            item: e.item,
          );
        }
        return e;
      }).toList(),
    );
  }

  /// Добавляет предмет; такой же предмет в инвентаре получает его количество («Факел» ×10 + ×10 = ×20).
  Inventory addItem(InventoryItem item) {
    final existingItem = items.firstWhereOrNull((e) => e.item == item.item);
    if (existingItem != null) {
      return copyWith(
        items: [
          for (final e in items)
            e == existingItem ? InventoryItem(quantity: e.quantity + item.quantity, item: e.item) : e,
        ],
      );
    }
    return copyWith(
      items: [...items, item],
    );
  }

  Inventory copyWith({
    Balance? balance,
    List<InventoryItem>? items,
  }) {
    return Inventory(
      balance: balance ?? this.balance,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Inventory && other.items.equals(items) && balance == other.balance;
  }

  @override
  int get hashCode => items.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'balance': balance.toJson(),
    };
  }

  factory Inventory.fromJson(Map<String, dynamic> json) => Inventory(
        balance: Balance.fromJson(json['balance']),
        items: List<InventoryItem>.from(
          json['items'].map((x) => InventoryItem.fromJson(x)),
        ),
      );
}

class InventoryItem {
  final int quantity;
  final dynamic item;

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
        if (item is int || item is double || item is String || item is bool)
          'value': item
        else
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
          'Tool' => Tool.fromJson(json['item']),
          'Shield' => Shield.fromJson(json['item']),
          'Gear' => Gear.fromJson(json['item']),
          'int' || 'double' || 'String' || 'bool' => json['item']['value'],
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
