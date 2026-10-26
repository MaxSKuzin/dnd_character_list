import 'package:dnd_character_list/domain/models/spell/spell_stat.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';

/// Заклинательная характеристика, Сл спасброска и бонус атаки заклинаниями — по ряду плиток на источник магии
/// (класс, раса). Без магии раздел не показывается.
class SpellsStatsSection extends StatelessWidget {
  const SpellsStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final spellStats = PlayerModel.spellStats(context);
    if (spellStats.isEmpty) return const SizedBox();
    // Как остальные разделы экрана боя: заголовок над карточкой.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: SheetSectionTitle(icon: Icons.auto_awesome_outlined, title: 'Магия'),
        ),
        SheetCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, stat) in spellStats.indexed) ...[
                  // Источник подписан, только если их несколько: «Бард», «Тифлинг».
                  if (spellStats.length > 1)
                    Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 0 : 12, bottom: 6),
                      child: Text(
                        stat.owner,
                        style: context.theme.textTheme.labelMedium?.copyWith(color: context.theme.colorScheme.primary),
                      ),
                    ),
                  _StatTiles(stat),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTiles extends StatelessWidget {
  final SpellStat stat;

  const _StatTiles(this.stat);

  @override
  Widget build(BuildContext context) {
    final valueStyle = context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);
    return TileGrid(
      columns: 3,
      children: [
        InfoTile(
          label: 'Способность',
          value: stat.statKind.localizedName.substring(0, 3).toUpperCase(),
          caption: stat.statKind.localizedName,
          valueStyle: valueStyle,
        ),
        InfoTile(label: 'Сл спасброска', value: '${stat.saveThrow}', valueStyle: valueStyle),
        InfoTile(
          label: 'Бонус атаки',
          value: '${stat.attackBonus >= 0 ? '+' : ''}${stat.attackBonus}',
          valueStyle: valueStyle,
        ),
      ],
    );
  }
}
