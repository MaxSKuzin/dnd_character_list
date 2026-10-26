import 'dart:convert';

import 'package:dnd_session/src/models/battle_snapshot.dart';
import 'package:dnd_session/src/models/combatant.dart';
import 'package:dnd_session/src/models/condition.dart';
import 'package:dnd_session/src/models/reaction.dart';

/// Версия протокола. Без обратной совместимости: при несовпадении мастер отклоняет подключение.
const sessionProtocolVersion = 9;

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
        InitiativeMessage.typeName => InitiativeMessage(json['value']),
        WelcomeMessage.typeName => WelcomeMessage(sessionName: json['sessionName']),
        RejectMessage.typeName => RejectMessage(json['reason']),
        SessionClosedMessage.typeName => const SessionClosedMessage(),
        BattleMessage.typeName => BattleMessage(
          json['battle'] == null ? null : BattleSnapshot.fromJson(json['battle']),
        ),
        InitiativeRequestMessage.typeName => const InitiativeRequestMessage(),
        HitsChangeMessage.typeName => HitsChangeMessage(json['delta']),
        // Неизвестная реакция (из новой версии) — сообщение пропускается.
        ReactMessage.typeName => ReactMessage(Reaction.fromName(json['reaction'])!, targetId: json['target']),
        ReactionMessage.typeName => ReactionMessage(Reaction.fromName(json['reaction'])!, from: json['from']),
        RosterMessage.typeName => RosterMessage(
          (json['players'] as List).map((e) => SessionMate.fromJson(e as Map<String, dynamic>)).toList(),
        ),
        ReviveMessage.typeName => ReviveMessage(json['target']),
        RevivedMessage.typeName => RevivedMessage(json['by']),
        StatusesMessage.typeName => StatusesMessage(StatusEffect.listFromJson(json['statuses'])),
        WriteMessage.typeName => WriteMessage(json['text'], targetId: json['target']),
        NoteMessage.typeName => NoteMessage(json['text'], from: json['from'], fromId: json['fromId']),
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

/// Игрок бросил инициативу (к20 + бонус) и вводит результат.
class InitiativeMessage extends SessionMessage {
  static const typeName = 'initiative';

  final int value;

  const InitiativeMessage(this.value);

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'value': value};
}

/// Игрок приводит в чувство союзника в нокауте ([targetId] — его `playerId`).
class ReviveMessage extends SessionMessage {
  static const typeName = 'revive';

  final String targetId;

  const ReviveMessage(this.targetId);

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'target': targetId};
}

// Мастер → игрок.

/// Персонажа привели в чувство: союзник через мастера или сам мастер. [by] — кто, для уведомления.
class RevivedMessage extends SessionMessage {
  static const typeName = 'revived';

  final String by;

  const RevivedMessage(this.by);

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'by': by};
}

/// Идущий бой. `null` — боя нет (не начат или закончен). Отправляется всем при каждом изменении очереди
/// и новому игроку сразу после [WelcomeMessage].
class BattleMessage extends SessionMessage {
  static const typeName = 'battle';

  final BattleSnapshot? battle;

  const BattleMessage(this.battle);

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'battle': battle?.toJson()};
}

/// Мастер просит бросить инициативу: игрок видит окно ввода.
class InitiativeRequestMessage extends SessionMessage {
  static const typeName = 'initiativeRequest';

  const InitiativeRequestMessage();

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {};
}

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

/// Мастер нанёс урон (отрицательное [delta]) или вылечил (положительное). Игрок применяет его к персонажу,
/// новые хиты возвращаются мастеру обычным [StateMessage].
class HitsChangeMessage extends SessionMessage {
  static const typeName = 'hits';

  final int delta;

  const HitsChangeMessage(this.delta);

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'delta': delta};
}

/// Игрок отправляет реакцию другому игроку ([targetId]) или мастеру (`null`). Мастер пересылает её цели
/// [ReactionMessage] от имени отправителя.
class ReactMessage extends SessionMessage {
  static const typeName = 'react';

  final Reaction reaction;
  final String? targetId;

  const ReactMessage(this.reaction, {this.targetId});

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'reaction': reaction.name, 'target': targetId};
}

/// Реакция игроку от мастера или другого игрока ([from] — имя или «Мастер»): у игрока показывается анимация.
class ReactionMessage extends SessionMessage {
  static const typeName = 'reaction';

  final Reaction reaction;
  final String from;

  const ReactionMessage(this.reaction, {required this.from});

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'reaction': reaction.name, 'from': from};
}

/// Подключённые игроки сессии — кому можно отправить реакцию. Приходит при подключении и при изменениях.
class RosterMessage extends SessionMessage {
  static const typeName = 'roster';

  final List<SessionMate> players;

  const RosterMessage(this.players);

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'players': players.map((e) => e.toJson()).toList()};
}

/// Эффекты на персонаже от мастера: состояния и свои («Удивлён», 2 хода). Приходят целиком при каждом
/// изменении и при подключении.
class StatusesMessage extends SessionMessage {
  static const typeName = 'statuses';

  final List<StatusEffect> statuses;

  const StatusesMessage(this.statuses);

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'statuses': statuses.map((e) => e.toJson()).toList()};
}

/// Игрок пишет другому игроку ([targetId]) или мастеру (`null`). Мастер пересылает сообщение цели [NoteMessage]
/// от имени отправителя.
class WriteMessage extends SessionMessage {
  static const typeName = 'write';

  final String text;
  final String? targetId;

  const WriteMessage(this.text, {this.targetId});

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'text': text, 'target': targetId};
}

/// Сообщение игроку от мастера или другого игрока: у получателя уведомление сверху экрана, без истории.
/// [from] — имя или «Мастер», [fromId] — `playerId` отправителя, чтобы ответить; `null` — от мастера.
class NoteMessage extends SessionMessage {
  static const typeName = 'note';

  /// Длиннее не принимается: это уведомление, а не письмо.
  static const maxLength = 300;

  final String text;
  final String from;
  final String? fromId;

  const NoteMessage(this.text, {required this.from, this.fromId});

  /// Текст для отправки: без пробелов по краям и не длиннее [maxLength]. `null` — пустое сообщение.
  static String? clean(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.length > maxLength ? trimmed.substring(0, maxLength) : trimmed;
  }

  @override
  String get type => typeName;

  @override
  Map<String, dynamic> _body() => {'text': text, 'from': from, 'fromId': fromId};
}
