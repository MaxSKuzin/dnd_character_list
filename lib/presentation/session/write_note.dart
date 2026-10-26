import 'package:dnd_character_list/data/session/session_source.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';

/// Короткое сообщение мастеру (`targetId == null`) или другому игроку: у него уведомление с именем персонажа.
/// [to] — кому, для заголовка окна; [replyTo] — сообщение, на которое отвечают, для подсказки в окне.
Future<void> writeNote(BuildContext context, {String? targetId, required String to, String? replyTo}) async {
  final text = await NoteDialog.show(context, to: to, replyTo: replyTo);
  if (text == null || !context.mounted) return;
  final sent = getIt<SessionSource>().note(text, targetId: targetId);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(sent ? 'Сообщение отправлено: $to' : 'Нет связи с мастером')),
  );
}
