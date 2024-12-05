import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class StatWidget extends StatelessWidget {
  final Stat stat;

  const StatWidget({
    super.key,
    required this.stat,
  });

  @override
  Widget build(BuildContext context) {
    return LabeledBorder(
      labelBorderStyle: LabelBorderStyle.circle,
      backgroundColor: context.customColors?.cardColor,
      text: stat.value.toString(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              child: Text(
                stat.kind.name,
              ),
            ),
            const Gap(8),
            Text(
              '${stat.bonus >= 0 ? '+' : ''}${stat.bonus}',
              style: context.theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
