import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/presentation/common/widgets/class_image.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class LevelUpClassScreen extends StatefulWidget {
  const LevelUpClassScreen({super.key});

  @override
  State<LevelUpClassScreen> createState() => _LevelUpClassScreenState();
}

class _LevelUpClassScreenState extends State<LevelUpClassScreen> {
  Specialization? _selectedClass;

  @override
  Widget build(BuildContext context) {
    final classes = PlayerModel.classes(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Класс',
                textAlign: TextAlign.center,
                style: TextStyle(
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
                  children: classes
                      .map(
                        (e) => GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedClass == e) {
                                _selectedClass = null;
                              } else {
                                _selectedClass = e;
                              }
                            });
                          },
                          child: ImageFiltered(
                            imageFilter: ColorFilter.mode(
                              _selectedClass == e ? Colors.transparent : Colors.black45,
                              BlendMode.srcATop,
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClassImage(classType: e.classKind),
                                ),
                                DecoratedBox(
                                  decoration: const ShapeDecoration(
                                    shape: CircleBorder(
                                      side: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          e.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selectedClass != null
                    ? () async {
                        final player = PlayerModel.getPlayer(context);
                        final stats = player.stats;
                        final classKind = _selectedClass!.classKind;
                        final knownSpellsCount = _selectedClass!.classKind.knownSpellsCount(
                          _selectedClass!.level + 1,
                          (StatKind statKind) => stats[statKind]!.bonus,
                        );

                        final knownConspiraciesCount = classKind.knownConspiracies(_selectedClass!.level + 1);
                        final knownSpells =
                            _selectedClass!.knownSpells.where((e) => e.slot != SpellSlot.conspiracy).toList();
                        final knownConspiracies =
                            _selectedClass!.knownSpells.where((e) => e.slot == SpellSlot.conspiracy).toList();

                        final conspiraciesDiff = max(0, knownConspiraciesCount - knownConspiracies.length);
                        final spellsDiff = max(0, knownSpellsCount - knownSpells.length);

                        final availableSlots = SpellSlot.getSpellCells(
                          classes
                              .map(
                                (e) => (
                                  kind: e.classKind,
                                  level: _selectedClass!.classKind == e.classKind ? e.level + 1 : e.level
                                ),
                              )
                              .toList(),
                        );

                        context.read<LevelUpCubit>().setClass(classKind, _selectedClass!.isMain);

                        final doubledSkillPoins = classKind.getDoubledSkillPoints(_selectedClass!.level + 1);

                        bool passed = true;

                        if (doubledSkillPoins > 0) {
                          passed = await context.pushRoute(
                                SelectSkillsRoute(
                                  classKind: classKind,
                                  maxSkills: doubledSkillPoins,
                                  availableSkills: player.chosenSkills,
                                  onSkillsSelected: (skills) {
                                    context.read<LevelUpCubit>().setSkills([...skills, ...player.chosenSkills]);
                                    context.maybePop(true);
                                  },
                                ),
                              ) ??
                              false;
                        }

                        final statsBonus = classKind.getStatsBonus(_selectedClass!.level + 1);
                        if (statsBonus > 0) {
                          passed = await context.pushRoute(
                                FillStatsRoute(
                                  maxPoints: statsBonus,
                                  initialStats: player.stats.map((key, value) => MapEntry(key, value.value)),
                                  isInitial: false,
                                  onStatsFilled: (stats) {
                                    context.read<LevelUpCubit>().setStatsBonus(stats);
                                    context.maybePop(true);
                                  },
                                ),
                              ) ??
                              false;
                        }

                        final route = classKind.getClassSpecificRoute(context, _selectedClass!.level + 1);
                        if (route != null) {
                          passed = await context.pushRoute(route) ?? false;
                        }

                        final raceSpells = player.race
                            .conspiracyForLevel(player.level + 1);

                        if (conspiraciesDiff > 0 || spellsDiff > 0) {
                          passed = await context.pushRoute(
                                SelectSpellsRoute(
                                  classKind: classKind,
                                  maxConspiracies: conspiraciesDiff,
                                  maxSpells: spellsDiff,
                                  availableSlots: [
                                    if (conspiraciesDiff > 0) SpellSlot.conspiracy,
                                    ...availableSlots.keys,
                                  ],
                                  knownSpells: [
                                    ...raceSpells,
                                    ...knownSpells,
                                    ...knownConspiracies,
                                  ],
                                  onSpellsSelected: (spells) {
                                    context.read<LevelUpCubit>().setSpells(
                                      [...knownSpells, ...knownConspiracies, ...spells],
                                    );
                                    context.maybePop(true);
                                  },
                                ),
                              ) ??
                              false;
                        } else {
                          context.read<LevelUpCubit>().setSpells(
                            [
                              ...knownSpells,
                              ...knownConspiracies,
                              ...raceSpells,
                            ],
                          );
                        }
                        if (passed) {
                          context.read<LevelUpCubit>().levelUp();
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

extension on ClassKind {
  PageRouteInfo<dynamic>? getClassSpecificRoute(BuildContext context, int level) {
    switch (this) {
      case ClassKind.bard:
        switch (level) {
          case 3:
            return SelectCollegiumRoute(onCollegiumSelected: (collegium) {
              context.read<LevelUpCubit>().setCollegium(collegium);
              context.maybePop(true);
            });
          default:
            return null;
        }
      default:
        return null;
    }
  }
}
