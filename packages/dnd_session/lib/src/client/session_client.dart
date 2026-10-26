import 'dart:async';
import 'dart:io';

import 'package:dnd_session/src/discovery/session_discovery.dart';
import 'package:dnd_session/src/models/battle_snapshot.dart';
import 'package:dnd_session/src/models/combatant.dart';
import 'package:dnd_session/src/models/condition.dart';
import 'package:dnd_session/src/models/reaction.dart';
import 'package:dnd_session/src/protocol/session_message.dart';

/// Состояние подключения игрока к сессии мастера.
sealed class SessionStatus {
  const SessionStatus();
}

/// Не подключён. [reason] — почему соединение закончилось: мастер завершил сессию, отклонил подключение,
/// не удалось подключиться. `null` — игрок отключился сам.
class SessionDisconnected extends SessionStatus {
  final String? reason;

  const SessionDisconnected([this.reason]);
}

class SessionConnecting extends SessionStatus {
  final SessionInfo session;

  const SessionConnecting(this.session);
}

class SessionConnected extends SessionStatus {
  final SessionInfo session;

  /// Название сессии от мастера. У сессии, введённой по адресу, [SessionInfo.name] — сам адрес.
  final String sessionName;

  const SessionConnected(this.session, this.sessionName);
}

/// Связь пропала, клиент переподключается сам.
class SessionReconnecting extends SessionStatus {
  final SessionInfo session;

  const SessionReconnecting(this.session);
}

/// Подключение игрока к сессии мастера.
///
/// Отправляет только изменившуюся часть данных: [CombatantState] при каждом изменении хитов и ресурсов,
/// [CombatantProfile] — когда меняются КД, уровень и т.п.
class SessionClient {
  static const _connectTimeout = Duration(seconds: 5);
  static const _pingInterval = Duration(seconds: 5);
  static const _reconnectDelay = Duration(seconds: 2);

  final _statusController = StreamController<SessionStatus>.broadcast();
  SessionStatus _status = const SessionDisconnected();
  final _battleController = StreamController<BattleSnapshot?>.broadcast();
  BattleSnapshot? _battle;
  final _initiativeRequestsController = StreamController<void>.broadcast();
  final _hitsChangesController = StreamController<int>.broadcast();
  final _reactionsController = StreamController<({String from, Reaction reaction})>.broadcast();
  final _rosterController = StreamController<List<SessionMate>>.broadcast();
  List<SessionMate> _roster = const [];
  final _revivalsController = StreamController<String>.broadcast();
  final _notesController = StreamController<({String from, String? fromId, String text})>.broadcast();
  final _statusesController = StreamController<List<StatusEffect>>.broadcast();
  List<StatusEffect> _statuses = const [];

  WebSocket? _socket;
  SessionInfo? _session;
  String? _playerId;
  CombatantProfile? _profile;
  CombatantState? _state;

  /// Что уже ушло мастеру в текущем соединении.
  CombatantProfile? _sentProfile;
  CombatantState? _sentState;

  /// Увеличивается при каждом новом подключении и отключении, чтобы старые попытки не меняли состояние.
  int _attempt = 0;

  SessionStatus get status => _status;

  Stream<SessionStatus> get statusStream => _statusController.stream;

  /// Идущий бой у мастера; `null` — боя нет или нет подключения.
  BattleSnapshot? get battle => _battle;

  Stream<BattleSnapshot?> get battleStream => _battleController.stream;

  /// Мастер просит бросить инициативу.
  Stream<void> get initiativeRequests => _initiativeRequestsController.stream;

  /// Урон (отрицательное значение) или лечение от мастера. Применить к персонажу и отправить новое состояние —
  /// забота приложения игрока.
  Stream<int> get hitsChanges => _hitsChangesController.stream;

  /// Реакции от мастера и других игроков: имя отправителя («Мастер») и реакция.
  Stream<({String from, Reaction reaction})> get reactions => _reactionsController.stream;

  /// Подключённые игроки сессии, включая этого. Без подключения — пусто.
  List<SessionMate> get roster => _roster;

  Stream<List<SessionMate>> get rosterStream => _rosterController.stream;

  /// Персонажа привели в чувство из нокаута: имя союзника или «Мастер».
  Stream<String> get revivals => _revivalsController.stream;

  /// Сообщения от мастера и других игроков: имя отправителя («Мастер»), его `playerId` (`null` — мастер), текст.
  Stream<({String from, String? fromId, String text})> get notes => _notesController.stream;

  /// Сообщение другому игроку ([targetId]) или мастеру (`null`): у него уведомление с именем персонажа.
  /// Пробелы по краям убираются, длинное обрезается. `false` — нет подключения или сообщение пустое.
  bool note(String text, {String? targetId}) {
    final socket = _socket;
    final note = NoteMessage.clean(text);
    if (socket == null || _status is! SessionConnected || note == null) return false;
    socket.add(WriteMessage(note, targetId: targetId).encode());
    return true;
  }

  /// Привести в чувство союзника в нокауте. `false` — нет подключения.
  bool revive(String targetId) {
    final socket = _socket;
    if (socket == null || _status is! SessionConnected) return false;
    socket.add(ReviveMessage(targetId).encode());
    return true;
  }

  /// Эффекты на персонаже от мастера. Без подключения — пусто.
  List<StatusEffect> get statuses => _statuses;

  Stream<List<StatusEffect>> get statusesStream => _statusesController.stream;

  /// Реакция другому игроку ([targetId]) или мастеру (`null`). `false` — нет подключения.
  bool react(Reaction reaction, {String? targetId}) {
    final socket = _socket;
    if (socket == null || _status is! SessionConnected) return false;
    socket.add(ReactMessage(reaction, targetId: targetId).encode());
    return true;
  }

  /// Отправляет мастеру результат броска инициативы. `false` — нет подключения.
  bool sendInitiative(int value) {
    final socket = _socket;
    if (socket == null || _status is! SessionConnected) return false;
    socket.add(InitiativeMessage(value).encode());
    return true;
  }

  /// Подключается к сессии. При разрыве связи переподключается сам, пока не вызван [disconnect].
  /// Ошибка подключения не выбрасывается, а приходит как [SessionDisconnected] с причиной.
  Future<void> connect(
    SessionInfo session, {
    required String playerId,
    required CombatantProfile profile,
    required CombatantState state,
  }) async {
    final attempt = ++_attempt;
    await _closeSocket();
    _session = session;
    _playerId = playerId;
    _profile = profile;
    _state = state;
    _setStatus(SessionConnecting(session));
    final (:error, retry: _) = await _open(attempt);
    if (error != null && attempt == _attempt) {
      _session = null;
      _setStatus(SessionDisconnected(error));
    }
  }

  /// Передаёт мастеру новые данные персонажа. Неизменившиеся части не отправляются.
  /// Без подключения данные запоминаются и уйдут при переподключении.
  void update({CombatantProfile? profile, CombatantState? state}) {
    if (profile != null) _profile = profile;
    if (state != null) _state = state;
    final socket = _socket;
    if (socket == null || _status is! SessionConnected) return;
    _sendChanges(socket);
  }

  Future<void> disconnect() async {
    _attempt++;
    _session = null;
    await _closeSocket();
    _setStatus(const SessionDisconnected());
  }

  Future<void> dispose() async {
    await disconnect();
    await _statusController.close();
    await _battleController.close();
    await _initiativeRequestsController.close();
    await _hitsChangesController.close();
    await _reactionsController.close();
    await _rosterController.close();
    await _revivalsController.close();
    await _notesController.close();
    await _statusesController.close();
  }

  /// Одна попытка подключения. [error] — причина неудачи или `null`, если мастер принял игрока;
  /// [retry] — есть ли смысл пробовать снова (мастер не отклонил подключение явно).
  Future<({String? error, bool retry})> _open(int attempt) async {
    final session = _session!;
    final WebSocket socket;
    try {
      socket = await WebSocket.connect(session.uri.toString()).timeout(_connectTimeout);
    } catch (_) {
      return (error: 'Не удалось подключиться к ${session.address}', retry: true);
    }
    if (attempt != _attempt) {
      await socket.close();
      return (error: null, retry: false);
    }
    socket.pingInterval = _pingInterval;
    final profile = _profile!;
    final state = _state!;
    socket.add(JoinMessage(playerId: _playerId!, profile: profile, state: state).encode());

    final answer = Completer<SessionMessage?>();
    socket.listen(
      (data) {
        final message = SessionMessage.decode(data);
        if (!answer.isCompleted) {
          if (message is WelcomeMessage || message is RejectMessage) answer.complete(message);
          return;
        }
        if (attempt != _attempt) return;
        switch (message) {
          case SessionClosedMessage():
            _onSessionClosed(attempt);
          case BattleMessage(:final battle):
            _setBattle(battle);
          case InitiativeRequestMessage():
            _initiativeRequestsController.add(null);
          case HitsChangeMessage(:final delta):
            _hitsChangesController.add(delta);
          case ReactionMessage(:final reaction, :final from):
            _reactionsController.add((from: from, reaction: reaction));
          case RosterMessage(:final players):
            _setRoster(players);
          case RevivedMessage(:final by):
            _revivalsController.add(by);
          case StatusesMessage(:final statuses):
            _setStatuses(statuses);
          case NoteMessage(:final text, :final from, :final fromId):
            _notesController.add((from: from, fromId: fromId, text: text));
          default:
        }
      },
      onDone: () {
        if (!answer.isCompleted) answer.complete(null);
        _onConnectionLost(socket, attempt);
      },
      cancelOnError: true,
    );

    final message = await answer.future.timeout(_connectTimeout, onTimeout: () => null);
    if (attempt != _attempt) return (error: null, retry: false);
    switch (message) {
      case WelcomeMessage(:final sessionName):
        _socket = socket;
        _sentProfile = profile;
        _sentState = state;
        _setStatus(SessionConnected(session, sessionName));
        // Пока шло подключение, персонаж мог измениться.
        _sendChanges(socket);
        return (error: null, retry: false);
      case RejectMessage(:final reason):
        await socket.close();
        return (error: reason, retry: false);
      default:
        await socket.close();
        return (error: 'Мастер не ответил', retry: true);
    }
  }

  void _sendChanges(WebSocket socket) {
    final profile = _profile;
    final state = _state;
    if (profile != null && profile != _sentProfile) {
      socket.add(ProfileMessage(profile).encode());
      _sentProfile = profile;
    }
    if (state != null && state != _sentState) {
      socket.add(StateMessage(state).encode());
      _sentState = state;
    }
  }

  void _onSessionClosed(int attempt) {
    if (attempt != _attempt) return;
    _attempt++;
    _session = null;
    _closeSocket();
    _setStatus(const SessionDisconnected('Мастер завершил сессию'));
  }

  Future<void> _onConnectionLost(WebSocket socket, int attempt) async {
    if (attempt != _attempt || _socket != socket) return;
    _socket = null;
    final session = _session;
    if (session == null) return;
    _setStatus(SessionReconnecting(session));
    while (attempt == _attempt) {
      await Future<void>.delayed(_reconnectDelay);
      if (attempt != _attempt) return;
      final (:error, :retry) = await _open(attempt);
      if (error == null || attempt != _attempt) return;
      if (!retry) {
        _attempt++;
        _session = null;
        _setStatus(SessionDisconnected(error));
        return;
      }
    }
  }

  Future<void> _closeSocket() async {
    final socket = _socket;
    _socket = null;
    _sentProfile = null;
    _sentState = null;
    await socket?.close(WebSocketStatus.normalClosure);
  }

  void _setBattle(BattleSnapshot? battle) {
    _battle = battle;
    if (!_battleController.isClosed) _battleController.add(battle);
  }

  void _setRoster(List<SessionMate> roster) {
    _roster = roster;
    if (!_rosterController.isClosed) _rosterController.add(roster);
  }

  void _setStatuses(List<StatusEffect> statuses) {
    _statuses = statuses;
    if (!_statusesController.isClosed) _statusesController.add(statuses);
  }

  void _setStatus(SessionStatus status) {
    // Без связи бой и эффекты не показываются: при переподключении мастер пришлёт их заново.
    if (status is! SessionConnected && _battle != null) _setBattle(null);
    if (status is! SessionConnected && _statuses.isNotEmpty) _setStatuses(const []);
    if (status is! SessionConnected && _roster.isNotEmpty) _setRoster(const []);
    _status = status;
    if (!_statusController.isClosed) _statusController.add(status);
  }
}
