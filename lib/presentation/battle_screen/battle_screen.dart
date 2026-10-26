import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/class_extra_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/death_throws_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/health_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/hit_dices.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/initiative_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/long_rest_button.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/protection_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/speed_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/spell_slots_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/spells_stats_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapons_section.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/session/session_button.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final _gridController = ScrollController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Future.delayed(
    //   const Duration(milliseconds: 500),
    //   () {
    //     if (_gridController.position.maxScrollExtent == 0) return;
    //     _gridController
    //         .animateTo(
    //           _gridController.position.maxScrollExtent,
    //           duration: const Duration(seconds: 2),
    //           curve: Curves.elasticOut,
    //         )
    //         .then(
    //           (_) => _gridController.animateTo(
    //             0,
    //             duration: const Duration(milliseconds: 300),
    //             curve: Curves.linear,
    //           ),
    //         );
    //   },
    // );
  }

  @override
  void dispose() {
    _gridController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SessionButton(),
            const LongRestButton(),
            LayoutBuilder(
              builder: (context, constraints) {
                final dimension = constraints.maxWidth / 3 - 24;
                return SizedBox(
                  height: dimension,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const InitiativeWidget(),
                      const ProtectionWidget(),
                      const SpeedWidget(),
                    ]
                        .map(
                          (e) => SizedBox(
                            width: dimension,
                            child: e,
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            const Gap(16),
            LayoutBuilder(
              builder: (context, constraints) {
                final extras = PlayerModel.extras(context);
                return SizedBox(
                  height: constraints.maxWidth / 2 + 10,
                  width: constraints.maxWidth,
                  child: GridView(
                    controller: _gridController,
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    shrinkWrap: true,
                    children: [
                      const HealthSection(),
                      const HitDices(),
                      const DeathThrowsWidget(),
                      ...extras.entries.map(
                        (e) => ClassExtraWidget(
                          extra: e.key,
                          count: e.value,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Gap(16),
            Expanded(
              child: FadingEdgeScrollView.fromSingleChildScrollView(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Без ячеек секция пустая и не занимает места.
                      const SpellSlotsSection(),
                      const Text(
                        'ОРУЖИЕ',
                        textAlign: TextAlign.center,
                      ),
                      const Gap(8),
                      const WeaponsSection(),
                      Builder(
                        builder: (context) {
                          final spellStats = PlayerModel.spellStats(context);
                          if (spellStats.isEmpty) {
                            return const SizedBox();
                          }
                          return Column(
                            children: [
                              const Gap(16),
                              const Text(
                                'МАГИЯ',
                                textAlign: TextAlign.center,
                              ),
                              const Gap(8),
                              SpellsStatsSection(spellStats),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
