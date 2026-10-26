import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/session/session_source.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/session/initiative_prompt.dart';
import 'package:dnd_character_list/presentation/session/write_note.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'MainFlowRoute')
class MainFlow extends StatefulWidget {
  final Player player;

  const MainFlow({
    super.key,
    required this.player,
  });

  @override
  State<MainFlow> createState() => _MainFlowState();
}

class _MainFlowState extends State<MainFlow> {
  final _session = getIt<SessionSource>();
  late final _cubit = getIt<PlayerCubit>(param1: widget.player);
  late final StreamSubscription<void> _initiativeRequests;
  late final StreamSubscription<BattleSnapshot?> _battle;
  late final StreamSubscription<int> _hitsChanges;
  late final StreamSubscription<String> _revivals;
  late final StreamSubscription<({String from, Reaction reaction})> _reactions;
  late final StreamSubscription<List<StatusEffect>> _statuses;
  late final StreamSubscription<({String from, String? fromId, String text})> _notes;

  /// Эффекты при прошлом обновлении — уведомление только о новых.
  Set<String> _statusIds = {};

  /// Чей ход был при прошлом обновлении боя: вибрация только когда ход переходит к персонажу.
  String? _currentTurnId;

  @override
  void initState() {
    super.initState();
    _currentTurnId = _session.battle?.currentId;
    _initiativeRequests = _session.initiativeRequests.listen((_) {
      if (mounted && _session.isJoined(_cubit.state)) askInitiative(context, _cubit.state);
    });
    _battle = _session.battleStream.listen((battle) {
      final currentId = battle?.currentId;
      if (currentId != null && currentId != _currentTurnId && _session.isMe(currentId)) {
        HapticFeedback.heavyImpact();
      }
      _currentTurnId = currentId;
    });
    // Урон и лечение от мастера меняют персонажа как обычно — новые хиты уходят мастеру через listener ниже.
    _hitsChanges = _session.hitsChanges.listen((delta) {
      if (!_session.isJoined(_cubit.state) || delta == 0) return;
      if (delta < 0) {
        _cubit.takeDamage(-delta);
        HapticFeedback.mediumImpact();
      } else {
        _cubit.heal(delta);
      }
      _notify(delta < 0 ? 'Мастер: урон ${-delta}' : 'Мастер: лечение $delta');
    });
    _revivals = _session.revivals.listen((by) {
      if (!_session.isJoined(_cubit.state) || !_cubit.state.isKnockedOut) return;
      _cubit.wakeUp();
      HapticFeedback.mediumImpact();
      _notify(by == 'Мастер' ? 'Мастер приводит вас в чувство' : '$by приводит вас в чувство');
    });
    // Реакции от мастера и других игроков: только анимация и вибрация, персонаж не меняется.
    _reactions = _session.reactions.listen((e) {
      if (!mounted || !_session.isJoined(_cubit.state)) return;
      e.reaction == Reaction.poop ? HapticFeedback.heavyImpact() : HapticFeedback.mediumImpact();
      ReactionOverlay.show(context, reaction: e.reaction, from: e.from);
      _notify('${e.from} ${e.reaction.phrase} ${e.reaction.emoji}');
    });
    // Сообщения от мастера и других игроков — отдельно от снекбаров, сверху экрана, с ответом в одно нажатие.
    _notes = _session.notes.listen((e) {
      if (!mounted || !_session.isJoined(_cubit.state)) return;
      HapticFeedback.mediumImpact();
      NoteOverlay.show(
        context,
        from: e.from,
        text: e.text,
        onReply: () {
          if (mounted) writeNote(context, targetId: e.fromId, to: e.from, replyTo: e.text);
        },
      );
    });
    _statusIds = _session.statuses.map((e) => e.id).toSet();
    _statuses = _session.statusesStream.listen((statuses) {
      final added = statuses.where((e) => !_statusIds.contains(e.id)).toList();
      _statusIds = statuses.map((e) => e.id).toSet();
      if (added.isEmpty || !_session.isJoined(_cubit.state)) return;
      HapticFeedback.mediumImpact();
      _notify(
        added
            .map((e) => [
                  e.title,
                  if (e.description.isNotEmpty && e.condition == null) e.description,
                  if (e.turns != null) turnsLabel(e.turns!),
                ].join(' — '))
            .join('\n'),
      );
    });
  }

  /// Новое уведомление сразу заменяет прежнее (`SingleSnackBarMessenger` над приложением).
  void _notify(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _initiativeRequests.cancel();
    _battle.cancel();
    _hitsChanges.cancel();
    _revivals.cancel();
    _reactions.cancel();
    _statuses.cancel();
    _notes.cancel();
    _cubit.close();
    // Персонаж закрыт — мастеру он больше не виден на связи.
    if (_session.isJoined(widget.player)) _session.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<PlayerCubit, Player>(
        // Хиты, ячейки и ресурсы уходят мастеру при каждом изменении, если персонаж подключён к сессии.
        listener: (context, player) => _session.updatePlayer(player),
        builder: (context, state) => PlayerModel(
          player: state,
          child: AutoTabsScaffold(
            homeIndex: 2,
            // appBarBuilder: (context, tabsRouter) => AppBar(
            //   title: const Text('DnD Character List'),
            //   actions: [
            //     IconButton(
            //       icon: const Icon(Icons.arrow_upward),
            //       onPressed: () {
            //         context.read<PlayerCubit>().levelUp<Bard>();
            //       },
            //     ),
            //   ],
            // ),
            bottomNavigationBuilder: (context, tabsRouter) => BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  label: 'Бой',
                  icon: Icon(Icons.sports_mma_outlined),
                ),
                BottomNavigationBarItem(
                  label: 'Спеллы',
                  icon: Icon(Icons.back_hand_outlined),
                ),
                BottomNavigationBarItem(
                  label: 'Статы',
                  icon: Icon(Icons.format_list_numbered),
                ),
                BottomNavigationBarItem(
                  label: 'Инвентарь',
                  icon: Icon(Icons.inventory),
                ),
                BottomNavigationBarItem(
                  label: 'Перс',
                  icon: Icon(Icons.person),
                ),
              ],
              onTap: tabsRouter.setActiveIndex,
              currentIndex: tabsRouter.activeIndex,
            ),
            routes: const [
              BattleRoute(),
              SpellsRoute(),
              MainRoute(),
              InventoryRoute(),
              PersonalityRoute(),
            ],
          ),
        ),
      ),
    );
  }
}
