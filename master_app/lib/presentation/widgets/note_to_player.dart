import 'package:dnd_master/domain/bloc/battle_cubit.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Короткое сообщение игроку: у него уведомление «Мастер: …». [replyTo] — сообщение игрока, на которое отвечают,
/// для подсказки в окне.
Future<void> writeToPlayer(
  BuildContext context, {
  required String playerId,
  required String name,
  String? replyTo,
}) async {
  final text = await NoteDialog.show(context, to: name, replyTo: replyTo);
  if (text == null || !context.mounted) return;
  final sent = context.read<BattleCubit>().note(playerId, text);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(sent ? 'Сообщение отправлено: $name' : '$name не на связи')));
}
