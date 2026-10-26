import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/item_texts.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/balance_widget.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/equipment_panel.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/item_details_sheet.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  static const _groups = [
    ('Оружие', Icons.sports_martial_arts),
    ('Доспехи и щиты', Icons.shield_outlined),
    ('Инструменты', Icons.handyman_outlined),
    ('Снаряжение', Icons.inventory_2_outlined),
  ];

  static int _group(Object item) => switch (item) {
        Weapon _ => 0,
        Armor _ || Shield _ => 1,
        Tool _ => 2,
        _ => 3,
      };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, Player>(
      builder: (context, player) {
        final inventory = player.inventory;
        final grouped = groupBy(inventory.items, (InventoryItem e) => _group(e.item));
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              BalanceWidget(balance: inventory.balance),
              const Gap(16),
              const EquipmentPanel(),
              const Gap(16),
              OutlinedButton.icon(
                onPressed: () => context.router.push(ItemCatalogRoute(playerCubit: context.read<PlayerCubit>())),
                icon: const Icon(Icons.add),
                label: const Text('Добавить предмет'),
              ),
              for (final (index, (title, icon)) in _groups.indexed)
                if (grouped[index] case final items?) ...[
                  const Gap(16),
                  Text(title.toUpperCase(), style: context.theme.textTheme.labelLarge),
                  const Gap(4),
                  for (final item in items.sortedBy((e) => ItemTexts.name(e.item)))
                    _InventoryItemTile(item: item, icon: icon, equippedIn: _equippedIn(player, item.item)),
                ],
            ],
          ),
        );
      },
    );
  }

  /// Где надет предмет: «основная рука», «доспех».
  static List<String> _equippedIn(Player player, Object item) => [
        for (final slot in WeaponSlot.values)
          if (player.weaponIn(slot) == item) slot.labelFor(item as Weapon).toLowerCase(),
        if (player.armor == item) 'надет',
        if (player.shield == item) 'в руке',
      ];
}

class _InventoryItemTile extends StatelessWidget {
  final InventoryItem item;
  final IconData icon;
  final List<String> equippedIn;

  const _InventoryItemTile({required this.item, required this.icon, required this.equippedIn});

  @override
  Widget build(BuildContext context) {
    final subtitle = ItemTexts.subtitle(item.item);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: equippedIn.isEmpty ? Colors.white24 : Colors.white),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(ItemTexts.name(item.item)),
        subtitle: subtitle == null && equippedIn.isEmpty
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null) Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (equippedIn.isNotEmpty)
                    Text(
                      'Экипировано: ${equippedIn.join(', ')}',
                      style: TextStyle(color: context.theme.colorScheme.primary, fontSize: 12),
                    ),
                ],
              ),
        trailing: item.quantity > 1 ? Text('×${item.quantity}', style: const TextStyle(fontSize: 16)) : null,
        onTap: () => ItemDetailsSheet.show(context, item.item),
      ),
    );
  }
}
