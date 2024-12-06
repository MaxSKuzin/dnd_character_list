import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/health_buttons.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/health_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/hit_dices.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/initiative_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/mana_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/protection_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/speed_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/spells_stats_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapons_section.dart';
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
  final _scrollController = ScrollController();

  @override
  void dispose() {
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
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              shrinkWrap: true,
              children: const [
                HealthSection(),
                HealthButtons(),
                ManaSection(),
                HitDices(),
              ],
            ),
            const Gap(16),
            Expanded(
              child: FadingEdgeScrollView.fromSingleChildScrollView(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ОРУЖИЕ',
                        textAlign: TextAlign.center,
                      ),
                      Gap(8),
                      WeaponsSection(),
                      Gap(16),
                      Text(
                        'МАГИЯ',
                        textAlign: TextAlign.center,
                      ),
                      Gap(8),
                      SpellsStatsSection(),
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
