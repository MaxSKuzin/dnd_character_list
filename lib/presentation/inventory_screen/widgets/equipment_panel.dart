import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/item_texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Надетые доспех, щит и оружие: класс доспеха и атаки пересчитываются при смене снаряжения.
class EquipmentPanel extends StatelessWidget {
  const EquipmentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, Player>(
      builder: (context, player) {
        final armorClass = player.armorClass;
        final warnings = [
          if (!player.isArmorProficient)
            'Нет владения доспехом: помеха на проверки, спасброски и атаки по Силе и Ловкости, нельзя накладывать заклинания.',
          if (!player.isShieldProficient) 'Нет владения щитом: помеха на проверки, спасброски и атаки по Силе и Ловкости.',
          if (player.isArmorTooHeavy) 'Сила ниже ${player.armor!.strengthRequirement}: скорость уменьшена на 10 футов.',
          if (player.armor?.stealthDisadvantage ?? false) 'Доспех даёт помеху на проверки Ловкости (Скрытность).',
        ];
        return LabeledBorder(
          backgroundColor: context.customColors?.cardColor,
          text: 'ЭКИПИРОВКА',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${armorClass.value}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text('КД', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        armorClass.parts
                            .map((e) => '${e.$1} ${e.$2 >= 0 && e != armorClass.parts.first ? '+' : ''}${e.$2}')
                            .join(' · '),
                      ),
                    ),
                  ],
                ),
                for (final warning in warnings)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(warning, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                  ),
                const Gap(8),
                _SlotTile(
                  icon: Icons.shield_outlined,
                  title: 'Доспех',
                  value: player.armor?.name,
                  details: player.armor == null ? null : 'КД ${player.armor!.protectionText}',
                  onTap: () => _pick<Armor>(
                    context,
                    title: 'Доспех',
                    current: player.armor,
                    candidates: player.inventory.items.map((e) => e.item).whereType<Armor>().toList(),
                    onSelect: (armor) => context.read<PlayerCubit>().equipArmor(armor),
                    onRemove: () => context.read<PlayerCubit>().unequipArmor(),
                  ),
                ),
                _SlotTile(
                  icon: Icons.security,
                  title: 'Щит',
                  value: player.shield?.name,
                  details: player.shield == null ? null : 'КД +${player.shield!.defense}',
                  onTap: () => _pick<Shield>(
                    context,
                    title: 'Щит',
                    current: player.shield,
                    candidates: player.inventory.items.map((e) => e.item).whereType<Shield>().toList(),
                    reason: (_) => player.canUseShield ? null : 'Основное оружие двуручное',
                    onSelect: (shield) => context.read<PlayerCubit>().equipShield(shield),
                    onRemove: () => context.read<PlayerCubit>().unequipShield(),
                  ),
                ),
                for (final slot in WeaponSlot.values)
                  if (slot.isMain || player.weaponIn(slot) != null || _hasCandidates(player, slot))
                    _weaponSlot(context, player, slot),
              ],
            ),
          ),
        );
      },
    );
  }

  static List<Weapon> _weapons(Player player) =>
      player.inventory.items.map((e) => e.item).whereType<Weapon>().toList();

  static bool _hasCandidates(Player player, WeaponSlot slot) =>
      _weapons(player).any((e) => player.cannotEquip(e, slot) == null);

  Widget _weaponSlot(BuildContext context, Player player, WeaponSlot slot) {
    final weapon = player.weaponIn(slot);
    final attack = weapon == null ? null : player.attackWith(weapon, slot);
    return _SlotTile(
      icon: slot == WeaponSlot.mainHand || slot == WeaponSlot.secondHand ? Icons.sports_martial_arts : Icons.gps_fixed,
      title: slot.labelFor(weapon),
      value: weapon?.name,
      details: attack == null
          ? null
          : 'Атака ${attack.attackBonus >= 0 ? '+' : ''}${attack.attackBonus} · урон ${attack.damage}'
              '${attack.isTwoHanded && weapon!.twoHandedDamage != null ? ' (двумя руками)' : ''}',
      warning: attack == null || attack.isProficient ? null : 'Нет владения: бонус мастерства не добавляется',
      onTap: () => _pick<Weapon>(
        context,
        title: slot.localizedName,
        current: weapon,
        candidates: _weapons(player).where((e) => !(player.cannotEquip(e, slot)?.startsWith('Только') ?? false)).toList(),
        reason: (e) => player.cannotEquip(e, slot),
        onSelect: (weapon) => context.read<PlayerCubit>().equipWeapon(weapon, slot),
        onRemove: () => context.read<PlayerCubit>().unequipWeapon(slot),
      ),
    );
  }

  /// Выбор предмета из инвентаря для слота; недоступные варианты показываются с причиной.
  Future<void> _pick<T extends Object>(
    BuildContext context, {
    required String title,
    required T? current,
    required List<T> candidates,
    required void Function(T item) onSelect,
    required VoidCallback onRemove,
    String? Function(T item)? reason,
  }) =>
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              ),
              if (current != null)
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text('Снять: ${ItemTexts.name(current)}'),
                  onTap: () {
                    onRemove();
                    Navigator.of(sheetContext).pop();
                  },
                ),
              if (candidates.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('В инвентаре нет подходящих предметов', textAlign: TextAlign.center),
                ),
              for (final item in candidates.toSet())
                if (item != current)
                  Builder(builder: (context) {
                    final disabled = reason?.call(item);
                    return ListTile(
                      enabled: disabled == null,
                      title: Text(ItemTexts.name(item)),
                      subtitle: Text(disabled ?? ItemTexts.subtitle(item) ?? ''),
                      onTap: () {
                        onSelect(item);
                        Navigator.of(sheetContext).pop();
                      },
                    );
                  }),
            ],
          ),
        ),
      );
}

class _SlotTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final String? details;
  final String? warning;
  final VoidCallback onTap;

  const _SlotTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.details,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: value == null ? Colors.white38 : null),
      title: Text(value ?? '—', style: TextStyle(color: value == null ? Colors.white38 : null)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.theme.textTheme.bodySmall),
          if (details != null) Text(details!),
          if (warning != null) Text(warning!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
        ],
      ),
      trailing: const Icon(Icons.swap_horiz),
      onTap: onTap,
    );
  }
}
