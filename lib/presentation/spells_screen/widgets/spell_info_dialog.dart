import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class SpellInfoDialog extends StatelessWidget {
  static Future<void> show(
    BuildContext context, {
    required Spell spell,
    required String spellDescription,
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
            spellDescription: spellDescription,
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
  final String spellDescription;
  final bool canDrainMana;

  const SpellInfoDialog({
    super.key,
    required this.spell,
    required this.canDrainMana,
    required this.spellDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            spell.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (spell.slot != SpellSlot.conspiracy)
            Text(
              '${spell.slot.mana} маны',
            ),
          const Gap(8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    spellDescription.trim(),
                  ),
                  if (canDrainMana && spell.slot != SpellSlot.conspiracy) ...[
                    const Gap(16),
                    BlocBuilder<PlayerCubit, Player>(
                      builder: (context, state) => FilledButton(
                        onPressed: state.currentMana >= spell.slot.mana
                            ? () => context.read<PlayerCubit>().spendMana(spell.slot.mana)
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
