import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/skill_widget.dart';
import 'package:flutter/material.dart';

class SaveThrowsWidget extends StatelessWidget {
  const SaveThrowsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final saves = PlayerModel.saveThrows(context);
    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'СПАСБРОСКИ',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final save in saves)
              SkillWidget(
                bonus: save.bonus,
                title: save.origin.name,
                isChosen: save.isChosen,
              )
          ],
        ),
      ),
    );
  }
}
