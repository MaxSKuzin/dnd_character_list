import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Остаток ячеек уровня: «3/4» и кружки — закрашенные доступны. Созданные из единиц чародейства ячейки сверх
/// максимума выделены цветом. С [onSpend] и [onRestore] — кнопки «−» и «+» под кружками (экран боя), без них —
/// только показ (кнопка ячеек на экране заклинаний).
class SpellSlotTile extends StatelessWidget {
  final SpellSlot slot;
  final int current;
  final int max;
  final VoidCallback? onSpend;
  final VoidCallback? onRestore;

  /// Фон; по умолчанию — цвет экрана.
  final Color? color;

  const SpellSlotTile({
    super.key,
    required this.slot,
    required this.current,
    required this.max,
    this.onSpend,
    this.onRestore,
    this.color,
  });

  bool get _hasButtons => onSpend != null || onRestore != null;

  @override
  Widget build(BuildContext context) {
    final primary = context.theme.colorScheme.primary;
    final isOverMax = current > max;
    final total = isOverMax ? current : max;
    return SheetTile(
      color: color,
      borderColor: current == 0 ? Colors.white12 : Colors.white24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${slot.level} уровень', style: context.theme.textTheme.labelSmall?.copyWith(color: Colors.white60)),
          const Gap(2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$current',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: isOverMax ? Colors.amber : (current == 0 ? Colors.white38 : null),
                  ),
                ),
                TextSpan(text: '/$max', style: context.theme.textTheme.bodySmall),
              ],
            ),
          ),
          const Gap(4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 3,
            runSpacing: 3,
            children: [
              for (var i = 0; i < total; i++)
                Icon(
                  i < current ? Icons.circle : Icons.circle_outlined,
                  size: 8,
                  color: i < current ? (i >= max ? Colors.amber : primary) : Colors.white24,
                ),
            ],
          ),
          if (_hasButtons) ...[
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StepButton.decrease(tooltip: 'Потратить ячейку ${slot.level} уровня', onPressed: onSpend),
                StepButton.increase(tooltip: 'Вернуть ячейку ${slot.level} уровня', onPressed: onRestore),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
