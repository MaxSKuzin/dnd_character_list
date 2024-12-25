import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';

class BackgroundEquipment {
  final List<Tool> availableTools;
  final List<InventoryItem> additionalItems;

  BackgroundEquipment({
    required this.availableTools,
    required this.additionalItems,
  });
}
