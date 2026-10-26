import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
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
    final primary = context.theme.colorScheme.primary;
    return SheetSection(
      icon: Icons.theater_comedy_outlined,
      title: table.title,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOptional) const SheetBadge('по желанию'),
          IconButton(
            tooltip: 'Бросить кость',
            onPressed: () => onChanged(table.options[_random.nextInt(table.options.length)]),
            icon: const Icon(Icons.casino_outlined),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, option) in table.options.indexed)
            Material(
              color: option == selected ? primary.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(option == selected ? null : option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: option == selected ? primary : Colors.white54,
                          ),
                        ),
                      ),
                      Expanded(child: Text(option)),
                      if (option == selected) ...[const Gap(8), Icon(Icons.check, size: 18, color: primary)],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
