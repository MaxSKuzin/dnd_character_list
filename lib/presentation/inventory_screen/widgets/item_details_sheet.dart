import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/gear.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/extensions/item_texts.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Подробности предмета инвентаря и действия с ним: надеть, снять, изменить количество.
class ItemDetailsSheet extends StatelessWidget {
  final Object item;

  const ItemDetailsSheet({super.key, required this.item});

  static Future<void> show(BuildContext context, Object item) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => BlocProvider.value(
          value: context.read<PlayerCubit>(),
          child: ItemDetailsSheet(item: item),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, Player>(
      builder: (context, player) {
        final inventoryItem = player.inventory.items.where((e) => e.item == item).firstOrNull;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ItemTexts.name(item),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const Gap(12),
                ..._details(player),
                const Gap(16),
                ..._equipActions(context, player),
                if (inventoryItem != null) ...[
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.read<PlayerCubit>().removeItem(inventoryItem);
                            if (inventoryItem.quantity == 1) Navigator.of(context).pop();
                          },
                          icon: Icon(inventoryItem.quantity == 1 ? Icons.delete_outline : Icons.remove),
                          label: Text(inventoryItem.quantity == 1 ? 'Удалить' : 'Убрать один'),
                        ),
                      ),
                      // Нажатие на количество — ввод точного числа: «осталось 7 факелов». 0 убирает предмет.
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          final cubit = context.read<PlayerCubit>();
                          final navigator = Navigator.of(context);
                          final quantity = await EnterNumberDialog.show(
                            context,
                            title: ItemTexts.name(item),
                            labelText: 'Количество (0 — убрать)',
                          );
                          if (quantity == null) return;
                          await cubit.setItemQuantity(inventoryItem, quantity);
                          if (quantity == 0) navigator.pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            '×${inventoryItem.quantity}',
                            style: const TextStyle(fontSize: 18, decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.read<PlayerCubit>().addItemQuantity(inventoryItem),
                          icon: const Icon(Icons.add),
                          label: const Text('Добавить'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _details(Player player) {
    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        );
    return switch (item) {
      Weapon item => [
          row('Категория', item.kind.localizedName),
          row('Урон', item.damageText),
          if (item.propertiesText.isNotEmpty) row('Свойства', item.propertiesText),
          row('Владение', player.isProficientWith(item) ? 'есть' : 'нет — бонус мастерства не добавляется к атаке'),
          if (item.cost != null) row('Стоимость', '${item.cost}'),
          if (item.weight != null) row('Вес', '${_formatWeight(item.weight!)} фнт.'),
          for (final slot in WeaponSlot.values)
            if (player.weaponIn(slot) == item) row(slot.labelFor(item), _attackText(player.attackWith(item, slot))),
        ],
      Armor item => [
          row('Тип', item.kind.localizedName),
          row('Класс доспеха', item.protectionText),
          if (item.strengthRequirement != null) row('Сила', '${item.strengthRequirement} (иначе скорость −10 фт.)'),
          if (item.stealthDisadvantage) row('Скрытность', 'помеха'),
          row('Владение', player.armorProficiencies.contains(item.kind.proficiency) ? 'есть' : 'нет'),
          if (item.cost != null) row('Стоимость', '${item.cost}'),
          row('Вес', '${item.weight} фнт.'),
        ],
      Shield item => [
          row('Класс доспеха', '+${item.defense}'),
          if (item.cost != null) row('Стоимость', '${item.cost}'),
          row('Вес', '${item.weight} фнт.'),
        ],
      Tool item => [
          row('Категория', item.category.localizedName),
          row('Стоимость', '${item.price}'),
          if (item.weight != null) row('Вес', '${_formatWeight(item.weight!)} фнт.'),
          if (item.description.isNotEmpty) ...[const Gap(8), HtmlContent(item.description)],
        ],
      Gear item => [
          if (item.group != null) row('Группа', item.group!),
          if (item.cost != null) row('Стоимость', '${item.cost}'),
          if (item.weight != null && item.weight != '—') row('Вес', item.weight!),
        ],
      EquipmentPack item => [
          if (item.cost != null) row('Стоимость', '${item.cost}'),
          const Text('Содержимое:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...item.contents.map((e) => Text('• ${e.text}')),
          const Gap(8),
          const Text(
            'В инвентаре набор раскладывается на отдельные вещи, их количество можно менять.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      CustomInvetoryItem item => [if (item.description.isNotEmpty) Text(item.description)],
      _ => [],
    };
  }

  static String _formatWeight(double weight) =>
      weight == weight.roundToDouble() ? weight.toInt().toString() : weight.toString();

  static String _attackText(WeaponAttack attack) =>
      'атака ${attack.attackBonus >= 0 ? '+' : ''}${attack.attackBonus}, урон ${attack.damage}';

  List<Widget> _equipActions(BuildContext context, Player player) {
    final cubit = context.read<PlayerCubit>();
    Widget action(String label, VoidCallback? onPressed, {String? reason}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(onPressed: onPressed, child: Text(label)),
              if (reason != null)
                Text(reason, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        );
    switch (item) {
      case Weapon weapon:
        final actions = <Widget>[];
        for (final slot in WeaponSlot.values) {
          final label = slot.labelFor(weapon).toLowerCase();
          if (player.weaponIn(slot) == weapon) {
            actions.add(action('Снять: $label', () => cubit.unequipWeapon(slot)));
            continue;
          }
          final reason = player.cannotEquip(weapon, slot);
          if (reason == null) {
            actions.add(action('Взять: $label', () => cubit.equipWeapon(weapon, slot)));
          } else if (!_isObvious(reason)) {
            actions.add(action('Взять: $label', null, reason: reason));
          }
        }
        return actions;
      case Armor armor:
        return [
          player.armor == armor
              ? action('Снять доспех', cubit.unequipArmor)
              : action('Надеть доспех', () => cubit.equipArmor(armor)),
        ];
      case Shield shield:
        return [
          if (player.shield == shield)
            action('Убрать щит', cubit.unequipShield)
          else
            action(
              'Взять щит',
              player.canUseShield ? () => cubit.equipShield(shield) : null,
              reason: player.canUseShield ? null : 'Основное оружие двуручное',
            ),
        ];
      default:
        return [];
    }
  }

  /// Неподходящий тип слота не показываем: у рукопашного оружия нет кнопок дальнего боя.
  static bool _isObvious(String reason) => reason.startsWith('Только');
}
