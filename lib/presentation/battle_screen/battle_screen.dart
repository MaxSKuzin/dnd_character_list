import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/health_section.dart';
import 'package:flutter/material.dart';

@RoutePage()
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HealthSection(),
          ],
        ),
      ),
    );
  }
}
