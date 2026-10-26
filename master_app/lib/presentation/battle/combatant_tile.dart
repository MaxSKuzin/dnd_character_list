import 'package:dnd_master/domain/bloc/battle_cubit.dart';
import 'package:dnd_master/domain/models/battle.dart';
import 'package:dnd_master/presentation/battle/statuses_section.dart';
import 'package:dnd_master/presentation/common/number_dialogs.dart';
import 'package:dnd_master/presentation/extensions/monster_marker_colors.dart';
import 'package:dnd_master/presentation/monsters/monster_stat_block.dart';
import 'package:dnd_master/presentation/widgets/player_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Урон или лечение участника. Хиты игрока меняются на его устройстве — если он не на связи, мастер видит
/// предупреждение.
Future<void> changeCombatantHits(BuildContext context, Combatant combatant) async {
  final cubit = context.read<BattleCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final delta = await askHitsChange(context, title: '${combatant.name}: ${combatant.currentHits}/${combatant.maxHits}');
  if (delta == null) return;
  if (!cubit.changeHits(combatant, delta)) {
    messenger.showSnackBar(SnackBar(content: Text('${combatant.name} не на связи — хиты не изменены')));
  }
}

/// Участник в очереди инициативы: значение инициативы, КД, хиты. Текущий ход подсвечен.
class CombatantTile extends StatelessWidget {
  final Combatant combatant;
  final int? initiative;
  final bool isCurrent;

  const CombatantTile({super.key, required this.combatant, required this.initiative, required this.isCurrent});

  bool get _isKnockedOut => switch (combatant) {
    PlayerCombatant(:final player) => player.state.isKnockedOut,
    MonsterCombatant() => false,
  };

  static String _signed(int value) => value >= 0 ? '+$value' : '$value';

  Future<void> _editInitiative(BuildContext context) async {
    final cubit = context.read<BattleCubit>();
    final bonus = combatant.initiativeBonus;
    final value = await askNumber(
      context,
      title: 'Инициатива: ${combatant.name}',
      hint: 'Результат броска к20 ${bonus >= 0 ? '+' : '−'} ${bonus.abs()}',
      initial: initiative,
    );
    if (value != null) cubit.setInitiative(combatant.id, value);
  }

  void _openDetails(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => switch (combatant) {
      PlayerCombatant() => _PlayerSheet(combatant.id),
      MonsterCombatant() => _MonsterSheet(combatant.id),
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final combatant = this.combatant;
    final hitsRatio = combatant.maxHits == 0 ? 0.0 : (combatant.currentHits / combatant.maxHits).clamp(0.0, 1.0);

    return Opacity(
      opacity: combatant.isOut ? 0.4 : 1,
      child: Card(
        color: isCurrent ? theme.colorScheme.primaryContainer : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _editInitiative(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      initiative?.toString() ?? _signed(combatant.initiativeBonus),
                      style: initiative == null
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (combatant case MonsterCombatant(:final monster))
                            MonsterMarkerBadge(marker: monster.marker, number: monster.number)
                          else
                            const Icon(Icons.person, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              combatant.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                decoration: combatant.isOut ? TextDecoration.lineThrough : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (combatant case PlayerCombatant(:final player) when !player.isConnected)
                            const Icon(Icons.wifi_off, size: 16),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('КД ${combatant.armorClass}'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: hitsRatio,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                              color: hitsRatio > 0.5 ? Colors.green : (hitsRatio > 0.25 ? Colors.orange : Colors.red),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${combatant.currentHits}/${combatant.maxHits}'),
                        ],
                      ),
                      if (combatant.statuses.isNotEmpty || _isKnockedOut) ...[
                        const SizedBox(height: 4),
                        Text(
                          [if (_isKnockedOut) 'Нокаут', ...combatant.statuses.map((e) => e.label)].join(', '),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.tertiary),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Урон или лечение',
                  onPressed: () => changeCombatantHits(context, combatant),
                  icon: const Icon(Icons.healing),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Статблок монстра в бою: его хиты, урон и лечение, удаление из боя.
class _MonsterSheet extends StatelessWidget {
  final String monsterId;

  const _MonsterSheet(this.monsterId);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BattleCubit, BattleState>(
      builder: (context, state) {
        final monster = state.order.whereType<MonsterCombatant>().where((e) => e.id == monsterId).firstOrNull;
        if (monster == null) return const SizedBox();
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            builder: (context, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                Text(monster.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                _MarkerEditor(monster: monster.monster),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => changeCombatantHits(context, monster),
                        icon: const Icon(Icons.healing),
                        label: Text('Хиты ${monster.currentHits}/${monster.maxHits}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<BattleCubit>().removeMonster(monster.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Убрать'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StatusesSection(combatantId: monster.id, statuses: monster.statuses),
                const SizedBox(height: 16),
                MonsterStatBlock(monster: monster.monster.template, hits: '${monster.currentHits}/${monster.maxHits}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Метка и прозвище монстра, чтобы отличать его от таких же: «Гоблин 2 «с луком»», красная метка.
class _MarkerEditor extends StatefulWidget {
  final BattleMonster monster;

  const _MarkerEditor({required this.monster});

  @override
  State<_MarkerEditor> createState() => _MarkerEditorState();
}

class _MarkerEditorState extends State<_MarkerEditor> {
  late final _labelController = TextEditingController(text: widget.monster.label ?? '');

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _save({MonsterMarker? marker}) => context.read<BattleCubit>().markMonster(
    widget.monster.id,
    marker: marker ?? widget.monster.marker,
    label: _labelController.text,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final marker in MonsterMarker.values)
              Tooltip(
                message: marker.localizedName,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _save(marker: marker),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: marker == widget.monster.marker
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: MonsterMarkerBadge(marker: marker, number: widget.monster.number, size: 32),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _labelController,
          decoration: const InputDecoration(labelText: 'Прозвище', hintText: 'с луком, вожак, раненый'),
          onChanged: (_) => _save(),
        ),
      ],
    );
  }
}

/// Игрок в бою: его карточка, урон и лечение, эффекты.
class _PlayerSheet extends StatelessWidget {
  final String playerId;

  const _PlayerSheet(this.playerId);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BattleCubit, BattleState>(
      builder: (context, state) {
        final player = state.order.whereType<PlayerCombatant>().where((e) => e.id == playerId).firstOrNull;
        if (player == null) return const SizedBox();
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (context, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                PlayerCard(player: player.player),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: player.player.isConnected ? () => changeCombatantHits(context, player) : null,
                  icon: const Icon(Icons.healing),
                  label: Text(player.player.isConnected ? 'Урон или лечение' : 'Игрок не на связи'),
                ),
                if (player.player.state.isKnockedOut) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      if (!context.read<BattleCubit>().revive(player.id)) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('${player.name} не на связи')));
                      }
                    },
                    icon: const Icon(Icons.bedtime_off),
                    label: const Text('Привести в чувство'),
                  ),
                ],
                const SizedBox(height: 16),
                StatusesSection(combatantId: player.id, statuses: player.statuses),
              ],
            ),
          ),
        );
      },
    );
  }
}
