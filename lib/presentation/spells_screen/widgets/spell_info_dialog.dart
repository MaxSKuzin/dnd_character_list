import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class SpellInfoDialog extends StatefulWidget {
  static Future<void> show(
    BuildContext context, {
    required Spell spell,
    required String Function(SpellSlot slot) spellDescription,
    bool canDrainMana = true,
  }) async {
    await showDialog(
      context: context,
      builder: (_) {
        final child = Dialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: SpellInfoDialog(
            spell: spell,
            canDrainMana: canDrainMana,
            spellDescription:  spellDescription,
          ),
        );
        return canDrainMana
            ? BlocProvider.value(
                value: context.read<PlayerCubit>(),
                child: child,
              )
            : child;
      },
    );
  }

  final Spell spell;
  final String Function(SpellSlot slot) spellDescription;
  final bool canDrainMana;

  const SpellInfoDialog({
    super.key,
    required this.spell,
    required this.canDrainMana,
    required this.spellDescription,
  });

  @override
  State<SpellInfoDialog> createState() => _SpellInfoDialogState();
}

class _SpellInfoDialogState extends State<SpellInfoDialog> {
  late SpellSlot? _slot = widget.spell.slot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.spell.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.spell.slot != SpellSlot.conspiracy)
            Text(
              '${_slot?.mana ?? widget.spell.slot.mana} маны',
            ),
          if (widget.spell.hasEffectOnHigherLevels) ...[
            const Gap(8),
            const Text('Ячейка'),
            const Gap(8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: SpellSlot.values
                  .where(
                (e) => e.index >= widget.spell.slot.index,
              )
                  .map((e) {
                return GestureDetector(
                  onTap: () => setState(() {
                    _slot = e;
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: e == _slot ? Colors.white : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      '${e.index}',
                      style: TextStyle(
                        color: e == _slot ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const Gap(8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextParses(
                    widget.spellDescription(_slot ?? widget.spell.slot).trim(),
                  ),
                  if (widget.canDrainMana && widget.spell.slot != SpellSlot.conspiracy) ...[
                    const Gap(16),
                    BlocBuilder<PlayerCubit, Player>(
                      builder: (context, state) => FilledButton(
                        onPressed: state.currentMana >= (_slot?.mana ?? widget.spell.slot.mana)
                            ? () => context.read<PlayerCubit>().spendMana(_slot?.mana ?? widget.spell.slot.mana)
                            : null,
                        child: const Text('Использовать'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
