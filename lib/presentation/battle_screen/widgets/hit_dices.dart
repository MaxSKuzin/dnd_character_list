import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';

class HitDices extends StatelessWidget {
  const HitDices({super.key});

  @override
  Widget build(BuildContext context) {
    PlayerModel.health(context);
    final hitDices = PlayerModel.getPlayer(context).hitDices;
    return LabeledBorder(
      backgroundColor: context.customColors?.cardColor,
      text: 'КУБЫ ЗДОРОВЬЯ',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Center(
          child: Text(
            hitDices,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
