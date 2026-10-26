import 'dart:ui';

import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Кнопка ячеек заклинаний на экране заклинаний: раскрывается в небольшую сетку с остатком ячеек по уровням.
/// Только показ — ячейки тратятся из описания заклинания и на экране боя. Без ячеек кнопки нет.
class SpellSlotsFab extends StatefulWidget {
  const SpellSlotsFab({super.key});

  @override
  State<SpellSlotsFab> createState() => _SpellSlotsFabState();
}

class _SpellSlotsFabState extends State<SpellSlotsFab> with SingleTickerProviderStateMixin {
  /// Раскрытие карточки в обе стороны: при закрытии она остаётся на экране, пока анимация не закончится.
  late final AnimationController _controller;
  late final Animation<double> _card;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    )..addStatusListener((_) => setState(() {}));
    _card = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic);
  }

  bool get _isOpen => _controller.status == AnimationStatus.forward || _controller.status == AnimationStatus.completed;

  void _toggle() => _isOpen ? _controller.reverse() : _controller.forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Плитки уровней проявляются по очереди: каждая в своём отрезке анимации.
  Animation<double> _tileAnimation(int index, int count) {
    final start = 0.25 + 0.5 * index / count;
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start.clamp(0, 0.9), (start + 0.35).clamp(0, 1), curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.watch(context);
    final levels = player.spellSlotLevels;
    if (levels.isEmpty) return const SizedBox.shrink();
    final width = (MediaQuery.sizeOf(context).width - 32).clamp(0.0, 320.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_controller.status != AnimationStatus.dismissed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            // Карточка вырастает из угла кнопки и проявляется.
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)),
              child: ScaleTransition(
                scale: Tween(begin: 0.6, end: 1.0).animate(_card),
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: width,
                  // Полупрозрачная карточка: под ней видно список, размытие сохраняет читаемость.
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: SheetSection(
                        color: context.customColors?.cardColor.withValues(alpha: 0.7),
                        icon: Icons.local_fire_department_outlined,
                        title: 'Ячейки заклинаний',
                        child: TileGrid(
                          columns: 3,
                          children: [
                            for (final (index, slot) in levels.indexed)
                              FadeTransition(
                                opacity: _tileAnimation(index, levels.length),
                                child: SlideTransition(
                                  position: Tween(begin: const Offset(0, 0.25), end: Offset.zero)
                                      .animate(_tileAnimation(index, levels.length)),
                                  child: _SlotTile(
                                    slot: slot,
                                    current: player.currentSpellSlots[slot] ?? 0,
                                    max: player.spellCells[slot] ?? 0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        FloatingActionButton(
          tooltip: _isOpen ? 'Скрыть ячейки' : 'Ячейки заклинаний',
          onPressed: _toggle,
          // Пламя поворачивается и сменяется крестиком.
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween(begin: 0.75, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(_isOpen ? Icons.close : Icons.local_fire_department, key: ValueKey(_isOpen)),
          ),
        ),
      ],
    );
  }
}

/// Остаток ячеек уровня: «3/4» и кружки — закрашенные доступны. Созданные из единиц чародейства ячейки сверх
/// максимума выделены цветом.
class _SlotTile extends StatelessWidget {
  final SpellSlot slot;
  final int current;
  final int max;

  const _SlotTile({required this.slot, required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final primary = context.theme.colorScheme.primary;
    final isOverMax = current > max;
    final total = isOverMax ? current : max;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: current == 0 ? Colors.white12 : Colors.white24),
      ),
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
        ],
      ),
    );
  }
}
