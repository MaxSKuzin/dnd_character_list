import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ManaSection extends StatelessWidget {
  const ManaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mana = PlayerModel.mana(context);

    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'МАНА',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: 'Мана\nмакс. '),
                  TextSpan(
                    text: '${mana.max}',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              '${mana.current}',
              style: context.theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
