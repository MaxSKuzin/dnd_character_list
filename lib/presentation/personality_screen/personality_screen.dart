import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/presentation/common/widgets/class_image.dart';
import 'package:dnd_character_list/presentation/common/widgets/labeled_border.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/personality_screen/widgets/peculiarity_widget.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class PersonalityScreen extends StatefulWidget {
  const PersonalityScreen({super.key});

  @override
  State<PersonalityScreen> createState() => _PersonalityScreenState();
}

class _PersonalityScreenState extends State<PersonalityScreen> {
  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.getPlayer(context);
    final languages = player.knownLanguages;
    final abilities = player.abilities;
    final personality = player.personality;
    final classes = PlayerModel.classes(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () => context.pushRoute(LevelUpFlowRoute(
                  player: PlayerModel.getPlayer(context),
                )),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward),
                    Text('Новый уровень'),
                  ],
                ),
              ),
              const Gap(16),
              LabeledBorder(
                backgroundColor: context.customColors?.cardColor,
                text: personality.name.toUpperCase(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text('Возраст: ${personality.age}'),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text('Рост: ${personality.height}'),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text('Вес: ${personality.weight}'),
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'Цвет глаз: ${personality.eyesColor}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Цвет кожи: ${personality.skinColor}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Цвет волос: ${personality.hairColor}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LabeledBorder(
                backgroundColor: context.customColors?.cardColor,
                text: 'КЛАССЫ',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: GridView(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    shrinkWrap: true,
                    children: classes
                        .map(
                          (e) => Center(
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClassImage(
                                    classType: e.classKind,
                                  ),
                                ),
                                Text('${e.name} (${e.level})'),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (abilities.isNotEmpty) ...[
                LabeledBorder(
                  backgroundColor: context.customColors?.cardColor,
                  text: 'ОСОБЕННОСТИ',
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: abilities
                          .map(
                            (e) => PeculiarityWidget(classAbility: e),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const Gap(16),
              ],
              LabeledBorder(
                backgroundColor: context.customColors?.cardColor,
                text: 'ЯЗЫКИ',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: languages
                        .map(
                          (e) => Text(
                            e.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const Gap(16),
              LabeledBorder(
                backgroundColor: context.customColors?.cardColor,
                text: 'ПРЕДЫСТОРИЯ',
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(personality.story),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
