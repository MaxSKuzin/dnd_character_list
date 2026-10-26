import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Текущие хиты: «−» — ввод урона, «+» — ввод лечения.
class HealthSection extends StatelessWidget {
  const HealthSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hits = PlayerModel.health(context);
    final isDead = PlayerModel.isDead(context);
    return InfoTile(
      label: 'Здоровье',
      value: isDead ? '💀' : '${hits.current}',
      caption: 'из ${hits.max}',
      valueStyle: context.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      decreaseTooltip: 'Урон',
      increaseTooltip: 'Лечение',
      onDecrease: () async {
        final cubit = context.read<PlayerCubit>();
        final damage = await EnterNumberDialog.show(context, title: 'Введите полученный урон', labelText: 'Урон');
        if (damage != null) cubit.takeDamage(damage);
      },
      onIncrease: () async {
        final cubit = context.read<PlayerCubit>();
        final health = await EnterNumberDialog.show(
          context,
          title: 'Введите здоровье для восстановления',
          labelText: 'Лечение',
        );
        if (health != null) cubit.heal(health);
      },
    );
  }
}
