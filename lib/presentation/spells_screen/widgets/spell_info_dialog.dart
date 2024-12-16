import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class SpellInfoDialog extends StatefulWidget {
  final Spell spell;
  final Player player;
  final Specialization spellOwner;

  static Future<void> show(
    BuildContext context, {
    required Spell spell,
    required Player player,
    required Specialization spellOwner,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<PlayerCubit>(),
        child: Dialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: SpellInfoDialog(
            spell: spell,
            player: player,
            spellOwner: spellOwner,
          ),
        ),
      ),
    );
  }

  const SpellInfoDialog({
    super.key,
    required this.spell,
    required this.player,
    required this.spellOwner,
  });

  @override
  State<SpellInfoDialog> createState() => _SpellInfoDialogState();
}

class _SpellInfoDialogState extends State<SpellInfoDialog> {
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
              '${widget.spell.slot.mana} маны',
            ),
          const Gap(8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.spell
                      .description(
                        widget.player,
                        widget.spellOwner,
                      )
                      .trim()),
                  if (widget.spell.slot != SpellSlot.conspiracy) ...[
                    const Gap(16),
                    BlocBuilder<PlayerCubit, Player>(
                      builder: (context, state) => FilledButton(
                        onPressed: state.currentMana >= widget.spell.slot.mana
                            ? () => context.read<PlayerCubit>().spendMana(widget.spell.slot.mana)
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
