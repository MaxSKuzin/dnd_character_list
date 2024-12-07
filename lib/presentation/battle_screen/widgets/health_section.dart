import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

    return Theme(
      data: context.theme.copyWith(
        iconButtonTheme: IconButtonThemeData(
          style: context.theme.iconButtonTheme.style?.copyWith(
            backgroundColor: const WidgetStatePropertyAll(Colors.amber),
            iconColor: const WidgetStatePropertyAll(Colors.amber),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      child: LabeledBorder(
        backgroundColor: context.customColors?.cardColor,
        text: 'ЗДОРОВЬЕ (МАКС. ${hits.max})',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  final damage = await EnterNumberDialog.show(
                    context,
                    title: 'Введите полученный урон',
                    labelText: 'Урон',
                  );
                  if (!mounted || damage == null) return;
                  context.read<PlayerCubit>().takeDamage(damage);
                },
                icon: const Text('-'),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    isDead ? '💀' : '${hits.current}',
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  final health = await EnterNumberDialog.show(
                    context,
                    title: 'Введите здоровье для восстановления',
                    labelText: 'Лечение',
                  );
                  if (!mounted || health == null) return;
                  context.read<PlayerCubit>().heal(health);
                },
                icon: const Text('+'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
