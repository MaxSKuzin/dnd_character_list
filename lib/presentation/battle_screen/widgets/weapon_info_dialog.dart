import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:flutter/material.dart';
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
          ),
        ),
      );

  final Weapon weapon;

  const WeaponInfoDialog({
    super.key,
    required this.weapon,
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
                    'Урон: ${weapon.getDamageString()}+(${weapon.isFencing ? 'ловкость/сила' : 'сила'})',
                  ),
                  if (weapon.fixedDamage != null)
                    Text(
                      'Фиксированный урон: +${weapon.fixedDamage}',
                    ),
                  if (weapon.twoHandedDamage != null && weapon.type == WeaponType.universal)
                    Text(
                      'Урон в двух руках: ${weapon.getDamageString(isTwoHanded: true)}+(${weapon.isFencing ? 'ловкость/сила' : 'сила'})',
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
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
