import 'package:dnd_master/domain/bloc/battle_cubit.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Эффекты участника: просмотр описания, снятие, добавление.
class StatusesSection extends StatelessWidget {
  final String combatantId;
  final List<StatusEffect> statuses;

  const StatusesSection({super.key, required this.combatantId, required this.statuses});

  Future<void> _add(BuildContext context) async {
    final cubit = context.read<BattleCubit>();
    final status = await showDialog<_NewStatus>(context: context, builder: (_) => const _AddStatusDialog());
    if (status == null) return;
    cubit.addStatus(
      combatantId,
      condition: status.condition,
      title: status.title,
      description: status.description,
      turns: status.turns,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Эффекты', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final status in statuses)
              InputChip(
                label: Text(status.label),
                onPressed: () => showStatusDescription(context, status),
                onDeleted: () => context.read<BattleCubit>().removeStatus(combatantId, status.id),
                deleteButtonTooltipMessage: 'Снять',
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Добавить эффект'),
              onPressed: () => _add(context),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> showStatusDescription(BuildContext context, StatusEffect status) => showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(status.title),
    content: Text(
      [
        if (status.description.isNotEmpty) status.description,
        status.turns == null ? 'Пока мастер не снимет.' : 'Осталось: ${turnsLabel(status.turns!)}.',
      ].join('\n\n'),
    ),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Закрыть'))],
  ),
);

class _NewStatus {
  final Condition? condition;
  final String? title;
  final String description;
  final int? turns;

  const _NewStatus({this.condition, this.title, this.description = '', this.turns});
}

/// Новый эффект: состояние из книги или своё («Удивлён — ты отказываешься биться»), длительность в ходах.
class _AddStatusDialog extends StatefulWidget {
  const _AddStatusDialog();

  @override
  State<_AddStatusDialog> createState() => _AddStatusDialogState();
}

class _AddStatusDialogState extends State<_AddStatusDialog> {
  /// `null` — свой эффект.
  Condition? _condition;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _turnsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _turnsController.dispose();
    super.dispose();
  }

  bool get _canSave => _condition != null || _titleController.text.trim().isNotEmpty;

  void _save() {
    if (!_canSave) return;
    final turns = int.tryParse(_turnsController.text.trim());
    Navigator.pop(
      context,
      _NewStatus(
        condition: _condition,
        title: _condition == null ? _titleController.text.trim() : null,
        description: _condition == null ? _descriptionController.text.trim() : '',
        turns: turns != null && turns > 0 ? turns : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новый эффект'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<Condition?>(
              initialValue: _condition,
              decoration: const InputDecoration(labelText: 'Эффект'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Свой эффект')),
                for (final condition in Condition.values)
                  DropdownMenuItem(value: condition, child: Text(condition.title)),
              ],
              onChanged: (value) => setState(() => _condition = value),
            ),
            if (_condition == null) ...[
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Название', hintText: 'Удивлён'),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _descriptionController,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Описание', hintText: 'Ты отказываешься биться'),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(_condition!.description, style: Theme.of(context).textTheme.bodySmall),
            ],
            TextField(
              controller: _turnsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Длительность в ходах',
                helperText: 'Пусто — пока не снимете. Ход уменьшается в конце хода участника.',
                helperMaxLines: 2,
              ),
              onSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        FilledButton(onPressed: _canSave ? _save : null, child: const Text('Добавить')),
      ],
    );
  }
}
