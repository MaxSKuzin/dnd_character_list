import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ячейки заклинаний: по плитке на уровень с остатком и максимумом, как счётчики здоровья и ресурсов классов.
/// Восстанавливаются продолжительным отдыхом (`RestButton`).
class SpellSlotsSection extends StatelessWidget {
  static const _columns = 3;
  static const _spacing = 12.0;

  const SpellSlotsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, Player>(
      builder: (context, player) {
        final levels = player.spellSlotLevels;
        if (levels.isEmpty) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: SheetSectionTitle(icon: Icons.local_fire_department_outlined, title: 'Ячейки заклинаний'),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - _spacing * (_columns - 1)) / _columns;
                return Wrap(
                  spacing: _spacing,
                  runSpacing: _spacing,
                  children: [
                    for (final slot in levels)
                      SizedBox(
                        width: width,
                        child: _SlotTile(
                          slot: slot,
                          current: player.currentSpellSlots[slot] ?? 0,
                          max: player.spellCells[slot] ?? 0,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SlotTile extends StatelessWidget {
  final SpellSlot slot;
  final int current;
  final int max;

  const _SlotTile({required this.slot, required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    // Ячейки сверх максимума созданы из единиц чародейства.
    final isOverMax = current > max;
    return Theme(
      data: context.theme.copyWith(
        iconButtonTheme: IconButtonThemeData(
          style: context.theme.iconButtonTheme.style?.copyWith(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
      child: LabeledBorder(
        backgroundColor: context.customColors?.cardColor,
        text: '${slot.level} УРОВЕНЬ',
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: current > 0 ? () => cubit.spendSpellSlot(slot) : null,
                icon: const Text('-'),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$current',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isOverMax ? Colors.amber : null,
                        ),
                      ),
                      TextSpan(text: '/$max', style: context.theme.textTheme.bodySmall),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: current < max ? () => cubit.restoreSpellSlot(slot) : null,
                icon: const Text('+'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
