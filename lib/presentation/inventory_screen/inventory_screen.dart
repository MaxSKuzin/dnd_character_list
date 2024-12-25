import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapon_info_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                                  if (quantity == 1 &&
                                      (item == player.secondWeapon || item == player.secondRangeWeapon)) {
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
                  if (item is Armor) {
                    return ListTile(
                      title: Text(item.name),
                      trailing: Text('x$quantity'),
                    );
                  }
                  if (item is Tool) {
                    return ListTile(
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => Dialog(
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
                            child: TextParses(item.description),
                          ),
                        ),
                      ),
                      title: Text(item.name),
                      trailing: Text('x$quantity'),
                    );
                  }
                  return ListTile(
                    title: Text(item),
                    trailing: Text('x$quantity'),
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

class BalanceWidget extends StatelessWidget {
  final Balance balance;

  const BalanceWidget({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return LabeledBorder(
      text: 'БАЛАНС',
      backgroundColor: context.customColors?.cardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Золото: ${balance.gold}'),
                  const Gap(4),
                  Text('Серебро: ${balance.silver}'),
                  const Gap(4),
                  Text('Медь: ${balance.copper}'),
                ],
              ),
            ),
            Column(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EnterBalanceDialog extends StatefulWidget {
  final String title;

  const EnterBalanceDialog({
    super.key,
    required this.title,
  });

  @override
  State<EnterBalanceDialog> createState() => _EnterBalanceDialogState();
}

class _EnterBalanceDialogState extends State<EnterBalanceDialog> {
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _silverController = TextEditingController();
  final TextEditingController _copperController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title),
          const Gap(16),
          TextField(
            controller: _goldController,
            decoration: const InputDecoration(
              labelText: 'Золото',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          TextField(
            controller: _silverController,
            decoration: const InputDecoration(
              labelText: 'Серебро',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          TextField(
            controller: _copperController,
            decoration: const InputDecoration(
              labelText: 'Медь',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () {
              final gold = int.tryParse(_goldController.text) ?? 0;
              final silver = int.tryParse(_silverController.text) ?? 0;
              final copper = int.tryParse(_copperController.text) ?? 0;

              Navigator.of(context).pop(gold * 100 + silver * 10 + copper);
            },
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }
}
