import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ArmorWidget extends StatelessWidget {
  final bool canWear;
  final Armor armor;

  const ArmorWidget(
    this.armor, {
    this.canWear = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        32,
        8,
        32,
        24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            armor.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(armor.kind.name),
          const Gap(16),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Защита: ${armor.protection}'),
                const Gap(8),
                if (armor.dexterityLimit != null) ...[
                  Text('Макс. бонус ловкости: ${armor.dexterityLimit}'),
                  const Gap(8),
                ],
                if (armor.stealthDisadvantage) const Text('Помеха при проверке скрытности'),
                if (canWear) ...[
                  const Gap(16),
                  ElevatedButton(
                    onPressed: () {
                      if (context.read<PlayerCubit>().state.armor == armor) {
                        context.read<PlayerCubit>().unequipArmor(armor);
                      } else {
                        context.read<PlayerCubit>().equipArmor(armor);
                      }
                      Navigator.of(context).pop();
                    },
                    child:
                        context.read<PlayerCubit>().state.armor == armor ? const Text('Снять') : const Text('Надеть'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
