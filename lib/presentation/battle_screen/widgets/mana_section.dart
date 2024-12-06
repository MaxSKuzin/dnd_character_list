import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';

class ManaSection extends StatelessWidget {
  const ManaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mana = PlayerModel.mana(context);

    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'МАНА',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Center(
          child: Text(
            '${mana.current}/${mana.max}',
            style: context.theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
