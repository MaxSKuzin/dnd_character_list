import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class WeaponInfoDialog extends StatelessWidget {
  static Future<void> show(
    BuildContext context, {
    required Weapon weapon,
  }) =>
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: WeaponInfoDialog(
            weapon: weapon,
            weaponSlot: null,
            canUnequip: false,
          ),
        ),
      );

  final Weapon weapon;
  final bool canUnequip;
  final WeaponSlot? weaponSlot;

  const WeaponInfoDialog({
    super.key,
    required this.weapon,
    required this.canUnequip,
    required this.weaponSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            weapon.name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          if (weaponSlot != null)
            Text(
              weaponSlot!.name,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          const Gap(16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Общее',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Тип: ${weapon.kind.name}',
                  ),
                  Text(
                    'Хват: ${weapon.type.name}',
                  ),
                  Text(
                    'Вес: ${weapon.weaponWeight.name}',
                  ),
                  if (weapon.kind.isMelee && weapon.minRange != null && weapon.maxRange != null)
                    const Text(
                      'Метательное',
                    ),
                  if (weapon.isFencing)
                    const Text(
                      'Фехтовальное',
                    ),
                  const Gap(8),
                  const Text(
                    'Урон',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Тип: ${weapon.damageType.name}',
                  ),
                  Text(
                    'Урон: ${weapon.getRawDamageString()}+(${weapon.isFencing || weapon.kind.isRanged ? 'ловкость/сила' : 'сила'})',
                  ),
                  if (weapon.elementalDamage.isNotEmpty)
                    Text(
                      'Доп. урон: ${weapon.elementalDamage.map((e) => '${e.count}${e.damage.name} (${e.type.name})').join(', ')}',
                    ),
                  if (weapon.fixedDamage != null && weapon.fixedDamage != 0)
                    Text(
                      'Фиксированный урон: +${weapon.fixedDamage}',
                    ),
                  if (weapon.twoHandedDamage != null && weapon.type == WeaponType.universal)
                    Text(
                      'Урон в двух руках: ${weapon.getRawDamageString(isTwoHanded: true)}+(${weapon.isFencing ? 'ловкость/сила' : 'сила'})',
                    ),
                  if (weapon.minRange != null && weapon.maxRange != null) ...[
                    const Gap(8),
                    const Text(
                      'Дальность',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Минимальная: ${weapon.minRange}',
                    ),
                    Text(
                      'Максимальная: ${weapon.maxRange}',
                    ),
                  ],
                  if (canUnequip) ...[
                    const Gap(16),
                    ElevatedButton(
                      onPressed: () {
                        switch (weaponSlot!) {
                          case WeaponSlot.mainHand:
                          case WeaponSlot.mainRange:
                            context.read<PlayerCubit>().unequipMainWeapon(weapon);
                          case WeaponSlot.secondHand:
                          case WeaponSlot.secondRange:
                            context.read<PlayerCubit>().unequipSecondaryWeapon(weapon);
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('Снять'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum WeaponSlot {
  mainHand,
  mainRange,
  secondHand,
  secondRange;

  String get name {
    switch (this) {
      case WeaponSlot.mainHand:
        return 'Основная рука';
      case WeaponSlot.mainRange:
        return 'Основное дальнобойное';
      case WeaponSlot.secondHand:
        return 'Вторая рука';
      case WeaponSlot.secondRange:
        return 'Второе дальнобойное';
    }
  }
}
