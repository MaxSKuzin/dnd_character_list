import 'package:dnd_character_list/data/session/session_source.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';

/// Эффекты на персонаже от мастера на экране боя: «Отравлен», «Удивлён · 2 хода». Нажатие — описание.
class StatusesBar extends StatelessWidget {
  const StatusesBar({super.key});

  @override
  Widget build(BuildContext context) {
    final source = getIt<SessionSource>();
    return StreamBuilder<List<StatusEffect>>(
      stream: source.statusesStream,
      initialData: source.statuses,
      builder: (context, snapshot) {
        final statuses = snapshot.requireData;
        if (statuses.isEmpty || !source.isJoined(PlayerModel.getPlayer(context))) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in statuses)
                ActionChip(
                  avatar: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(status.label),
                  onPressed: () => showStatusDescription(context, status),
                ),
            ],
          ),
        );
      },
    );
  }
}

Future<void> showStatusDescription(BuildContext context, StatusEffect status) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status.title),
        content: Text(
          [
            if (status.description.isNotEmpty) status.description,
            status.turns == null ? 'Пока мастер не снимет.' : 'Осталось: ${turnsLabel(status.turns!)}.',
          ].join('\n\n'),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Понятно'))],
      ),
    );
