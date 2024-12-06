import 'package:collection/collection.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/skill_widget.dart';
import 'package:flutter/material.dart';

class PlayerSkillsList extends StatelessWidget {
  const PlayerSkillsList({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = PlayerModel.skills(context);
    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'НАВЫКИ',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          8,
          12,
          8,
          0,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final skill in skills.sorted((a, b) => a.origin.name.compareTo(b.origin.name)))
                SkillWidget(
                  key: Key(skill.origin.name),
                  title: '${skill.origin.name} (${skill.origin.origin.name.substring(0, 3)})',
                  isChosen: skill.isChosen,
                  bonus: skill.bonus,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
