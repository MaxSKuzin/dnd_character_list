import 'package:dnd_session/src/protocol/session_message.dart';
import 'package:flutter/material.dart';

/// Ввод короткого сообщения мастеру или игроку. Возвращает текст или `null`, если отменили или ничего не ввели.
///
/// ```dart
/// final text = await NoteDialog.show(context, to: 'Лира');
/// ```
class NoteDialog extends StatefulWidget {
  /// Кому — для заголовка: «Сообщение: Лира».
  final String to;

  /// Сообщение, на которое отвечают: показывается над полем ввода.
  final String? replyTo;

  const NoteDialog({super.key, required this.to, this.replyTo});

  static Future<String?> show(BuildContext context, {required String to, String? replyTo}) => showDialog<String>(
    context: context,
    builder: (_) => NoteDialog(to: to, replyTo: replyTo),
  );

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() => Navigator.pop(context, NoteMessage.clean(_controller.text));

  @override
  Widget build(BuildContext context) {
    final replyTo = widget.replyTo;
    return AlertDialog(
      title: Text('Сообщение: ${widget.to}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (replyTo != null) ...[
            Text(replyTo, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            maxLength: NoteMessage.maxLength,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.send,
            decoration: const InputDecoration(hintText: 'Можно я осмотрю сундук?'),
            onSubmitted: (_) => _send(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        TextButton(onPressed: _send, child: const Text('Отправить')),
      ],
    );
  }
}
