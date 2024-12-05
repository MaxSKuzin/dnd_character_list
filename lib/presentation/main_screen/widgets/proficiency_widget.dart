import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';

class ProficiencyWidget extends StatelessWidget {
  const ProficiencyWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final proficiencyBonus = PlayerModel.proficiencyBonus(context);
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Colors.white),
        ),
        color: context.customColors?.cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Бонус мастерства: +$proficiencyBonus',
          style: context.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
