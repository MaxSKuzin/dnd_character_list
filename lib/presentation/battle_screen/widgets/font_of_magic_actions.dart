import 'dart:math';

import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/sorcerer.dart';
import 'package:dnd_character_list/domain/models/metamagic.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Действия с единицами чародейства в диалоге ресурса (как описание вдохновения барда):
/// «Источник магии» — превращение ячеек в единицы и обратно, и метамагия.
class FontOfMagicActions extends StatelessWidget {
  const FontOfMagicActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, Player>(
      builder: (context, player) {
        if (player.maxSorceryPoints == 0) return const SizedBox();
        final cubit = context.read<PlayerCubit>();
        final metamagic = player.classes.whereType<Sorcerer>().expand((e) => e.metamagic).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Осталось ${player.currentSorceryPoints} из ${player.maxSorceryPoints}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final slot = await _chooseSlot(
                        context,
                        title: 'Ячейка → единицы',
                        options: {
                          for (final slot in player.spellSlotLevels)
                            slot: (
                              label: '${slot.level} уровень: +${slot.level} ед. '
                                  '(осталось ячеек ${player.currentSpellSlots[slot] ?? 0})',
                              enabled: player.canConvertToSorceryPoints(slot),
                            ),
                        },
                      );
                      if (slot != null) cubit.convertSpellSlotToSorceryPoints(slot);
                    },
                    child: const Text('Ячейка → единицы', textAlign: TextAlign.center),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final slot = await _chooseSlot(
                        context,
                        title: 'Единицы → ячейка',
                        description: 'Созданная ячейка исчезает после продолжительного отдыха.',
                        options: {
                          for (final MapEntry(key: slot, value: cost) in Sorcerer.spellSlotCost.entries)
                            slot: (
                              label: '${slot.level} уровень: −$cost ед.',
                              enabled: player.canCreateSpellSlot(slot),
                            ),
                        },
                      );
                      if (slot != null) cubit.createSpellSlot(slot);
                    },
                    child: const Text('Единицы → ячейка', textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
            if (metamagic.isNotEmpty) ...[
              const Gap(16),
              const Text('МЕТАМАГИЯ', textAlign: TextAlign.center),
              const Gap(8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final option in metamagic) _MetamagicChip(option: option, player: player),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MetamagicChip extends StatelessWidget {
  final Metamagic option;
  final Player player;

  const _MetamagicChip({required this.option, required this.player});

  bool get _isTwinned => option.link == Sorcerer.twinnedSpell;

  Future<void> _use(BuildContext context) async {
    final cubit = context.read<PlayerCubit>();
    var cost = Sorcerer.metamagicCost[option.link];
    if (_isTwinned) {
      // «Удвоенное заклинание» стоит столько единиц, каков уровень заклинания (заговор — 1).
      final slot = await _chooseSlot(
        context,
        title: option.name,
        description: 'Уровень заклинания',
        options: {
          for (final slot in SpellSlot.values.take((player.spellSlotLevels.lastOrNull?.index ?? 0) + 1))
            slot: (
              label: '${slot == SpellSlot.conspiracy ? 'Заговор' : '${slot.level} уровень'}: '
                  '−${max(1, slot.level)} ед.',
              enabled: player.currentSorceryPoints >= max(1, slot.level),
            ),
        },
      );
      if (slot == null) return;
      cost = max(1, slot.level);
    }
    if (cost != null) cubit.spendSorceryPoints(cost);
  }

  @override
  Widget build(BuildContext context) {
    final cost = Sorcerer.metamagicCost[option.link];
    final enabled = _isTwinned ? player.currentSorceryPoints > 0 : cost != null && player.currentSorceryPoints >= cost;
    return GestureDetector(
      onLongPress: () => showDialog(
        context: context,
        builder: (_) => HtmlDialog(title: option.name, html: option.descriptionHtml),
      ),
      child: ActionChip(
        label: Text('${option.name} · ${_isTwinned ? 'ур. закл.' : '$cost'} ед.'),
        onPressed: enabled ? () => _use(context) : null,
      ),
    );
  }
}

typedef _SlotOption = ({String label, bool enabled});

/// Выбор уровня ячейки; недоступные варианты показываются, но не нажимаются.
Future<SpellSlot?> _chooseSlot(
  BuildContext context, {
  required String title,
  String? description,
  required Map<SpellSlot, _SlotOption> options,
}) =>
    showDialog<SpellSlot>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          if (description != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(description),
            ),
          for (final MapEntry(key: slot, value: option) in options.entries)
            SimpleDialogOption(
              onPressed: option.enabled ? () => Navigator.pop(context, slot) : null,
              child: Text(option.label, style: TextStyle(color: option.enabled ? null : Colors.grey)),
            ),
        ],
      ),
    );
