import 'package:dnd_character_list/domain/models/spell/spell_stat.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/common/widgets/separated_column.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SpellsStatsSection extends StatelessWidget {
  final List<SpellStat> spellStats;

  const SpellsStatsSection(
    this.spellStats, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SeparatedColumn(
      separatorBuilder: (context, index) => const Gap(16),
      children: spellStats
          .map(
            (e) => LabeledBorder(
              backgroundColor: context.customColors?.cardColor,
              text: e.owner.toUpperCase(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: LabeledBorder(
                          backgroundColor: context.theme.scaffoldBackgroundColor,
                          text: 'СПОСОБНОСТЬ',
                          fontSize: 6,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                            child: Center(
                              child: Text(e.statKind.name.substring(0, 3).toUpperCase()),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Center(
                        child: LabeledBorder(
                          backgroundColor: context.theme.scaffoldBackgroundColor,
                          text: 'СПАСБРОСОК',
                          fontSize: 6,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                            child: Center(
                              child: Text('${e.saveThrow}'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Center(
                        child: LabeledBorder(
                          backgroundColor: context.theme.scaffoldBackgroundColor,
                          text: 'БОНУС АТАКИ',
                          fontSize: 6,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                            child: Center(
                              child: Text('+${e.attackBonus}'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
