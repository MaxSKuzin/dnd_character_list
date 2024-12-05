import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/player_skills_list.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/player_stats_list.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/proficiency_widget.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/save_throws_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: PlayerStatsList(),
            ),
            Gap(24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProficiencyWidget(),
                  Gap(16),
                  SaveThrowsWidget(),
                  Gap(8),
                  Expanded(
                    child: PlayerSkillsList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
