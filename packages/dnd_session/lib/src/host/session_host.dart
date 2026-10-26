import 'dart:async';
import 'dart:io';

import 'package:dnd_session/src/discovery/session_discovery.dart';
import 'package:dnd_session/src/models/combatant.dart';
import 'package:dnd_session/src/protocol/session_message.dart';

/// Игрок сессии. После разрыва связи остаётся в списке с [isConnected] = false, чтобы мастер видел
/// последние хиты; при переподключении с тем же `playerId` запись обновляется.
class SessionPlayer {
  final String id;
  final CombatantProfile profile;
  final CombatantState state;
  final bool isConnected;

  const SessionPlayer({required this.id, required this.profile, required this.state, required this.isConnected});

  SessionPlayer copyWith({CombatantProfile? profile, CombatantState? state, bool? isConnected}) => SessionPlayer(
    id: id,
    profile: profile ?? this.profile,
    state: state ?? this.state,
    isConnected: isConnected ?? this.isConnected,
  );
}

/// Сервер сессии на устройстве мастера: принимает игроков по WebSocket и объявляет себя в сети.
class SessionHost {
  static const _joinTimeout = Duration(seconds: 5);
  static const _pingInterval = Duration(seconds: 5);

  final SessionAdvertiser? _advertiser;

  HttpServer? _server;
  String? _name;
  final _sockets = <String, WebSocket>{};
  final _players = <String, SessionPlayer>{};
  final _playersController = StreamController<List<SessionPlayer>>.broadcast();

  /// [advertiser] — `null`, чтобы не объявлять сессию в сети (подключение только по адресу, тесты).
  SessionHost({SessionAdvertiser? advertiser}) : _advertiser = advertiser;

  bool get isRunning => _server != null;

  String? get name => _name;

  /// Порт сервера, пока сессия запущена.
  int? get port => _server?.port;

  List<SessionPlayer> get players => _players.values.toList();

  /// Список игроков при каждом изменении: подключение, отключение, новые хиты.
  Stream<List<SessionPlayer>> get playersStream => _playersController.stream;

  /// Запускает сессию. [port] 0 — любой свободный.
  Future<void> start({required String name, int port = 0}) async {
    if (isRunning) await stop();
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _server = server;
    _name = name;
    server.listen(_handleRequest);
    await _advertiser?.start(name: name, port: server.port);
  }

  /// Завершает сессию: игроки получают [SessionClosedMessage] и не переподключаются.
  Future<void> stop() async {
    final server = _server;
    if (server == null) return;
    _server = null;
    _name = null;
    await _advertiser?.stop();
    for (final socket in _sockets.values.toList()) {
      socket.add(const SessionClosedMessage().encode());
      await socket.close(WebSocketStatus.goingAway);
    }
    _sockets.clear();
    _players.clear();
    _emit();
    await server.close(force: true);
  }

  /// Убирает игрока из сессии. Если он подключён, соединение закрывается.
  Future<void> removePlayer(String id) async {
    _players.remove(id);
    final socket = _sockets.remove(id);
    _emit();
    if (socket != null) {
      socket.add(const SessionClosedMessage().encode());
      await socket.close(WebSocketStatus.normalClosure);
    }
  }

  Future<void> dispose() async {
    await stop();
    await _playersController.close();
  }

  /// Адреса устройства в локальной сети, чтобы игрок мог подключиться вручную, если поиск не работает.
  static Future<List<String>> localAddresses() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    return interfaces.expand((e) => e.addresses).where((e) => !e.isLoopback).map((e) => e.address).toList();
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (request.uri.path != '/session' || !WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    socket.pingInterval = _pingInterval;
    _handleSocket(socket);
  }

  void _handleSocket(WebSocket socket) {
    String? playerId;
    final joinTimer = Timer(_joinTimeout, () {
      if (playerId == null) socket.close(WebSocketStatus.policyViolation);
    });

    socket.listen(
      (data) {
        final message = SessionMessage.decode(data);
        final id = playerId;
        if (id == null) {
          if (message is! JoinMessage) return;
          joinTimer.cancel();
          if (message.protocolVersion != sessionProtocolVersion) {
            socket.add(
              const RejectMessage('Другая версия приложения: обновите приложение мастера или игрока').encode(),
            );
            socket.close(WebSocketStatus.normalClosure);
            return;
          }
          playerId = message.playerId;
          // Повторное подключение того же игрока (например, после сна телефона) вытесняет старое соединение.
          _sockets.remove(message.playerId)?.close(WebSocketStatus.normalClosure);
          _sockets[message.playerId] = socket;
          _players[message.playerId] = SessionPlayer(
            id: message.playerId,
            profile: message.profile,
            state: message.state,
            isConnected: true,
          );
          socket.add(WelcomeMessage(sessionName: _name ?? '').encode());
          _emit();
          return;
        }
        final player = _players[id];
        if (player == null) return;
        switch (message) {
          case ProfileMessage(:final profile):
            _players[id] = player.copyWith(profile: profile);
          case StateMessage(:final state):
            _players[id] = player.copyWith(state: state);
          default:
            return;
        }
        _emit();
      },
      onDone: () {
        joinTimer.cancel();
        final id = playerId;
        // Соединение могло быть уже вытеснено новым — тогда игрок по-прежнему на связи.
        if (id == null || _sockets[id] != socket) return;
        _sockets.remove(id);
        final player = _players[id];
        if (player != null) {
          _players[id] = player.copyWith(isConnected: false);
          _emit();
        }
      },
      cancelOnError: true,
    );
  }

  void _emit() {
    if (!_playersController.isClosed) _playersController.add(players);
  }
}
