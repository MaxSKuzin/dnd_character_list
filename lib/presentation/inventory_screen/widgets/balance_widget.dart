import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/enter_balance_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class BalanceWidget extends StatelessWidget {
  final Balance balance;

  const BalanceWidget({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return LabeledBorder(
      text: 'БАЛАНС',
      backgroundColor: context.customColors?.cardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () async {
                final value = await showDialog<int?>(
                  context: context,
                  builder: (modalContext) => const Dialog(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: EnterBalanceDialog(
                      title: 'Снять',
                    ),
                  ),
                );
                if (value != null) {
                  context.read<PlayerCubit>().spendBalance(
                        Balance(value),
                      );
                }
              },
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: Column(
                children: [
                  Text('Золото: ${balance.gold}'),
                  const Gap(4),
                  Text('Серебро: ${balance.silver}'),
                  const Gap(4),
                  Text('Медь: ${balance.copper}'),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                final value = await showDialog<int?>(
                  context: context,
                  builder: (modalContext) => const Dialog(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: EnterBalanceDialog(
                      title: 'Положить',
                    ),
                  ),
                );
                if (value != null) {
                  context.read<PlayerCubit>().addBalance(
                        Balance(value),
                      );
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

