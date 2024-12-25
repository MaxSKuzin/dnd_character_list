import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/presentation/common/widgets/class_image.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectClassScreen extends StatefulWidget {
  final Map<StatKind, int> stats;
  const SelectClassScreen({
    super.key,
    required this.stats,
  });

  @override
  State<SelectClassScreen> createState() => _SelectClassScreenState();
}

class _SelectClassScreenState extends State<SelectClassScreen> {
  ClassKind? _selectedClass;

  @override
  Widget build(BuildContext context) {
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
                  children: ClassKind.values
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
                    ? () {
                        final knownSpellsCount = _selectedClass!.knownSpellsCount(
                          1,
                          (StatKind statKind) => Stat(
                            value: widget.stats[statKind]!,
                            kind: statKind,
                          ).bonus,
                        );
                        context.read<CreateCharacterCubit>().setClass(_selectedClass!);
                        final knownSpells = context.read<CreateCharacterCubit>().race!.conspiracyForLevel(1);
                        if (_selectedClass!.knownConspiracies(1) > 0 || knownSpellsCount > 0) {
                          context.pushRoute(
                            SelectSpellsRoute(
                              classKind: _selectedClass!,
                              maxConspiracies: _selectedClass!.knownConspiracies(1),
                              maxSpells: knownSpellsCount,
                              knownSpells: knownSpells,
                            ),
                          );
                        } else {
                          context.read<CreateCharacterCubit>().setSpells([]);
                          context.pushRoute(
                            SelectBackgroundRoute(
                              onContinue: () {
                                context.pushRoute(
                                  SelectSkillsRoute(
                                    maxSkills: _selectedClass!.startSkillCount,
                                    availableSkills: _selectedClass!.availableSkills,
                                    classKind: _selectedClass!,
                                  ),
                                );
                              },
                            ),
                          );
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
