import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/common/widgets/inter_number_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class HealthSection extends StatefulWidget {
  const HealthSection({
    super.key,
  });

  @override
  State<HealthSection> createState() => _HealthSectionState();
}

class _HealthSectionState extends State<HealthSection> {
  @override
  Widget build(BuildContext context) {
    final hits = PlayerModel.health(context);
    final isDead = PlayerModel.isDead(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: LabeledBorder(
            backgroundColor: context.customColors?.cardColor,
            text: 'Очки здоровья, текущие',
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: 'Очки здоровья, макс. '),
                        TextSpan(
                          text: '${hits.$2}',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    isDead ? '💀' : '${hits.$1}',
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(8),
                ],
              ),
            ),
          ),
        ),
        const Gap(16),
        Expanded(
          child: Theme(
            data: context.theme.copyWith(
              filledButtonTheme: FilledButtonThemeData(
                style: context.theme.filledButtonTheme.style?.copyWith(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton(
                  onPressed: () async {
                    final damage = await InterNumberDialog.show(
                      context,
                      title: 'Введите полученный урон',
                      labelText: 'Урон',
                    );
                    if (!mounted || damage == null) return;
                    context.read<PlayerCubit>().takeDamage(damage);
                  },
                  child: const Text('Урон'),
                ),
                const Gap(16),
                FilledButton(
                  onPressed: () async {
                    final health = await InterNumberDialog.show(
                      context,
                      title: 'Введите здоровье для восстановления',
                      labelText: 'Лечение',
                    );
                    if (!mounted || health == null) return;
                    context.read<PlayerCubit>().heal(health);
                  },
                  child: const Text('Лечение'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
