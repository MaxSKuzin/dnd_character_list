import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/balance_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/custom_inventory_item_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/inventory_armor_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/inventory_shield_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/inventory_tool_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/inventory_weapon_widget.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        Shield _ => 2,
        Tool _ => 3,
        CustomInvetoryItem _ => 4,
        _ => 5,
      };
      final bOrder = switch (b.item) {
        Weapon _ => 0,
        Armor _ => 1,
        Shield _ => 2,
        Tool _ => 3,
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
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return BlocProvider.value(
                      value: context.read<PlayerCubit>(),
                      child: const SelectItemTypeDialog(),
                    );
                  },
                );
              },
              child: const Text('Добавить предмет'),
            ),
            const Gap(16),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final quantity = items[index].quantity;
                  final item = items[index].item;

                  final child = switch (item) {
                    CustomInvetoryItem item => CustomInventoryItemWidget(item: item, quantity: quantity),
                    Weapon item => InventoryWeaponWidget(item: item, quantity: quantity),
                    Armor item => InventoryArmorWidget(item: item, quantity: quantity),
                    Shield item => InventoryShieldWidget(item: item, quantity: quantity),
                    Tool item => InventoryToolWidget(item: item, quantity: quantity),
                    _ => ListTile(
                        title: Text(item),
                        trailing: Text('x$quantity'),
                      ),
                  };

                  return Card(
                    clipBehavior: Clip.hardEdge,
                    child: Row(
                      children: [
                        Expanded(
                          child: child,
                        ),
                        PopupMenuButton(
                          menuPadding: EdgeInsets.zero,
                          itemBuilder: (_) {
                            return [
                              PopupMenuItem(
                                onTap: () async {
                                  context.read<PlayerCubit>().addItemQuantity(items[index]);
                                },
                                child: const Text('Добавить'),
                              ),
                              PopupMenuItem(
                                onTap: () async {
                                  if (quantity == 1) {
                                    switch (item) {
                                      case Weapon _:
                                        if (context.read<PlayerCubit>().state.mainWeapon == item ||
                                            context.read<PlayerCubit>().state.mainRangeWeapon == item) {
                                          await context.read<PlayerCubit>().unequipMainWeapon(item);
                                        } else if (context.read<PlayerCubit>().state.secondWeapon == item ||
                                            context.read<PlayerCubit>().state.secondRangeWeapon == item) {
                                          await context.read<PlayerCubit>().unequipSecondaryWeapon(item);
                                        }
                                        break;
                                      case Armor _:
                                        await context.read<PlayerCubit>().unequipArmor(item);
                                        break;
                                      case Shield _:
                                        await context.read<PlayerCubit>().unequipShield();
                                        break;
                                    }
                                  }
                                  if (quantity == 2 && item is Weapon) {
                                    if ((context.read<PlayerCubit>().state.mainWeapon == item ||
                                            context.read<PlayerCubit>().state.mainRangeWeapon == item) &&
                                        (context.read<PlayerCubit>().state.secondWeapon == item ||
                                            context.read<PlayerCubit>().state.secondRangeWeapon == item)) {
                                      await context.read<PlayerCubit>().unequipSecondaryWeapon(item);
                                    }
                                  }
                                  context.read<PlayerCubit>().removeItem(items[index]);
                                },
                                child: const Text('Удалить'),
                              ),
                            ];
                          },
                          child: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectItemTypeDialog extends StatefulWidget {
  const SelectItemTypeDialog({
    super.key,
  });

  @override
  State<SelectItemTypeDialog> createState() => _SelectItemTypeDialogState();
}

class _SelectItemTypeDialogState extends State<SelectItemTypeDialog> {
  Type? _itemType;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      title: const Text(
        'Выберите тип предмета',
        textAlign: TextAlign.center,
      ),
      content: Wrap(
        spacing: 8,
        children: [
          (Weapon, 'Оружие'),
          (Armor, 'Броня'),
          (Shield, 'Щит'),
          (Tool, 'Инструмент'),
          (CustomInvetoryItem, 'Предмет'),
          (String, 'Другое'),
        ]
            .map(
              (e) => GestureDetector(
                onTap: () => setState(() {
                  _itemType = e.$1;
                }),
                child: Chip(
                  label: Text(e.$2),
                  color: WidgetStatePropertyAll(
                    _itemType == e.$1 ? context.customColors?.cardColor : Colors.transparent,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: _itemType != null
              ? () {
                  Navigator.of(context).pop();
                  context.router.push(
                    InventoryAddItemRoute(
                      itemType: _itemType!,
                      playerCubit: context.read<PlayerCubit>(),
                    ),
                  );
                }
              : null,
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
