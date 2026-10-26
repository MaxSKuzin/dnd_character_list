import 'package:dnd_master/data/master_session_source.dart';
import 'package:dnd_master/presentation/battle/battle_view.dart';
import 'package:dnd_master/presentation/widgets/player_card.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';

/// Запущенная сессия: адрес для подключения и игроки с их боевыми данными.
class SessionScreen extends StatefulWidget {
  final MasterSessionSource source;

  const SessionScreen({super.key, required this.source});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final _addresses = widget.source.addresses();

  Future<void> _confirmStop() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Завершить сессию?'),
        content: const Text('Игроки будут отключены.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Завершить')),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.source.stop();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmStop();
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const EncounterSwitcher(),
            actions: [
              const BattleMenu(),
              IconButton(tooltip: 'Завершить сессию', onPressed: _confirmStop, icon: const Icon(Icons.stop)),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Бой'),
                Tab(text: 'Игроки'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              const BattleView(),
              _PlayersTab(source: widget.source, addresses: _addresses),
            ],
          ),
        ),
      ),
    );
  }
}

/// Название сессии, адрес для ручного подключения и подробные карточки игроков.
///
/// Отдельный виджет, а не метод экрана: `TabBarView` пересоздаёт вкладку при каждом переключении, и текущий
/// список игроков должен читаться в момент её построения, а не когда строился экран сессии.
class _PlayersTab extends StatelessWidget {
  final MasterSessionSource source;
  final Future<List<String>> addresses;

  const _PlayersTab({required this.source, required this.addresses});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text('Сессия «${source.name ?? ''}»', style: Theme.of(context).textTheme.titleMedium),
      ),
      FutureBuilder<List<String>>(
        future: addresses,
        builder: (context, snapshot) {
          final addresses = snapshot.data ?? const [];
          if (addresses.isEmpty) return const SizedBox();
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Адрес для подключения вручную: ${addresses.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        },
      ),
      Expanded(
        child: StreamBuilder<List<SessionPlayer>>(
          stream: source.playersStream,
          initialData: source.players,
          builder: (context, snapshot) {
            final players = snapshot.requireData;
            if (players.isEmpty) {
              return const Center(
                child: Text('Ждём игроков…\nОни увидят сессию на экране боя', textAlign: TextAlign.center),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: players.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  PlayerCard(player: players[index], onRemove: () => source.removePlayer(players[index].id)),
            );
          },
        ),
      ),
    ],
  );
}
