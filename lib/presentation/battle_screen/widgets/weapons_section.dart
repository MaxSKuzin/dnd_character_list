import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapon_info_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/common/widgets/separated_column.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

//TODO: refactor

class WeaponsSection extends StatelessWidget {
  const WeaponsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // ref to stats to recalculate damage on change
    PlayerModel.proficiencyBonus(context);
    PlayerModel.stats(context);
    final mainWeapon = PlayerModel.mainWeapon(context);
    final secondWeapon = PlayerModel.secondWeapon(context);
    final mainRangeWeapon = PlayerModel.mainRangeWeapon(context);
    final secondRangeWeapon = PlayerModel.secondRangeWeapon(context);
    final shield = PlayerModel.shield(context);
    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'АТАКИ',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SeparatedColumn(
          separatorBuilder: (context, index) => const Gap(8),
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Название',
                    textAlign: TextAlign.center,
                  ),
                ),
                Gap(8),
                Expanded(
                  child: Text(
                    'Бросок атаки',
                    textAlign: TextAlign.center,
                  ),
                ),
                Gap(8),
                Expanded(
                  child: Text(
                    'Урон/тип',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            if (mainWeapon != null)
              _WeaponWidget(
                mainWeapon,
                isMain: true,
                isTwoHanded: secondWeapon == null && shield == null,
              ),
            if (secondWeapon != null)
              _WeaponWidget(
                secondWeapon,
                isMain: false,
                isTwoHanded: false,
              ),
            if (mainRangeWeapon != null)
              _WeaponWidget(
                mainRangeWeapon,
                isMain: true,
                isTwoHanded: secondRangeWeapon == null,
              ),
            if (secondRangeWeapon != null)
              _WeaponWidget(
                secondRangeWeapon,
                isMain: false,
                isTwoHanded: false,
              ),
          ],
        ),
      ),
    );
  }
}

class _WeaponWidget extends StatelessWidget {
  final Weapon weapon;
  final bool isTwoHanded;
  final bool isMain;

  const _WeaponWidget(
    this.weapon, {
    super.key,
    required this.isTwoHanded,
    required this.isMain,
  });

  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.getPlayer(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<PlayerCubit>(),
          child: Dialog(
            shape: const RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.white,
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: WeaponInfoDialog(
              weapon: weapon,
              canUnequip: true,
              weaponSlot: isMain
                  ? weapon.kind.isMelee
                      ? WeaponSlot.mainHand
                      : WeaponSlot.mainRange
                  : weapon.kind.isMelee
                      ? WeaponSlot.secondHand
                      : WeaponSlot.secondRange,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: LabeledBorder(
              backgroundColor: context.theme.scaffoldBackgroundColor,
              text: (weapon.type == WeaponType.universal ? WeaponType.oneHanded.name : weapon.type.name).toUpperCase(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Center(
                  child: Text(
                    weapon.name,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: LabeledBorder(
              backgroundColor: context.theme.scaffoldBackgroundColor,
              text: '1${Dice.k20.name}',
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Center(
                  child: Text(
                    weapon.getHitString(player),
                  ),
                ),
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: LabeledBorder(
              backgroundColor: context.theme.scaffoldBackgroundColor,
              text: weapon.damageType.name.toUpperCase(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Center(
                  child: Text(
                    weapon.getDamageString(
                      player,
                      isTwoHanded: isTwoHanded,
                      isMain: isMain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
