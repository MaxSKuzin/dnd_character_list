import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapon_info_dialog.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          itemCount: inventory.items.length,
          itemBuilder: (context, index) {
            final quantity = inventory.items[index].quantity;
            final item = inventory.items[index].item;
            if (item is CustomInvetoryItem) {
              return ListTile(
                title: Text(item.name),
                subtitle: Text(item.description),
                trailing: Text('x$quantity'),
              );
            }
            if (item is Weapon) {
              return ListTile(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (modalContext) => Dialog(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        WeaponInfoDialog(
                          weapon: item,
                          weaponSlot: null,
                          canUnequip: false,
                        ),
                        TextButton(
                          onPressed: () async {
                            final player = PlayerModel.getPlayer(context);
                            if (quantity == 1 && (item == player.secondWeapon || item == player.secondRangeWeapon)) {
                              await context.read<PlayerCubit>().unequipSecondaryWeapon(item);
                            }
                            await context.read<PlayerCubit>().equipMainWeapon(item);
                            Navigator.of(modalContext).pop();
                          },
                          child: const Text('Взять в основную руку'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final player = PlayerModel.getPlayer(context);
                            if (quantity == 1 && (item == player.mainWeapon || item == player.mainRangeWeapon)) {
                              await context.read<PlayerCubit>().unequipMainWeapon(item);
                            }
                            await context.read<PlayerCubit>().equipSecondaryWeapon(item);
                            Navigator.of(modalContext).pop();
                          },
                          child: const Text('Взять во вторую руку'),
                        ),
                      ],
                    ),
                  ),
                ),
                title: Text(item.name),
                trailing: Text('x$quantity'),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
