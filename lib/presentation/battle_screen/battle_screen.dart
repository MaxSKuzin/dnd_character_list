import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/health_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/initiative_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/protection_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/speed_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
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
                final dimension = constraints.maxWidth / 3 - 32;
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
            const HealthSection(),
            const Expanded(
              child: SingleChildScrollView(
                child: Column(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
