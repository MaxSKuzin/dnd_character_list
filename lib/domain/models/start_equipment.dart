import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';

class EquipmentToSelect {
  final int quantity;
  final List<InventoryItem> items;

  EquipmentToSelect({
    required this.quantity,
    required this.items,
  });
}

class StartEquipment {
  final List<EquipmentKit> kits;
  final List<EquipmentToSelect> items;

  StartEquipment(
    this.items,
    this.kits,
  );
}

class EquipmentKit {
  final String name;
  final List<InventoryItem> items;

  EquipmentKit({
    required this.name,
    required this.items,
  });

  String get description {
    return items.map((e) {
      final name = switch (e.item) {
        Tool kit => kit.name,
        _ => e.item.toString(),
      };
      if (e.quantity > 1) {
        return '$name x${e.quantity}';
      }
      return name;
    }).join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EquipmentKit && name == other.name;
  }

  @override
  int get hashCode => Object.hashAll([name]);
}
