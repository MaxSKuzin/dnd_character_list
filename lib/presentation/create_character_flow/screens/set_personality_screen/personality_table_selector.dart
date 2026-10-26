import 'dart:math';

import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Таблица персонализации предыстории: выбор одной строки вручную или броском кости.
class PersonalityTableSelector extends StatelessWidget {
  static final _random = Random();

  final PersonalityTable table;
  final String? selected;

  /// Получает выбранную строку или `null`, если выбор снят.
  final ValueChanged<String?> onChanged;

  const PersonalityTableSelector({
    super.key,
    required this.table,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOptional = table.kind == PersonalityTableKind.other;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${table.title}${isOptional ? ' (по желанию)' : ''}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'Бросить кость',
              onPressed: () => onChanged(table.options[_random.nextInt(table.options.length)]),
              icon: const Icon(Icons.casino),
            ),
          ],
        ),
        const Gap(4),
        for (final (index, option) in table.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: option == selected ? context.customColors?.cardColor : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: option == selected ? Colors.white : Colors.white24),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onChanged(option == selected ? null : option),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('${index + 1}. $option'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
