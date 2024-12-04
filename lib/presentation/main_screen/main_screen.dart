import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/bard.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/common/widgets/separated_column.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/passive_wisdom_widget.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/save_throws_widget.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/skill_widget.dart';
import 'package:dnd_character_list/presentation/main_screen/widgets/stat_widget.dart';
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
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            label: 'Статы',
            icon: Icon(Icons.format_list_numbered),
          ),
          BottomNavigationBarItem(
            label: 'Перс',
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: SeparatedColumn(
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 16,
                      ),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...[
                          player.strength,
                          player.dexterity,
                          player.constitution,
                          player.intelligence,
                          player.wisdom,
                          player.charisma,
                        ].map((e) => StatWidget(stat: e)),
                        PassiveWisdomWidget(value: 10 + player.wisdom.bonus),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 24,
              ),
              Expanded(
                child: Column(
                  children: [
                    LabeledBorder(
                      backgroundColor: context.customColors?.cardColor,
                      text: 'СПАСБРОСКИ',
                      child: SaveThrowsWidget(
                        saves: player.saveThrows,
                        player: player,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: LabeledBorder(
                        backgroundColor: context.customColors?.cardColor,
                        text: 'НАВЫКИ',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 16,
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                for (final skill in player.skills)
                                  SkillWidget(
                                    key: Key(skill.name),
                                    title: '${skill.name} (${skill.origin.name.substring(0, 3)})',
                                    isChosen: skill.isChosen,
                                    bonus: skill.getBonus(player),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      skills: [
        Skill(
          origin: StatKind.dexterity,
          name: 'Акробатика',
          isChosen: true,
        ),
        Skill(
          origin: StatKind.strength,
          name: 'Атлетика',
        ),
        Skill(
          origin: StatKind.intelligence,
          name: 'Магия',
        ),
        Skill(
          origin: StatKind.charisma,
          name: 'Обман',
          isChosen: true,
        ),
        Skill(
          origin: StatKind.intelligence,
          name: 'История',
        ),
        Skill(
          origin: StatKind.wisdom,
          name: 'Проницательность',
        ),
        Skill(
          origin: StatKind.charisma,
          name: 'Запугивание',
          isChosen: true,
        ),
        Skill(
          origin: StatKind.intelligence,
          name: 'Анализ',
        ),
        Skill(
          origin: StatKind.wisdom,
          name: 'Медицина',
        ),
        Skill(
          origin: StatKind.wisdom,
          name: 'Природа',
        ),
        Skill(
          origin: StatKind.wisdom,
          name: 'Восприятие',
        ),
        Skill(
          origin: StatKind.charisma,
          name: 'Выступление',
        ),
        Skill(
          origin: StatKind.charisma,
          name: 'Убеждение',
          isChosen: true,
        ),
        Skill(
          origin: StatKind.intelligence,
          name: 'Религия',
        ),
        Skill(
          origin: StatKind.dexterity,
          name: 'Ловкость рук',
        ),
        Skill(
          origin: StatKind.dexterity,
          name: 'Скрытность',
        ),
        Skill(
          origin: StatKind.wisdom,
          name: 'Выживание',
        ),
        Skill(
          origin: StatKind.wisdom,
          name: 'Обращение с животными',
        ),
      ],
    );
  }
}
