import 'package:dnd_character_list/data/session/session_source.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Бой у мастера на экране боя: раунд, чей ход и кто следующий. Нажатие открывает всю очередь.
/// В свой ход полоска подсвечена (вибрацию при смене хода даёт `MainFlow`, она работает на любой вкладке).
class BattleQueueBar extends StatelessWidget {
  const BattleQueueBar({super.key});

  static final _source = getIt<SessionSource>();

  String _name(BattleEntry entry) => _source.isMe(entry.id) ? 'Вы' : entry.name;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BattleSnapshot?>(
      stream: _source.battleStream,
      initialData: _source.battle,
      builder: (context, snapshot) {
        final battle = snapshot.data;
        if (battle == null || !_source.isJoined(PlayerModel.getPlayer(context))) return const SizedBox();
        final current = battle.current;
        final next = battle.next;
        final myTurn = current != null && _source.isMe(current.id);
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: myTurn ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: myTurn ? theme.colorScheme.primary : Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _BattleQueueSheet.show(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Text('Раунд ${battle.round}', style: theme.textTheme.labelLarge),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            myTurn ? 'Ваш ход!' : 'Ходит: ${current == null ? '—' : current.name}',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (next != null)
                            Text('Далее: ${_name(next)}',
                                style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const Icon(Icons.format_list_numbered),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Вся очередь боя: инициатива, метки монстров, текущий ход.
class _BattleQueueSheet extends StatelessWidget {
  const _BattleQueueSheet();

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const _BattleQueueSheet(),
      );

  /// Цвета меток — как в приложении мастера (`MonsterMarker`).
  static Color? _markerColor(String? marker) => switch (marker) {
        'red' => Colors.red,
        'blue' => Colors.blue,
        'green' => Colors.green,
        'yellow' => Colors.yellow,
        'purple' => Colors.purple,
        'orange' => Colors.orange,
        'white' => Colors.white,
        'black' => Colors.black,
        _ => null,
      };

  /// Союзник в нокауте приходит в себя: мастер передаёт это его устройству.
  static void _revive(BuildContext context, BattleEntry entry) {
    final sent = getIt<SessionSource>().revive(entry.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sent ? 'Вы приводите в чувство: ${entry.name}' : 'Нет связи с мастером')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = getIt<SessionSource>();
    return SafeArea(
      child: StreamBuilder<BattleSnapshot?>(
        stream: source.battleStream,
        initialData: source.battle,
        builder: (context, snapshot) {
          final battle = snapshot.data;
          if (battle == null) {
            return const Padding(padding: EdgeInsets.all(32), child: Text('Бой закончен', textAlign: TextAlign.center));
          }
          final theme = Theme.of(context);
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (context, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                Text('Раунд ${battle.round}', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                const Gap(8),
                for (final entry in battle.entries)
                  Opacity(
                    opacity: entry.isOut ? 0.4 : 1,
                    child: ListTile(
                      selected: entry.id == battle.currentId,
                      selectedTileColor: theme.colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      leading: SizedBox(
                        width: 32,
                        child: Text(
                          entry.initiative?.toString() ?? '—',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      title: Text(
                        source.isMe(entry.id) ? '${entry.name} (вы)' : entry.name,
                        style: TextStyle(decoration: entry.isOut ? TextDecoration.lineThrough : null),
                      ),
                      subtitle: entry.isKnockedOut || entry.statuses.isNotEmpty
                          ? Text([if (entry.isKnockedOut) 'Нокаут', ...entry.statuses.map((e) => e.label)].join(', '))
                          : null,
                      trailing: entry.isKnockedOut && !source.isMe(entry.id)
                          ? TextButton(
                              onPressed: () => _revive(context, entry),
                              child: const Text('Привести\nв чувство', textAlign: TextAlign.center),
                            )
                          : entry.isPlayer
                              ? const Icon(Icons.person)
                              : Icon(Icons.circle, color: _markerColor(entry.marker)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
