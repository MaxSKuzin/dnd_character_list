import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dnd_master/data/master_session_source.dart';
import 'package:dnd_master/domain/models/battle.dart';
import 'package:dnd_master/domain/models/encounter.dart';
import 'package:dnd_master/domain/models/monster.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BattleState {
  /// Игроки сессии — участвуют во всех боях.
  final List<SessionPlayer> players;

  /// Бои по `id` ситуации. Бой создаётся при первом переключении на ситуацию и хранит хиты монстров
  /// и инициативу, пока мастер переключается между ситуациями.
  final Map<String, Battle> battles;
  final String activeId;

  const BattleState({required this.players, required this.battles, required this.activeId});

  Battle get active => battles[activeId]!;

  List<Combatant> get order => active.order(players);

  BattleState copyWith({List<SessionPlayer>? players, Map<String, Battle>? battles, String? activeId}) => BattleState(
    players: players ?? this.players,
    battles: battles ?? this.battles,
    activeId: activeId ?? this.activeId,
  );
}

/// Бои мастера: переключение между подготовленными ситуациями, монстры, инициатива и ходы.
class BattleCubit extends Cubit<BattleState> {
  final MasterSessionSource _source;
  final Random _random;
  late final StreamSubscription<List<SessionPlayer>> _players;
  late final StreamSubscription<({String playerId, int value})> _initiatives;

  /// Последний показанный игрокам бой (JSON), чтобы не рассылать одно и то же при каждом изменении хитов.
  String? _published;

  /// Последние отправленные игрокам эффекты (JSON) по `playerId`.
  final _publishedStatuses = <String, String>{};

  BattleCubit(this._source, {Random? random})
    : _random = random ?? Random(),
      super(BattleState(players: _source.players, battles: {Battle.freeId: Battle.free()}, activeId: Battle.freeId)) {
    _players = _source.playersStream.listen((players) => emit(state.copyWith(players: players)));
    // Инициатива, которую игрок ввёл у себя, идёт в активный бой — как если бы мастер ввёл её сам.
    _initiatives = _source.initiatives.listen((e) {
      if (state.players.any((player) => player.id == e.playerId)) setInitiative(e.playerId, e.value);
    });
  }

  @override
  Future<void> close() async {
    await _players.cancel();
    await _initiatives.cancel();
    return super.close();
  }

  /// Игроки видят очередь активного боя: она уходит при каждом изменении, которое заметно игрокам.
  @override
  void onChange(Change<BattleState> change) {
    super.onChange(change);
    final next = change.nextState;
    final snapshot = next.active.snapshot(next.players);
    final encoded = jsonEncode(snapshot?.toJson());
    if (encoded != _published) {
      _published = encoded;
      _source.setBattle(snapshot);
    }
    // Эффекты игрока — из активного боя: при переключении ситуации игрок видит эффекты нового боя.
    for (final player in next.players) {
      final statuses = next.active.statuses[player.id] ?? const <StatusEffect>[];
      final encoded = jsonEncode(statuses.map((e) => e.toJson()).toList());
      if (_publishedStatuses[player.id] == encoded) continue;
      _publishedStatuses[player.id] = encoded;
      _source.setPlayerStatuses(player.id, statuses);
    }
  }

  /// Просит бросить инициативу игроков, у которых её ещё нет в активном бою.
  void requestInitiative() => _source.requestInitiative(
    state.players.where((e) => e.isConnected && !state.active.initiative.containsKey(e.id)).map((e) => e.id),
  );

  /// Переключается на ситуацию. Уже начатый бой этой ситуации продолжается с того же места.
  void select(Encounter encounter) {
    final battle = state.battles[encounter.id]?.rename(encounter.name) ?? Battle.fromEncounter(encounter);
    emit(state.copyWith(battles: {...state.battles, encounter.id: battle}, activeId: encounter.id));
  }

  void selectFree() => emit(state.copyWith(activeId: Battle.freeId));

  /// Собирает бой ситуации заново: монстры с полными хитами, без инициативы.
  void reset(Encounter? encounter) => _update(encounter == null ? Battle.free() : Battle.fromEncounter(encounter));

  /// Ситуация отредактирована. Бой, который ещё не начат, собирается заново с новыми монстрами;
  /// начатый — только получает новое название, чтобы не потерять хиты и инициативу.
  void encounterChanged(Encounter encounter) {
    final battle = state.battles[encounter.id];
    if (battle == null) return;
    _update(battle.isStarted ? battle.rename(encounter.name) : Battle.fromEncounter(encounter));
  }

  /// Ситуация удалена — её бой тоже. Если он был активным, мастер возвращается к свободному бою.
  void forget(String encounterId) {
    if (encounterId == Battle.freeId) return;
    emit(
      state.copyWith(
        battles: {...state.battles}..remove(encounterId),
        activeId: state.activeId == encounterId ? Battle.freeId : null,
      ),
    );
  }

  void addMonster(MonsterTemplate template, {int count = 1}) =>
      _update(state.active.addMonster(template, count: count));

  void removeMonster(String id) => _update(state.active.removeMonster(id, state.players));

  void changeMonsterHits(String id, int delta) => _update(state.active.changeMonsterHits(id, delta));

  /// Урон или лечение участника. Хиты игрока меняются на его устройстве и возвращаются мастеру обычным
  /// обновлением; `false` — игрок не на связи.
  bool changeHits(Combatant combatant, int delta) {
    switch (combatant) {
      case MonsterCombatant():
        changeMonsterHits(combatant.id, delta);
        return true;
      case PlayerCombatant():
        return _source.changePlayerHits(combatant.id, delta);
    }
  }

  /// Мастер приводит в чувство игрока в нокауте. `false` — игрок не на связи.
  bool revive(String playerId) => _source.revivePlayer(playerId);

  void addStatus(String combatantId, {Condition? condition, String? title, String description = '', int? turns}) =>
      _update(
        state.active.addStatus(combatantId, condition: condition, title: title, description: description, turns: turns),
      );

  void removeStatus(String combatantId, String statusId) => _update(state.active.removeStatus(combatantId, statusId));

  void setInitiative(String id, int value) => _update(state.active.setInitiative(id, value, _random));

  void markMonster(String id, {required MonsterMarker marker, required String? label}) =>
      _update(state.active.markMonster(id, marker: marker, label: label));

  void rollMonsterInitiative() => _update(state.active.rollMonsterInitiative(_random));

  /// Начало боя: инициатива монстров бросается, ход переходит к первому в очереди. Инициативу игроков мастер
  /// вводит заранее — игроки бросают кубики сами.
  void start() => _update(state.active.rollMonsterInitiative(_random).start(state.players));

  void nextTurn() => _update(state.active.nextTurn(state.players));

  void previousTurn() => _update(state.active.previousTurn(state.players));

  void finish() => _update(state.active.finish());

  void _update(Battle battle) => emit(state.copyWith(battles: {...state.battles, battle.id: battle}));
}
