import 'package:dnd_character_list/domain/models/cur_max.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class ManaSection extends StatelessWidget {
  final CurMax<int> mana;

  const ManaSection(
    this.mana, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'МАНА (МАКС. ${mana.max})',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Center(
          child: Text(
            '${mana.current}',
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
