import 'package:dnd_character_list/data/session/session_source.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/session/write_note.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Подключение к сессии мастера: найденные в сети сессии, ввод адреса вручную, отключение.
class SessionSheet extends StatefulWidget {
  final Player player;

  const SessionSheet({super.key, required this.player});

  static Future<void> show(BuildContext context, Player player) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => SessionSheet(player: player),
      );

  @override
  State<SessionSheet> createState() => _SessionSheetState();
}

class _SessionSheetState extends State<SessionSheet> {
  final _source = getIt<SessionSource>();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _joinByAddress() {
    final session = SessionSource.parseAddress(_addressController.text);
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Адрес вида 192.168.1.5:4040')));
      return;
    }
    _source.join(session, widget.player);
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea — от скруглений и полоски жестов снизу; при открытой клавиатуре нижний отступ SafeArea обнуляется,
    // поэтому он не складывается с viewInsets.
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: StreamBuilder<SessionStatus>(
          stream: _source.statusStream,
          initialData: _source.status,
          builder: (context, snapshot) {
            final status = snapshot.requireData;
            final joined = _source.isJoined(widget.player);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Сессия мастера', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                const Gap(16),
                if (joined) ..._connected(status) else ..._search(status),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _connected(SessionStatus status) => [
        Text(
          switch (status) {
            SessionConnected(:final sessionName, :final session) => '$sessionName\n${session.address}',
            SessionConnecting(:final session) => 'Подключение к ${session.address}…',
            SessionReconnecting(:final session) => 'Связь потеряна, переподключение к ${session.address}…',
            SessionDisconnected() => '',
          },
          textAlign: TextAlign.center,
        ),
        const Gap(16),
        // Для настроения за столом: реакции мастеру и другим игрокам, у них на экране анимация.
        if (status is SessionConnected) ...[
          _Notes(source: _source),
          const Gap(16),
          _Reactions(source: _source),
        ],
        const Gap(8),
        OutlinedButton(onPressed: _source.leave, child: const Text('Отключиться')),
      ];

  List<Widget> _search(SessionStatus status) => [
        if (status case SessionDisconnected(:final reason?)) ...[
          Text(reason, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const Gap(8),
        ],
        _SessionsList(onSelected: (session) => _source.join(session, widget.player)),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addressController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Адрес мастера', hintText: '192.168.1.5:4040'),
                onSubmitted: (_) => _joinByAddress(),
              ),
            ),
            IconButton(onPressed: _joinByAddress, icon: const Icon(Icons.login)),
          ],
        ),
      ];
}

/// Найденные в сети сессии. Поиск идёт, пока список на экране.
class _SessionsList extends StatefulWidget {
  final ValueChanged<SessionInfo> onSelected;

  const _SessionsList({required this.onSelected});

  @override
  State<_SessionsList> createState() => _SessionsListState();
}

class _SessionsListState extends State<_SessionsList> {
  late final _sessions = getIt<SessionSource>().sessions;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SessionInfo>>(
      stream: _sessions,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Поиск в сети недоступен, введите адрес вручную', textAlign: TextAlign.center);
        }
        final sessions = snapshot.data ?? const [];
        if (sessions.isEmpty) {
          return const Column(
            children: [
              LinearProgressIndicator(),
              Gap(8),
              Text('Ищем сессии в локальной сети…', textAlign: TextAlign.center),
            ],
          );
        }
        return Column(
          children: sessions
              .map(
                (session) => ListTile(
                  leading: const Icon(Icons.shield_moon_outlined),
                  title: Text(session.name),
                  subtitle: Text(session.address),
                  onTap: () => widget.onSelected(session),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// Сообщения мастеру и другим подключённым игрокам: по кнопке на каждого.
class _Notes extends StatelessWidget {
  final SessionSource source;

  const _Notes({required this.source});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SessionMate>>(
      stream: source.rosterStream,
      initialData: source.roster,
      builder: (context, snapshot) {
        final mates = (snapshot.data ?? const <SessionMate>[]).where((e) => !source.isMe(e.id));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Написать', style: Theme.of(context).textTheme.titleMedium),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => writeNote(context, to: 'Мастер'),
                  icon: const Icon(Icons.shield_moon_outlined, size: 18),
                  label: const Text('Мастеру'),
                ),
                for (final mate in mates)
                  OutlinedButton.icon(
                    onPressed: () => writeNote(context, targetId: mate.id, to: mate.name),
                    icon: const Icon(Icons.mail_outline, size: 18),
                    label: Text(mate.name),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Реакции мастеру и другим подключённым игрокам: по ряду кнопок на каждого.
class _Reactions extends StatelessWidget {
  final SessionSource source;

  const _Reactions({required this.source});

  void _send(BuildContext context, Reaction reaction, {String? targetId, required String to}) {
    final sent = source.react(reaction, targetId: targetId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(sent ? '${reaction.emoji} летит: $to' : 'Нет связи с мастером')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SessionMate>>(
      stream: source.rosterStream,
      initialData: source.roster,
      builder: (context, snapshot) {
        final mates = (snapshot.data ?? const <SessionMate>[]).where((e) => !source.isMe(e.id)).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Реакции', style: Theme.of(context).textTheme.titleMedium),
            const Gap(4),
            _ReactionRow(title: 'Мастеру', onSelected: (reaction) => _send(context, reaction, to: 'мастеру')),
            for (final mate in mates)
              _ReactionRow(
                title: mate.name,
                onSelected: (reaction) => _send(context, reaction, targetId: mate.id, to: mate.name),
              ),
            if (mates.isEmpty)
              Text(
                'Других игроков в сессии пока нет.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
          ],
        );
      },
    );
  }
}

class _ReactionRow extends StatelessWidget {
  final String title;
  final ValueChanged<Reaction> onSelected;

  const _ReactionRow({required this.title, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
          for (final reaction in Reaction.values)
            IconButton(
              tooltip: '${reaction.emoji} → $title',
              visualDensity: VisualDensity.compact,
              onPressed: () => onSelected(reaction),
              icon: Text(reaction.emoji, style: const TextStyle(fontSize: 20)),
            ),
        ],
      ),
    );
  }
}
