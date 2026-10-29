import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';

/// Оставшиеся кубы здоровья по классам: «3к8, 1к10» и под ними — все. Тратятся на коротком отдыхе, половина
/// возвращается после продолжительного.
class HitDices extends StatelessWidget {
  const HitDices({super.key});

  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.watch(context);
    return InfoTile(
      label: 'Кубы здоровья',
      value: player.hitDices,
      caption: 'из ${player.maxHitDices}',
      valueStyle: context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
