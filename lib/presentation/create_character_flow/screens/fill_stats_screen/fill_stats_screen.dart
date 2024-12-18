import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/fill_stats_screen/widgets/enter_stat_widget.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class FillStatsScreen extends StatefulWidget {
  final Map<StatKind, int> initialStats;
  final int maxPoints;
  final bool isInitial;
  final Map<StatKind, int> Function()? onStatsFilled;

  const FillStatsScreen({
    super.key,
    this.isInitial = true,
    this.maxPoints = 27,
    this.initialStats = const {},
    this.onStatsFilled,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Очки: $points/${widget.maxPoints}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Expanded(
                child: GridView(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  children: stats.entries
                      .map(
                        (e) => EnterStatWidget(
                          statKind: e.key,
                          value: e.value,
                          canAdd: e.value < 15,
                          canSubtract: e.value > 8,
                          onAdd: () {
                            setState(() {
                              if (points > 0) {
                                points--;
                                if (e.value >= 13) {
                                  points--;
                                }
                                stats[e.key] = e.value + 1;
                              }
                            });
                          },
                          onSubtract: () {
                            setState(() {
                              if (points < 27) {
                                points++;
                                if (e.value > 13) {
                                  points++;
                                }
                                stats[e.key] = e.value - 1;
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: points == 0
                    ? () {
                        if (widget.onStatsFilled != null) {
                          widget.onStatsFilled!();
                        } else {
                          context.read<CreateCharacterCubit>().setStats(stats);
                          context.pushRoute(const SelectClassRoute());
                        }
                      }
                    : null,
                child: const Text('Далее'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
