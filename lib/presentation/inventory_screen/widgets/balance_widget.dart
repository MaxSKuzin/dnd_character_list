import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/enter_balance_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BalanceWidget extends StatelessWidget {
  final Balance balance;

  const BalanceWidget({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    // Кошелёк — шапка экрана инвентаря: снять и положить деньги по краям.
    return SheetHeader(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SheetSectionTitle(icon: Icons.account_balance_wallet_outlined, title: 'Кошелёк'),
          ),
          Row(
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
                child: TileGrid(
                  columns: 3,
                  children: [
                    InfoTile(label: 'Золото', value: '${balance.gold}', valueStyle: _coin(context, Colors.amber)),
                    InfoTile(
                        label: 'Серебро',
                        value: '${balance.silver}',
                        valueStyle: _coin(context, Colors.blueGrey.shade100)),
                    InfoTile(
                        label: 'Медь',
                        value: '${balance.copper}',
                        valueStyle: _coin(context, Colors.deepOrange.shade200)),
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
        ],
      ),
    );
  }

  static TextStyle? _coin(BuildContext context, Color color) =>
      context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: color);
}
