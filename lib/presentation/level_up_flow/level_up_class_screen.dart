import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/presentation/common/widgets/class_image.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/fighter.dart';
import 'package:dnd_character_list/domain/models/classes/monk.dart';
import 'package:dnd_character_list/domain/models/classes/ranger.dart';
import 'package:dnd_character_list/domain/models/classes/sorcerer.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/level_up_flow/bard_level_up.dart';
import 'package:dnd_character_list/presentation/level_up_flow/fighter_level_up.dart';
import 'package:dnd_character_list/presentation/level_up_flow/monk_level_up.dart';
import 'package:dnd_character_list/presentation/level_up_flow/ranger_level_up.dart';
import 'package:dnd_character_list/presentation/level_up_flow/sorcerer_level_up.dart';

@RoutePage()
class LevelUpClassScreen extends StatefulWidget {
  const LevelUpClassScreen({super.key});

  @override
  State<LevelUpClassScreen> createState() => _LevelUpClassScreenState();
}

class _LevelUpClassScreenState extends State<LevelUpClassScreen> {
  ClassKind? _selectedClassKind;
  bool _isLoading = false;

  Future<void> _levelUp() async {
    final player = PlayerModel.getPlayer(context);
    final classKind = _selectedClassKind!;
    final selectedClass = player.classes.firstWhereOrNull((e) => e.classKind == classKind);
    final cubit = context.read<LevelUpCubit>();
    cubit.setClass(classKind, selectedClass?.isMain ?? false);

    final link = classKind.ttgLink;
    final bool passed;
    const ttgClasses = [ClassKind.bard, ClassKind.sorcerer, ClassKind.monk, ClassKind.warrior, ClassKind.ranger];
    if (ttgClasses.contains(classKind) && link != null) {
      final ClassInfo info;
      setState(() => _isLoading = true);
      try {
        info = await getIt<RulesRepository>().getClass(link);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось загрузить описание класса с ttg.club: $e')),
          );
        }
        return;
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      if (!mounted) return;
      passed = await switch (classKind) {
        ClassKind.bard => BardLevelUp(context: context, player: player, info: info, bard: selectedClass as Bard?).run(),
        ClassKind.monk => MonkLevelUp(context: context, player: player, info: info, monk: selectedClass as Monk?).run(),
        ClassKind.ranger =>
          RangerLevelUp(context: context, player: player, info: info, ranger: selectedClass as Ranger?).run(),
        ClassKind.warrior =>
          FighterLevelUp(context: context, player: player, info: info, fighter: selectedClass as Fighter?).run(),
        _ => SorcererLevelUp(context: context, player: player, info: info, sorcerer: selectedClass as Sorcerer?).run(),
      };
    } else {
      passed = await _levelUpLegacy(player, classKind, selectedClass);
    }

    cubit.setRaceSpells(player.race.spellForLevel(player.level + 1));
    if (passed) cubit.levelUp();
  }

  /// Классы, повышение уровня которых ещё не переведено на описание с ttg.club.
  Future<bool> _levelUpLegacy(Player player, ClassKind classKind, Specialization? selectedClass) async {
    final classes = player.classes;
    final stats = player.stats;
    final newLevel = (selectedClass?.level ?? 0) + 1;
    final knownSpellsCount = classKind.knownSpellsCount(
      newLevel,
      (StatKind statKind) => stats[statKind]!.bonus,
    );

    final knownConspiraciesCount = classKind.knownConspiracies(newLevel);
    final classKnownSpells = selectedClass?.knownSpells.where((e) => e.slot != SpellSlot.conspiracy).toList() ?? [];
    final classKnownConspiracies =
        selectedClass?.knownSpells.where((e) => e.slot == SpellSlot.conspiracy).toList() ?? [];

    final knownSpells = player.spells.values.expand((e) => e).toList();

    final conspiraciesDiff = max(0, knownConspiraciesCount - classKnownConspiracies.length);
    final spellsDiff = max(0, knownSpellsCount - classKnownSpells.length);

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

    final cubit = context.read<LevelUpCubit>();
    bool passed = true;

    if (newLevel != 1) {
      final doubledSkillPoints = classKind.getDoubledSkillPoints(newLevel);
      if (doubledSkillPoints > 0) {
        passed = await context.pushRoute(
              SelectSkillsRoute(
                title: 'Компетентность',
                description: 'Выберите навыки из тех, которыми владеете: бонус мастерства для них удваивается.',
                maxSkills: doubledSkillPoints,
                availableSkills: player.chosenSkills.toSet().toList(),
                onSkillsSelected: (skills) {
                  cubit.setSkills([...skills, ...player.rawChosenSkills]);
                  context.maybePop(true);
                },
              ),
            ) ??
            false;
      }
    } else {
      passed = await context.pushRoute(
            SelectSkillsRoute(
              title: 'Владение навыками',
              description: 'Класс «${classKind.localizedName}»: выберите навыки из списка класса.',
              maxSkills: classKind.startSkillCount,
              availableSkills: classKind.availableSkills.where((e) => !player.chosenSkills.contains(e)).toList(),
              onSkillsSelected: (skills) {
                cubit.setSkills([...skills, ...player.rawChosenSkills]);
                context.maybePop(true);
              },
            ),
          ) ??
          false;
    }
    if (!mounted) return false;

    final route = classKind.getClassSpecificRoute(context, newLevel);
    if (route != null) {
      passed = await context.pushRoute(route) ?? false;
    }
    if (!mounted) return false;

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
              knownSpells: knownSpells,
              onSpellsSelected: (spells) {
                cubit.setSpells([...classKnownSpells, ...classKnownConspiracies, ...spells]);
                context.maybePop(true);
              },
            ),
          ) ??
          false;
    } else {
      cubit.setSpells([...classKnownSpells, ...classKnownConspiracies]);
    }
    return passed;
  }

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
                        onTap: !e.canLevelUp
                            ? null
                            : () {
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
                            _selectedClassKind == e
                                ? Colors.transparent
                                : e.canLevelUp
                                    ? Colors.black45
                                    : Colors.black87,
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
                                            e.localizedName,
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
                                          if (!e.canLevelUp)
                                            const Text('Пока недоступен', style: TextStyle(color: Colors.white70)),
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
                onPressed: _selectedClassKind != null && !_isLoading ? _levelUp : null,
                child: _isLoading
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Далее'),
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
      case ClassKind.paladin:
        switch (level) {
          case 2:
            return SelectFightingStyleRoute(
              styles: FightingStyle.paladinStyles,
              onStyleSelected: (style) {
                context.read<LevelUpCubit>().setFightingStyle(style);
                context.maybePop(true);
              },
            );
          default:
            return null;
        }
      default:
        return null;
    }
  }
}
