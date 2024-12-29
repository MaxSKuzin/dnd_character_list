import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/create_item_controller.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/widgets/create_armor_section.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/widgets/create_custom_item_section.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/widgets/create_shield_section.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/widgets/create_simple_item_section.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/widgets/create_tool_section.dart';
import 'package:dnd_character_list/presentation/Inventory_add_item_screen/widgets/create_weapon_section.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class InventoryAddItemScreen extends StatefulWidget {
  final Type itemType;
  final PlayerCubit playerCubit;

  const InventoryAddItemScreen({
    super.key,
    required this.itemType,
    required this.playerCubit,
  });

  @override
  State<InventoryAddItemScreen> createState() => _InventoryAddItemScreenState();
}

class _InventoryAddItemScreenState extends State<InventoryAddItemScreen> {
  CreateItemController? _controller;

  @override
  void dispose() {
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final section = switch (widget.itemType) {
      Type type when type == Weapon => CreateWeaponSection(
          onControllerReady: (controller) => _controller = controller,
        ),
      Type type when type == Armor => CreateArmorSection(
          onControllerReady: (controller) => _controller = controller,
        ),
      Type type when type == Shield => CreateShieldSection(
          onControllerReady: (controller) => _controller = controller,
        ),
      Type type when type == Tool => CreateToolSection(
          onControllerReady: (controller) => _controller = controller,
        ),
      Type type when type == CustomInvetoryItem => CreateCustomItemSection(
          onControllerReady: (controller) => _controller = controller,
        ),
      _ => CreateSimpleItemSection(
          onControllerReady: (controller) => _controller = controller,
        ),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                section,
                const Gap(24),
                OutlinedButton(
                  onPressed: () {
                    final item = _controller?.createItem();

                    if (item != null) {
                      widget.playerCubit.addItem(
                        InventoryItem(
                          quantity: 1,
                          item: item,
                        ),
                      );
                      context.maybePop();
                    }
                  },
                  child: const Text('Добавить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
