import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/cur_max.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManaSection extends StatefulWidget {
  final CurMax<int> mana;

  const ManaSection(
    this.mana, {
    super.key,
  });

  @override
  State<ManaSection> createState() => _ManaSectionState();
}

class _ManaSectionState extends State<ManaSection> {
  @override
  Widget build(BuildContext context) {
    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'МАНА (МАКС. ${widget.mana.max})',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: () async {
                final mana = await EnterNumberDialog.show(
                  context,
                  title: 'Введите потраченную ману',
                  labelText: 'Мана',
                );
                if (!mounted || mana == null) return;
                context.read<PlayerCubit>().spendMana(mana);
              },
              icon: const Text('-'),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${widget.mana.current}',
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                final mana = await EnterNumberDialog.show(
                  context,
                  title: 'Введите востановленную ману',
                  labelText: 'Мана',
                );
                if (!mounted || mana == null) return;
                context.read<PlayerCubit>().recoverMana(mana);
              },
              icon: const Text('+'),
            ),
          ],
        ),
      ),
    );
  }
}
