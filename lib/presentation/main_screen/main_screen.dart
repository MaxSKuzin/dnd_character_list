import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/bard.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/player_skills_list.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/player_stats_list.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/proficiency_widget.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/save_throws_widget.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late var player = setPlayer();

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
            SizedBox(
              width: 24,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProficiencyWidget(),
                  SizedBox(
                    height: 16,
                  ),
                  SaveThrowsWidget(),
                  SizedBox(
                    height: 8,
                  ),
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

  Player setPlayer() {
    return Player(
      strength: 11,
      dexterity: 17,
      constitution: 15,
      intelligence: 10,
      wisdom: 13,
      charisma: 16,
      classes: [
        Bard(
          level: 1,
          isMain: true,
        ),
      ],
      chosenSkills: [
        Skill.acrobatics,
        Skill.fraud,
        Skill.harassment,
        Skill.conviction,
      ],
    );
  }
}
