import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/martial_arts_dice.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/item_texts.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/item_details_sheet.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Атаки экипированным оружием — по карточке на атаку; оружие меняется во вкладке инвентаря.
class WeaponsSection extends StatelessWidget {
  const WeaponsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.watch(context);
    final attacks = player.attacks;
    final perAction = player.attacksPerAction;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: SheetSectionTitle(
            icon: Icons.sports_martial_arts,
            title: 'Оружие',
            // «Дополнительная атака»: сколько атак даёт действие «Атака».
            trailing: perAction > 1 ? SheetBadge('$perAction атаки за действие') : null,
          ),
        ),
        if (attacks.isEmpty)
          const SheetCard(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Оружие не экипировано. Возьмите его во вкладке инвентаря.', textAlign: TextAlign.center),
            ),
          )
        else
          for (final (index, attack) in attacks.indexed) ...[
            if (index > 0) const Gap(8),
            _AttackCard(attack),
          ],
      ],
    );
  }
}

/// Атака: слева бонус к броску, справа оружие и урон — каждая часть урона своим типом.
class _AttackCard extends StatelessWidget {
  final WeaponAttack attack;

  const _AttackCard(this.attack);

  bool get _isUnarmed => attack.weapon == unarmedStrike;

  @override
  Widget build(BuildContext context) {
    final weapon = attack.weapon;
    final notes = [
      _isUnarmed ? 'Без оружия' : attack.slot.labelFor(weapon),
      attack.ability.localizedName,
      if (attack.isTwoHanded && weapon.type == WeaponType.universal) 'двумя руками',
    ];
    final warnings = [
      if (!attack.isProficient) 'без владения',
      if (attack.hasDisadvantage) 'помеха',
    ];
    final damageTypeName = weapon.damageType?.localizedName.toLowerCase();
    return SheetCard(
      onTap: () => _isUnarmed ? MartialArtsDice.showDescription(context) : ItemDetailsSheet.show(context, weapon),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AttackBonus(bonus: attack.attackBonus, isProficient: attack.isProficient),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(weapon.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Gap(2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: notes.join(' · ')),
                        if (warnings.isNotEmpty)
                          TextSpan(
                            text: ' · ${warnings.join(' · ')}',
                            style: const TextStyle(color: Colors.orangeAccent),
                          ),
                      ],
                    ),
                    style: context.theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
                  ),
                  const Gap(8),
                  // Каждая часть урона — отдельно со своим типом: монстр может быть иммунен или уязвим к одной из них.
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _DamageChip(value: attack.damage, type: damageTypeName),
                      for (final extra in attack.extraDamage)
                        _DamageChip(
                          value: '+${extra.count}${extra.damage.name}',
                          type: extra.type.localizedName.toLowerCase(),
                          color: extra.type.color,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

/// Бонус к броску атаки крупно, как КД в экипировке. Без владения — оранжевым.
class _AttackBonus extends StatelessWidget {
  final int bonus;
  final bool isProficient;

  const _AttackBonus({required this.bonus, required this.isProficient});

  @override
  Widget build(BuildContext context) {
    final color = isProficient ? null : Colors.orangeAccent;
    return Container(
      // Не меньше 56×56, но растёт с крупным системным шрифтом.
      constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        border: Border.all(color: color ?? Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${bonus >= 0 ? '+' : ''}$bonus',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text('атака', style: context.theme.textTheme.labelSmall?.copyWith(color: Colors.white60)),
        ],
      ),
    );
  }
}

/// Часть урона: «1к8 + 3 рубящий», «+2к6 огонь». Стихии — своим цветом.
class _DamageChip extends StatelessWidget {
  final String value;
  final String? type;
  final Color? color;

  const _DamageChip({required this.value, required this.type, this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color?.withValues(alpha: 0.12),
        border: Border.all(color: color ?? Colors.white38),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (type != null) TextSpan(text: ' $type', style: TextStyle(color: color ?? Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
