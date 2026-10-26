import 'package:flutter/material.dart';

/// Ввод числа: инициатива и т.п. `null` — отмена. [cancelLabel] — подпись кнопки отмены, например «Пропустить».
Future<int?> askNumber(
  BuildContext context, {
  required String title,
  int? initial,
  String? hint,
  String cancelLabel = 'Отмена',
}) => showDialog<int>(
  context: context,
  builder: (context) => _NumberDialog(
    title: title,
    initial: initial,
    hint: hint,
    onSubmitted: (value) => Navigator.pop(context, value),
    actions: (value) => [
      TextButton(onPressed: () => Navigator.pop(context), child: Text(cancelLabel)),
      TextButton(onPressed: () => Navigator.pop(context, value()), child: const Text('Готово')),
    ],
  ),
);

/// Урон или лечение: отрицательное число — урон, положительное — лечение. `null` — отмена.
/// Enter в поле — урон, это частый случай.
Future<int?> askHitsChange(BuildContext context, {required String title}) => showDialog<int>(
  context: context,
  builder: (context) => _NumberDialog(
    title: title,
    onSubmitted: (value) => Navigator.pop(context, value == null ? null : -value.abs()),
    actions: (value) => [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
      TextButton(onPressed: () => Navigator.pop(context, value()?.abs()), child: const Text('Лечение')),
      FilledButton(
        onPressed: () {
          final hits = value();
          Navigator.pop(context, hits == null ? null : -hits.abs());
        },
        child: const Text('Урон'),
      ),
    ],
  ),
);

class _NumberDialog extends StatefulWidget {
  final String title;
  final int? initial;
  final String? hint;
  final ValueChanged<int?> onSubmitted;

  /// Кнопки диалога; `value` возвращает введённое число или `null`.
  final List<Widget> Function(int? Function() value) actions;

  const _NumberDialog({required this.title, this.initial, this.hint, required this.onSubmitted, required this.actions});

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  late final _controller = TextEditingController(text: widget.initial?.toString() ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _value() => int.tryParse(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        decoration: InputDecoration(helperText: widget.hint),
        onSubmitted: (_) => widget.onSubmitted(_value()),
      ),
      actions: widget.actions(_value),
    );
  }
}
