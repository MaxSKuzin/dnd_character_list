import 'package:dnd_character_list/data/session/session_source.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/session/session_sheet.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';

/// Кнопка сессии мастера в шапке экрана боя: показывает состояние подключения и открывает [SessionSheet].
class SessionButton extends StatelessWidget {
  const SessionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final source = getIt<SessionSource>();
    return StreamBuilder<SessionStatus>(
      stream: source.statusStream,
      initialData: source.status,
      builder: (context, snapshot) {
        final player = PlayerModel.getPlayer(context);
        final status = source.isJoined(player) ? snapshot.requireData : const SessionDisconnected();
        final (icon, label) = switch (status) {
          SessionConnected(:final sessionName) => (Icons.wifi, sessionName),
          SessionConnecting() || SessionReconnecting() => (Icons.wifi_find, 'Подключение…'),
          SessionDisconnected() => (Icons.wifi_off, 'Сессия мастера'),
        };
        return TextButton.icon(
          onPressed: () => SessionSheet.show(context, PlayerModel.getPlayer(context)),
          icon: Icon(icon),
          label: Text(label, overflow: TextOverflow.ellipsis),
        );
      },
    );
  }
}
