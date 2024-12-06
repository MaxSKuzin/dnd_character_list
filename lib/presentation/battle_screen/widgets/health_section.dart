import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HealthSection extends StatefulWidget {
  const HealthSection({
    super.key,
  });

  @override
  State<HealthSection> createState() => _HealthSectionState();
}

class _HealthSectionState extends State<HealthSection> {
  @override
  Widget build(BuildContext context) {
    final hits = PlayerModel.health(context);
    final isDead = PlayerModel.isDead(context);

    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'ЗДОРОВЬЕ',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: 'Здоровье макс. '),
                  TextSpan(
                    text: '${hits.max}',
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
              isDead ? '💀' : '${hits.current}',
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
