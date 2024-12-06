import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/common/widgets/separated_column.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

//TODO: refactor

class WeaponsSection extends StatelessWidget {
  const WeaponsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // ref to stats to recalculate damage on change
    PlayerModel.proficiencyBonus(context);
    PlayerModel.stats(context);
    final player = PlayerModel.getPlayer(context);
    final weapons = PlayerModel.weapons(context);
    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'Атаки',
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
            ...weapons.map(
              (e) {
                return [
                  Row(
                    children: [
                      Expanded(
                        child: LabeledBorder(
                          backgroundColor: context.theme.scaffoldBackgroundColor,
                          text:
                              (e.type == WeaponType.universal ? WeaponType.oneHanded.name : e.type.name).toUpperCase(),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                            child: Center(
                              child: Text(
                                e.name,
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
                                e.getHitString(player),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: LabeledBorder(
                          backgroundColor: context.theme.scaffoldBackgroundColor,
                          text: e.damageType.name.toUpperCase(),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                            child: Center(
                              child: Text(e.getDamageString(player)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (e.type == WeaponType.universal)
                    Row(
                      children: [
                        Expanded(
                          child: LabeledBorder(
                            backgroundColor: context.theme.scaffoldBackgroundColor,
                            text: WeaponType.twoHanded.name.toUpperCase(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                              child: Center(
                                child: Text(
                                  e.name,
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
                                  e.getHitString(player),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: LabeledBorder(
                            backgroundColor: context.theme.scaffoldBackgroundColor,
                            text: e.damageType.name.toUpperCase(),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                              child: Center(
                                child: Text(
                                  e.getDamageString(
                                    player,
                                    isTwoHanded: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ];
              },
            ).expand((e) => e),
          ],
        ),
      ),
    );
  }
}
