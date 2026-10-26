import 'dart:convert';

import 'package:dnd_session/src/models/combatant.dart';

/// Версия протокола. Без обратной совместимости: при несовпадении мастер отклоняет подключение.
const sessionProtocolVersion = 1;

/// Сообщение между мастером и игроком. Передаётся по WebSocket текстом JSON: `{"type": ..., ...}`.
sealed class SessionMessage {
  const SessionMessage();

  String get type;

  Map<String, dynamic> _body();

  String encode() => jsonEncode({'type': type, ..._body()});

  /// `null` — неизвестный тип или битое сообщение, такие пропускаются.
  static SessionMessage? decode(Object? data) {
    if (data is! String) return null;
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      return switch (json['type']) {
        JoinMessage.typeName => JoinMessage.fromJson(json),
        ProfileMessage.typeName => ProfileMessage(CombatantProfile.fromJson(json['profile'])),
        StateMessage.typeName => StateMessage(CombatantState.fromJson(json['state'])),
        WelcomeMessage.typeName => WelcomeMessage(sessionName: json['sessionName']),
        RejectMessage.typeName => RejectMessage(json['reason']),
        SessionClosedMessage.typeName => const SessionClosedMessage(),
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }
}

// Игрок → мастер.

/// Первое сообщение игрока после подключения. [playerId] постоянный для персонажа на устройстве:
/// при переподключении мастер узнаёт игрока и не создаёт новую запись.
class JoinMessage extends SessionMessage {
  static const typeName = 'join';

  final int protocolVersion;
  final String playerId;
  final CombatantProfile profile;
  final CombatantState state;

  const JoinMessage({
    this.protocolVersion = sessionProtocolVersion,
    required this.playerId,
    required this.profile,
    required this.state,
  });

  factory JoinMessage.fromJson(Map<String, dynamic> json) => JoinMessage(
    protocolVersion: json['version'],
    playerId: json['playerId'],
    profile: CombatantProfile.fromJson(json['profile']),
    state: CombatantState.fromJson(json['state']),
  );

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {
    'version': protocolVersion,
    'playerId': playerId,
    'profile': profile.toJson(),
    'state': state.toJson(),
  };
}

/// Изменились редкие данные: уровень, КД, максимум хитов.
class ProfileMessage extends SessionMessage {
  static const typeName = 'profile';

  final CombatantProfile profile;

  const ProfileMessage(this.profile);

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'profile': profile.toJson()};
}

/// Изменилось боевое состояние: хиты, ячейки, ресурсы.
class StateMessage extends SessionMessage {
  static const typeName = 'state';

  final CombatantState state;

  const StateMessage(this.state);

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'state': state.toJson()};
}

// Мастер → игрок.

/// Подключение принято.
class WelcomeMessage extends SessionMessage {
  static const typeName = 'welcome';

  final String sessionName;

  const WelcomeMessage({required this.sessionName});

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'sessionName': sessionName};
}

/// Подключение отклонено, например из-за другой версии протокола.
class RejectMessage extends SessionMessage {
  static const typeName = 'reject';

  final String reason;

  const RejectMessage(this.reason);

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'reason': reason};
}

/// Мастер завершил сессию: переподключаться не нужно.
class SessionClosedMessage extends SessionMessage {
  static const typeName = 'closed';

  const SessionClosedMessage();

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {};
}
