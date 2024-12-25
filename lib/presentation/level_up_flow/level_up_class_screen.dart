import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
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
  ClassKind? _selectedClassKind;

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
                  children: ClassKind.values.sorted((a, b) {
                    final firstClass = classes.firstWhereOrNull((el) => a == el.classKind);
                    final secondClass = classes.firstWhereOrNull((el) => b == el.classKind);
                    if (firstClass != null) {
                      if (secondClass != null) {
                        return secondClass.level.compareTo(firstClass.level);
                      } else {
                        return -1;
                      }
                    } else {
                      if (secondClass != null) {
                        return 1;
                      } else {
                        return 0;
                      }
                    }
                  }).map(
                    (e) {
                      final selectedClass = classes.firstWhereOrNull((el) => e == el.classKind);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedClassKind == e) {
                              _selectedClassKind = null;
                            } else {
                              _selectedClassKind = e;
                            }
                          });
                        },
                        child: ImageFiltered(
                          imageFilter: ColorFilter.mode(
                            _selectedClassKind == e ? Colors.transparent : Colors.black45,
                            BlendMode.srcATop,
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClassImage(classType: e),
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
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            e.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          if (selectedClass != null)
                                            Text(
                                              'Уровень ${selectedClass.level}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
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
                      );
                    },
                  ).toList(),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selectedClassKind != null
                    ? () async {
                        final selectedClass = classes.firstWhereOrNull((e) => e.classKind == _selectedClassKind!);
                        final player = PlayerModel.getPlayer(context);
                        final stats = player.stats;
                        final classKind = _selectedClassKind!;
                        final newLevel = (selectedClass?.level ?? 0) + 1;
                        final knownSpellsCount = classKind.knownSpellsCount(
                          newLevel,
                          (StatKind statKind) => stats[statKind]!.bonus,
                        );

                        final knownConspiraciesCount = classKind.knownConspiracies(newLevel);
                        final knownSpells =
                            player.spells.values.expand((e) => e).where((e) => e.slot != SpellSlot.conspiracy).toList();
                        final knownConspiracies =
                            player.spells.values.expand((e) => e).where((e) => e.slot == SpellSlot.conspiracy).toList();

                        final conspiraciesDiff = max(0, knownConspiraciesCount - knownConspiracies.length);
                        final spellsDiff = max(0, knownSpellsCount - knownSpells.length);

                        final availableSlots = SpellSlot.getSpellCells(
                          Map.fromEntries(
                            [
                              ...classes.map(
                                (e) => MapEntry(e.classKind, classKind == e.classKind ? e.level + 1 : e.level),
                              ),
                              if (selectedClass == null) MapEntry(classKind, 1),
                            ],
                          ),
                        );

                        context.read<LevelUpCubit>().setClass(classKind, selectedClass?.isMain ?? false);

                        bool passed = true;

                        if (newLevel != 1) {
                          final doubledSkillPoins = classKind.getDoubledSkillPoints(newLevel);
                          if (doubledSkillPoins > 0) {
                            passed = await context.pushRoute(
                                  SelectSkillsRoute(
                                    classKind: classKind,
                                    maxSkills: doubledSkillPoins,
                                    availableSkills: player.chosenSkills.toSet().toList(),
                                    onSkillsSelected: (skills) {
                                      context.read<LevelUpCubit>().setSkills([...skills, ...player.chosenSkills]);
                                      context.maybePop(true);
                                    },
                                  ),
                                ) ??
                                false;
                          }
                        } else {
                          passed = await context.pushRoute(
                                SelectSkillsRoute(
                                  maxSkills: classKind.startSkillCount,
                                  availableSkills: classKind.availableSkills,
                                  classKind: classKind,
                                  onSkillsSelected: (skills) {
                                    context.read<LevelUpCubit>().setSkills([...skills, ...player.chosenSkills]);
                                    context.maybePop(true);
                                  },
                                ),
                              ) ??
                              false;
                        }

                        final statsBonus = classKind.getStatsBonus(newLevel);
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

                        final route = classKind.getClassSpecificRoute(context, newLevel);
                        if (route != null) {
                          passed = await context.pushRoute(route) ?? false;
                        }

                        final raceSpells = player.race.conspiracyForLevel(player.level + 1);

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
