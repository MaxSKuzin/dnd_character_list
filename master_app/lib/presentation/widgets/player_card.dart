import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';

/// Игрок сессии: классы, хиты, КД, инициатива, ячейки и ресурсы.
class PlayerCard extends StatelessWidget {
  final SessionPlayer player;

  /// Убрать игрока из сессии. Кнопка показывается, только когда игрок не на связи; `null` — без кнопки.
  final VoidCallback? onRemove;

  const PlayerCard({super.key, required this.player, this.onRemove});

  static String _signed(int value) => value >= 0 ? '+$value' : '$value';

  @override
  Widget build(BuildContext context) {
    final profile = player.profile;
    final state = player.state;
    final theme = Theme.of(context);
    final hitsRatio = profile.maxHits == 0 ? 0.0 : (state.currentHits / profile.maxHits).clamp(0.0, 1.0);

    return Opacity(
      opacity: player.isConnected ? 1 : 0.5,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(player.isConnected ? Icons.wifi : Icons.wifi_off, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(profile.name, style: theme.textTheme.titleMedium)),
                  if (!player.isConnected && onRemove != null)
                    IconButton(tooltip: 'Убрать из сессии', onPressed: onRemove, icon: const Icon(Icons.close)),
                ],
              ),
              Text(profile.classes.map((e) => '${e.name} ${e.level}').join(' / '), style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: hitsRatio,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: hitsRatio > 0.5 ? Colors.green : (hitsRatio > 0.25 ? Colors.orange : Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${state.currentHits}/${profile.maxHits}'),
                ],
              ),
              if (state.isDead)
                Text('Мёртв', style: TextStyle(color: theme.colorScheme.error))
              else if (state.isKnockedOut)
                const Text('Нокаут: 1 хит, без сознания')
              else if (state.currentHits <= 0)
                Text('Спасброски от смерти: ✓${state.deathSuccesses} ✗${state.deathFailures}'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text('КД ${profile.armorClass}'),
                  Text('Иниц. ${_signed(profile.initiative)}'),
                  Text('Скор. ${profile.speed}'),
                  Text('Пасс. вним. ${profile.passivePerception}'),
                  for (final slot in state.spellSlots.entries)
                    Text('${slot.key} ур. ${slot.value.current}/${slot.value.max}'),
                  for (final counter in state.counters.entries)
                    Text('${counter.key} ${counter.value.current}/${counter.value.max}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
