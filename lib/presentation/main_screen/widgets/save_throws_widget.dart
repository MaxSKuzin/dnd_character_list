import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/save_throw.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/skill_widget.dart';
import 'package:flutter/material.dart';

class SaveThrowsWidget extends StatelessWidget {
  final Player player;
  final List<SaveThrow> saves;

  const SaveThrowsWidget({
    super.key,
    required this.saves,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              bonus: save.getBonus(player),
              title: save.origin.name,
              isChosen: save.isChosen,
            )
        ],
      ),
    );
  }
}
