import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/balance_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/custom_inventory_item_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/inventory_armor_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/inventory_shield_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/inventory_tool_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/inventory_weapon_widget.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final inventory = PlayerModel.inventory(context);
    final items = inventory.items.sorted((a, b) {
      final aOrder = switch (a.item) {
        Weapon _ => 0,
        Armor _ => 1,
        Tool _ => 2,
        Shield _ => 3,
        CustomInvetoryItem _ => 4,
        _ => 5,
      };
      final bOrder = switch (b.item) {
        Weapon _ => 0,
        Armor _ => 1,
        Tool _ => 2,
        Shield _ => 3,
        CustomInvetoryItem _ => 4,
        _ => 5,
      };
      return aOrder.compareTo(bOrder);
    });
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            BalanceWidget(
              balance: inventory.balance,
            ),
            const Gap(16),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final quantity = items[index].quantity;
                  final item = items[index].item;

                  return switch (item) {
                    CustomInvetoryItem item => CustomInventoryItemWidget(item: item, quantity: quantity),
                    Weapon item => InventoryWeaponWidget(item: item, quantity: quantity),
                    Armor item => InventoryArmorWidget(item: item, quantity: quantity),
                    Shield item => InventoryShieldWidget(item: item),
                    Tool item => InventoryToolWidget(item: item, quantity: quantity),
                    _ => ListTile(
                        title: Text(item),
                        trailing: Text('x$quantity'),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
