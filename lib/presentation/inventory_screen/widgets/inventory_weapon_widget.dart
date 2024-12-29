import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapon_info_dialog.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryWeaponWidget extends StatelessWidget {
  const InventoryWeaponWidget({
    super.key,
    required this.item,
    required this.quantity,
  });

  final Weapon item;
  final int quantity;

  @override
  Widget build(BuildContext context) {
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
                  if (quantity == 1 &&
                      (item == player.secondWeapon ||
                          item == player.secondRangeWeapon ||
                          item.type == WeaponType.twoHanded)) {
                    await context.read<PlayerCubit>().unequipSecondaryWeapon(item);
                    if (player.shield != null) {
                      await context.read<PlayerCubit>().unequipShield();
                    }
                  }
                  await context.read<PlayerCubit>().equipMainWeapon(item);
                  Navigator.of(modalContext).pop();
                },
                child: const Text('Взять в основную руку'),
              ),
              TextButton(
                onPressed: item.type != WeaponType.twoHanded
                    ? () async {
                        final player = PlayerModel.getPlayer(context);
                        if (quantity == 1 &&
                            (item == player.mainWeapon ||
                                item == player.mainRangeWeapon ||
                                player.mainWeapon?.type == WeaponType.twoHanded)) {
                          await context.read<PlayerCubit>().unequipMainWeapon(item);
                        }
                        await context.read<PlayerCubit>().equipSecondaryWeapon(item);
                        Navigator.of(modalContext).pop();
                      }
                    : null,
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
}
