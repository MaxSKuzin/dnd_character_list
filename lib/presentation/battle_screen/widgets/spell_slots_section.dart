import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/common/widgets/spell_slot_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ячейки заклинаний: карточка с плиткой на уровень — остаток, кружки и кнопки «−»/«+».
/// Восстанавливаются продолжительным отдыхом (`RestButton`).
class SpellSlotsSection extends StatelessWidget {
  const SpellSlotsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, Player>(
      builder: (context, player) {
        final levels = player.spellSlotLevels;
        if (levels.isEmpty) return const SizedBox();
        final cubit = context.read<PlayerCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
              child: SheetSectionTitle(icon: Icons.local_fire_department_outlined, title: 'Ячейки заклинаний'),
            ),
            SheetCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TileGrid(
                  columns: 3,
                  children: [
                    for (final slot in levels)
                      Builder(
                        builder: (context) {
                          final current = player.currentSpellSlots[slot] ?? 0;
                          final max = player.spellCells[slot] ?? 0;
                          return SpellSlotTile(
                            slot: slot,
                            current: current,
                            max: max,
                            onSpend: current > 0 ? () => cubit.spendSpellSlot(slot) : null,
                            onRestore: current < max ? () => cubit.restoreSpellSlot(slot) : null,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            // Отступ до раздела магии, который всегда идёт следом.
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
