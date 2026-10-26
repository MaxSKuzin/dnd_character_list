import 'package:dnd_master/domain/bloc/battle_cubit.dart';
import 'package:dnd_master/domain/bloc/encounters_cubit.dart';
import 'package:dnd_master/domain/models/battle.dart';
import 'package:dnd_master/domain/models/encounter.dart';
import 'package:dnd_master/presentation/battle/combatant_tile.dart';
import 'package:dnd_master/presentation/common/number_dialogs.dart';
import 'package:dnd_master/presentation/encounters/encounters_screen.dart';
import 'package:dnd_master/presentation/monsters/monster_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Бой активной ситуации: очередь инициативы, ходы, добавление монстров.
class BattleView extends StatelessWidget {
  const BattleView({super.key});

  Future<void> _addMonster(BuildContext context) async {
    final cubit = context.read<BattleCubit>();
    final monster = await pickMonster(context);
    if (monster != null) cubit.addMonster(monster);
  }

  /// Игроки бросают инициативу сами: мастер вводит результаты тех, у кого её ещё нет. Пропущенный игрок
  /// встаёт в конец очереди, его инициативу можно ввести позже. Монстрам инициатива бросается сама.
  Future<void> _start(BuildContext context) async {
    final cubit = context.read<BattleCubit>();
    final battle = cubit.state.active;
    for (final player in cubit.state.order.whereType<PlayerCombatant>()) {
      if (battle.initiative.containsKey(player.id)) continue;
      final bonus = player.initiativeBonus;
      final value = await askNumber(
        context,
        title: 'Инициатива: ${player.name}',
        hint: 'Результат броска к20 ${bonus >= 0 ? '+' : '−'} ${bonus.abs()}',
        cancelLabel: 'Пропустить',
      );
      if (!context.mounted) return;
      if (value != null) cubit.setInitiative(player.id, value);
    }
    cubit.start();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BattleCubit, BattleState>(
      builder: (context, state) {
        final battle = state.active;
        final order = state.order;
        final notes = context
            .select<EncountersCubit, Encounter?>((cubit) => cubit.state.where((e) => e.id == battle.id).firstOrNull)
            ?.notes;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (notes != null && notes.isNotEmpty)
              ExpansionTile(
                title: const Text('Заметки'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(notes)],
              ),
            Expanded(
              child: order.isEmpty
                  ? const Center(child: Text('Добавьте монстров или дождитесь игроков'))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                      children: [
                        for (final combatant in order)
                          CombatantTile(
                            key: ValueKey(combatant.id),
                            combatant: combatant,
                            initiative: battle.initiative[combatant.id],
                            isCurrent: battle.currentId == combatant.id,
                          ),
                      ],
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Добавить монстра',
                      onPressed: () => _addMonster(context),
                      icon: const Icon(Icons.add),
                    ),
                    if (battle.isStarted) ...[
                      IconButton(
                        tooltip: 'Предыдущий ход',
                        onPressed: context.read<BattleCubit>().previousTurn,
                        icon: const Icon(Icons.undo),
                      ),
                      Expanded(child: Text('Раунд ${battle.round}', textAlign: TextAlign.center)),
                      FilledButton.icon(
                        onPressed: context.read<BattleCubit>().nextTurn,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Следующий ход'),
                      ),
                    ] else ...[
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: order.isEmpty ? null : () => _start(context),
                        icon: const Icon(Icons.casino),
                        label: const Text('Начать бой'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Название активной ситуации в шапке; по нажатию — переключение на другую ситуацию.
class EncounterSwitcher extends StatelessWidget {
  const EncounterSwitcher({super.key});

  static const _prepare = '__prepare';

  @override
  Widget build(BuildContext context) {
    final battle = context.select<BattleCubit, String>((cubit) => cubit.state.active.name);
    final activeId = context.select<BattleCubit, String>((cubit) => cubit.state.activeId);
    final encounters = context.watch<EncountersCubit>().state;
    return PopupMenuButton<String>(
      tooltip: 'Боевая ситуация',
      onSelected: (id) {
        final cubit = context.read<BattleCubit>();
        if (id == _prepare) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EncountersScreen()));
        } else if (id == Battle.freeId) {
          cubit.selectFree();
        } else {
          cubit.select(encounters.firstWhere((e) => e.id == id));
        }
      },
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: Battle.freeId,
          checked: activeId == Battle.freeId,
          child: const Text('Свободный бой'),
        ),
        for (final encounter in encounters)
          CheckedPopupMenuItem(value: encounter.id, checked: activeId == encounter.id, child: Text(encounter.name)),
        const PopupMenuDivider(),
        const PopupMenuItem(value: _prepare, child: Text('Подготовить ситуации…')),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(battle, overflow: TextOverflow.ellipsis)),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}

/// Меню боя: броски инициативы, конец боя, сброс ситуации.
class BattleMenu extends StatelessWidget {
  const BattleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BattleCubit>();
    return PopupMenuButton<VoidCallback>(
      tooltip: 'Бой',
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        // Игроки вводят бросок у себя, результат сразу появляется в очереди.
        PopupMenuItem(value: cubit.requestInitiative, child: const Text('Попросить игроков бросить инициативу')),
        // Например, для монстров, добавленных посреди боя.
        PopupMenuItem(value: cubit.rollMonsterInitiative, child: const Text('Бросить инициативу монстрам')),
        PopupMenuItem(value: cubit.finish, child: const Text('Закончить бой')),
        PopupMenuItem(
          value: () {
            final activeId = cubit.state.activeId;
            final encounter = context.read<EncountersCubit>().state.where((e) => e.id == activeId).firstOrNull;
            cubit.reset(encounter);
          },
          child: const Text('Начать ситуацию заново'),
        ),
      ],
    );
  }
}
