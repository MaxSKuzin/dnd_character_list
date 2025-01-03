import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class PeculiarityWidget extends StatelessWidget {
  final Peculiarity classAbility;

  const PeculiarityWidget({super.key, required this.classAbility});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showDialog(
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
              child: _DialogInfo(classAbility: classAbility),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 16,
          ),
          child: Text(
            classAbility.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _DialogInfo extends StatefulWidget {
  final Peculiarity classAbility;

  const _DialogInfo({
    required this.classAbility,
  });

  @override
  State<_DialogInfo> createState() => _DialogInfoState();
}

class _DialogInfoState extends State<_DialogInfo> {
  late SpellSlot? _slot = widget.classAbility.manaRequired;

  @override
  Widget build(BuildContext context) {
    final availableSlots = widget.classAbility.manaRequired != null
        ? context
            .read<PlayerCubit>()
            .state
            .spellCells
            .entries
            .where(
              (e) => e.key.index >= widget.classAbility.manaRequired!.index && e.value > 0,
            )
            .map((e) => e.key)
            .toList()
        : <SpellSlot>[];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.classAbility.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (widget.classAbility.manaRequired != null && availableSlots.length > 1) ...[
            const Gap(8),
            const Text('Ячейка'),
            const Gap(8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: availableSlots.map((e) {
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
            const Gap(8),
          ],
          const Gap(8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextParses(
                    widget.classAbility.description.trim(),
                  ),
                  if (_slot != null)
                    TextParses(
                      '\n${widget.classAbility.magicDescription(_slot!)}',
                    ),
                ],
              ),
            ),
          ),
          if (_slot != null)
            BlocBuilder<PlayerCubit, Player>(
              builder: (context, state) => Column(
                children: [
                  const Gap(8),
                  OutlinedButton(
                    onPressed: state.currentMana >= _slot!.mana
                        ? () {
                            context.read<PlayerCubit>().spendMana(
                                  _slot!.mana,
                                );
                            Navigator.pop(context);
                          }
                        : null,
                    child: Text('Использовать (${_slot!.mana} маны)'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
