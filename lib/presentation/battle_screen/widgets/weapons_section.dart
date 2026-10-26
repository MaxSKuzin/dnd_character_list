import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/martial_arts_dice.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/common/widgets/separated_column.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/item_texts.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/inventory_screen/widgets/item_details_sheet.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Атаки экипированным оружием; оружие меняется во вкладке инвентаря.
class WeaponsSection extends StatelessWidget {
  const WeaponsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.watch(context);
    final attacks = player.attacks;
    final perAction = player.attacksPerAction;
    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      // «Дополнительная атака»: сколько атак даёт действие «Атака».
      text: perAction > 1 ? 'АТАКИ · $perAction ЗА ДЕЙСТВИЕ' : 'АТАКИ',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: attacks.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: Text('Оружие не экипировано. Возьмите его во вкладке инвентаря.', textAlign: TextAlign.center),
              )
            : SeparatedColumn(
                separatorBuilder: (context, index) => const Gap(8),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Expanded(child: Text('Название', textAlign: TextAlign.center)),
                      Gap(8),
                      Expanded(child: Text('Бросок атаки', textAlign: TextAlign.center)),
                      Gap(8),
                      Expanded(child: Text('Урон/тип', textAlign: TextAlign.center)),
                    ],
                  ),
                  ...attacks.map((e) => _AttackWidget(e)),
                ],
              ),
      ),
    );
  }
}

class _AttackWidget extends StatelessWidget {
  final WeaponAttack attack;

  const _AttackWidget(this.attack);

  bool get isUnarmed => attack.weapon == unarmedStrike;

  @override
  Widget build(BuildContext context) {
    final cell = context.theme.scaffoldBackgroundColor;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => isUnarmed ? MartialArtsDice.showDescription(context) : ItemDetailsSheet.show(context, attack.weapon),
      child: Row(
        children: [
          Expanded(
            child: LabeledBorder(
              backgroundColor: cell,
              text: (isUnarmed ? 'Без оружия' : attack.slot.labelFor(attack.weapon)).toUpperCase(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Center(child: Text(attack.weapon.name, textAlign: TextAlign.center)),
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: LabeledBorder(
              backgroundColor: cell,
              text: '1${Dice.k20.name} ${attack.ability.localizedName.substring(0, 3).toUpperCase()}'
                  '${attack.hasDisadvantage ? ' · ПОМЕХА' : ''}',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Center(
                  child: Text(
                    '${attack.attackBonus >= 0 ? '+' : ''}${attack.attackBonus}',
                    style: TextStyle(color: attack.isProficient ? null : Colors.orangeAccent),
                  ),
                ),
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: LabeledBorder(
              backgroundColor: cell,
              text: (attack.weapon.damageType?.localizedName ?? '—').toUpperCase(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Center(child: Text(attack.damage, textAlign: TextAlign.center)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
