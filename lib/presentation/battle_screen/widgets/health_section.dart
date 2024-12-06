import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';

class HealthSection extends StatelessWidget {
  const HealthSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hits = PlayerModel.health(context);
    final isDead = PlayerModel.isDead(context);

    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'ЗДОРОВЬЕ',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Center(
          child: Text(
            isDead ? '💀' : '${hits.current}/${hits.max}',
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
