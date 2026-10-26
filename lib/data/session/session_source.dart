import 'dart:math';

import 'package:dnd_character_list/data/session/player_combatant.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Подключение персонажа к сессии мастера в локальной сети.
///
/// ```dart
/// source.sessions                      // найденные сессии, поиск идёт, пока есть подписка
/// source.join(session, player)         // подключиться
/// source.updatePlayer(player)          // при каждом изменении персонажа: уходит только изменившееся
/// source.leave()                       // отключиться
/// ```
@preResolve
@singleton
class SessionSource {
  static const _deviceIdKey = 'sessionDeviceId';

  final String _deviceId;
  final SessionDiscovery _discovery;
  final SessionClient _client;

  /// Персонаж, который подключён (или подключается) к сессии.
  String? _playerId;

  SessionSource._(this._deviceId, this._discovery, this._client);

  @factoryMethod
  static Future<SessionSource> init() async {
    final sp = await SharedPreferences.getInstance();
    var deviceId = sp.getString(_deviceIdKey);
    if (deviceId == null) {
      final random = Random.secure();
      deviceId = List.generate(8, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
      await sp.setString(_deviceIdKey, deviceId);
    }
    return SessionSource._(deviceId, BonjourSessionDiscovery(), SessionClient());
  }

  /// Сессии мастеров в локальной сети.
  Stream<List<SessionInfo>> get sessions => _discovery.sessions;

  SessionStatus get status => _client.status;

  Stream<SessionStatus> get statusStream => _client.statusStream;

  /// Подключён ли к сессии именно этот персонаж.
  bool isJoined(Player player) => _playerId == _idOf(player) && _client.status is! SessionDisconnected;

  /// Сессия по адресу «192.168.1.5:4040», если поиск в сети не работает. `null` — адрес не разобран.
  static SessionInfo? parseAddress(String address) {
    final uri = Uri.tryParse('ws://${address.trim()}');
    if (uri == null || uri.host.isEmpty || !uri.hasPort) return null;
    return SessionInfo(name: '${uri.host}:${uri.port}', host: uri.host, port: uri.port);
  }

  Future<void> join(SessionInfo session, Player player) {
    _playerId = _idOf(player);
    return _client.connect(
      session,
      playerId: _playerId!,
      profile: player.combatantProfile,
      state: player.combatantState,
    );
  }

  /// Передаёт мастеру изменения персонажа. Другие персонажи (не тот, что подключён) пропускаются.
  void updatePlayer(Player player) {
    if (_playerId != _idOf(player)) return;
    _client.update(profile: player.combatantProfile, state: player.combatantState);
  }

  Future<void> leave() {
    _playerId = null;
    return _client.disconnect();
  }

  /// Постоянный для персонажа на этом устройстве: персонажи различаются по имени и основному классу, как в `SpSource`.
  String _idOf(Player player) =>
      '$_deviceId/${player.personality.name}/${player.classes.firstWhere((e) => e.isMain).classKind.name}';
}
