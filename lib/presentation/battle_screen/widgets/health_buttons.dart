import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class HealthButtons extends StatefulWidget {
  const HealthButtons({
    super.key,
  });

  @override
  State<HealthButtons> createState() => _HealthButtonsState();
}

class _HealthButtonsState extends State<HealthButtons> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.theme.copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: context.theme.filledButtonTheme.style?.copyWith(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () async {
                final damage = await EnterNumberDialog.show(
                  context,
                  title: 'Введите полученный урон',
                  labelText: 'Урон',
                );
                if (!mounted || damage == null) return;
                context.read<PlayerCubit>().takeDamage(damage);
              },
              child: const Text('Урон'),
            ),
          ),
          const Gap(8),
          Expanded(
            child: FilledButton(
              onPressed: () async {
                final health = await EnterNumberDialog.show(
                  context,
                  title: 'Введите здоровье для восстановления',
                  labelText: 'Лечение',
                );
                if (!mounted || health == null) return;
                context.read<PlayerCubit>().heal(health);
              },
              child: const Text('Лечение'),
            ),
          ),
        ],
      ),
    );
  }
}
