import 'package:dnd_character_list/data/session/session_source.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:flutter/material.dart';

/// Игрок бросил к20 вживую и вводит результат с бонусом — он уходит мастеру в очередь боя.
Future<void> askInitiative(BuildContext context, Player player) async {
  final bonus = player.initiative;
  final value = await EnterNumberDialog.show(
    context,
    title: 'Бросок инициативы',
    labelText: 'к20 ${bonus >= 0 ? '+' : '−'} ${bonus.abs()}',
  );
  if (value == null || !context.mounted) return;
  final sent = getIt<SessionSource>().sendInitiative(value);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(sent ? 'Инициатива $value отправлена мастеру' : 'Нет связи с мастером')),
  );
}
