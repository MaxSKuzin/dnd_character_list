import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ShieldDialog extends StatelessWidget {
  final Shield shield;

  const ShieldDialog(this.shield, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.white,
        ),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              shield.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(16),
            Text('Защита: ${shield.defense}'),
            const Gap(8),
            Text('Вес: ${shield.weight}'),
            const Gap(16),
            ElevatedButton(
              onPressed: () async {
                if (context.read<PlayerCubit>().state.shield == shield) {
                  context.read<PlayerCubit>().unequipShield();
                } else {
                  if (context.read<PlayerCubit>().state.mainWeapon?.type == WeaponType.twoHanded) {
                    await context.read<PlayerCubit>().unequipMainWeapon(context.read<PlayerCubit>().state.mainWeapon!);
                  }
                  if (context.read<PlayerCubit>().state.secondWeapon?.kind.isMelee ?? false) {
                    await context.read<PlayerCubit>().unequipSecondaryWeapon(
                          context.read<PlayerCubit>().state.secondWeapon!,
                        );
                  }
                  context.read<PlayerCubit>().equipShield(shield);
                }
                Navigator.of(context).pop();
              },
              child: context.read<PlayerCubit>().state.shield == shield ? const Text('Снять') : const Text('Надеть'),
            ),
          ],
        ),
      ),
    );
  }
}
