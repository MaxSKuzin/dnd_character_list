import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class FillStatsScreen extends StatefulWidget {
  final Map<StatKind, int> initialStats;
  final int maxPoints;
  final bool isInitial;

  /// Получает прибавку к [initialStats] (при пустых [initialStats] — сами значения).
  final void Function(Map<StatKind, int> stats) onStatsFilled;
  final bool canSpendOnOneStat;
  final String? title;
  final String? description;
  final List<StatKind> forbiddenStats;

  /// Рекомендации класса из раздела «Быстрое создание» на ttg.club.
  final String? quickBuildHtml;

  const FillStatsScreen({
    super.key,
    this.title,
    this.description,
    this.isInitial = true,
    this.canSpendOnOneStat = true,
    this.maxPoints = 27,
    this.initialStats = const {},
    this.forbiddenStats = const [],
    this.quickBuildHtml,
    required this.onStatsFilled,
  });

  @override
  State<FillStatsScreen> createState() => _FillStatsScreenState();
}

class _FillStatsScreenState extends State<FillStatsScreen> {
  late int points = widget.maxPoints;

  late final stats = {
    StatKind.strength: widget.initialStats[StatKind.strength] ?? 8,
    StatKind.dexterity: widget.initialStats[StatKind.dexterity] ?? 8,
    StatKind.constitution: widget.initialStats[StatKind.constitution] ?? 8,
    StatKind.intelligence: widget.initialStats[StatKind.intelligence] ?? 8,
    StatKind.wisdom: widget.initialStats[StatKind.wisdom] ?? 8,
    StatKind.charisma: widget.initialStats[StatKind.charisma] ?? 8,
  };

  bool _canAdd(StatKind kind, int value) =>
      !widget.forbiddenStats.contains(kind) &&
      (widget.isInitial
          ? value < 15 && (value >= 13 && points > 1 || value < 13)
          : value < 20 && (widget.canSpendOnOneStat || value <= widget.initialStats[kind]!));

  bool _canSubtract(StatKind kind, int value) => widget.isInitial ? value > 8 : value > widget.initialStats[kind]!;

  void _add(StatKind kind) => setState(() {
        final value = stats[kind]!;
        if (points > 0) {
          points--;
          // При покупке очками 14 и 15 стоят по 2 очка.
          if (widget.isInitial && value >= 13) points--;
          stats[kind] = value + 1;
        }
      });

  void _subtract(StatKind kind) => setState(() {
        final value = stats[kind]!;
        if (points < 27) {
          points++;
          if (widget.isInitial && value > 13) points++;
          stats[kind] = value - 1;
        }
      });

  @override
  Widget build(BuildContext context) {
    final valueStyle = context.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700);
    return StepScaffold(
      title: widget.title ?? 'Характеристики',
      description: widget.description,
      counter: 'Осталось $points из ${widget.maxPoints}',
      isCounterDone: points == 0,
      onAction: points == 0
          ? () => widget.onStatsFilled(
                stats.map((key, value) => MapEntry(key, value - (widget.initialStats[key] ?? 0))),
              )
          : null,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SheetCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TileGrid(
                columns: 2,
                children: [
                  for (final MapEntry(key: kind, :value) in stats.entries)
                    InfoTile(
                      label: kind.localizedName,
                      value: '$value',
                      caption: _signed(Stat(value: value, kind: kind).bonus),
                      valueStyle: valueStyle,
                      decreaseTooltip: '${kind.localizedName}: меньше',
                      increaseTooltip: '${kind.localizedName}: больше',
                      onDecrease: _canSubtract(kind, value) ? () => _subtract(kind) : null,
                      onIncrease: _canAdd(kind, value) ? () => _add(kind) : null,
                    ),
                ],
              ),
            ),
          ),
          if (widget.quickBuildHtml != null) ...[
            const Gap(12),
            // Рекомендации класса свёрнуты, чтобы характеристики были видны сразу.
            SheetCard(
              child: Theme(
                data: context.theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const Icon(Icons.lightbulb_outline, color: Colors.white70),
                  title: const Text('Быстрое создание'),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  children: [HtmlContent(widget.quickBuildHtml!)],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _signed(int value) => value >= 0 ? '+$value' : '−${-value}';
}
