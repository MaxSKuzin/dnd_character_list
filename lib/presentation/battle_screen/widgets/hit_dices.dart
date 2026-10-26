import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';

/// Кубы здоровья по классам: «3к8, 1к10».
class HitDices extends StatelessWidget {
  const HitDices({super.key});

  @override
  Widget build(BuildContext context) {
    final hitDices = PlayerModel.watch(context).hitDices;
    return InfoTile(
      label: 'Кубы здоровья',
      value: hitDices,
      valueStyle: context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
