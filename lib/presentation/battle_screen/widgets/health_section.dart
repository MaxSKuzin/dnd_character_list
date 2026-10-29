import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/concentration_banner.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Текущие хиты: «−» — ввод урона, «+» — ввод лечения. На 0 хитах урон добавляет провал спасброска от смерти —
/// спрашивается, было ли попадание критическим (два провала). После урона — напоминание о концентрации.
class HealthSection extends StatelessWidget {
  const HealthSection({super.key});

  static Future<void> _damage(BuildContext context) async {
    final cubit = context.read<PlayerCubit>();
    final damage = await EnterNumberDialog.show(context, title: 'Введите полученный урон', labelText: 'Урон');
    if (damage == null || !context.mounted) return;
    final before = cubit.state;
    var critical = false;
    if (before.currentHits == 0 && !before.isDead && damage > before.tempHits) {
      final answer = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Урон на 0 хитах'),
          content: const Text('Каждый урон — провал спасброска от смерти, критическое попадание — два.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Обычное')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Критическое')),
          ],
        ),
      );
      if (answer == null) return;
      critical = answer;
    }
    cubit.takeDamage(damage, critical: critical);
    final notice = concentrationNotice(before, cubit.state, damage);
    if (notice != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(notice)));
    }
  }

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
      onDecrease: () => _damage(context),
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
