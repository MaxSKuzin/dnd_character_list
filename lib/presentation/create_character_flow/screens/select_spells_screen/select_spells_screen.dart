import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/conspiracies/conspiracies.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/spells_level_1.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_widget.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectSpellsScreen extends StatefulWidget {
  final ClassKind classKind;
  final int maxConspiracies;
  final int maxSpells;
  final List<Spell> knownSpells;
  final Function(List<Spell> spells)? onSpellsSelected;

  const SelectSpellsScreen({
    super.key,
    this.knownSpells = const [],
    this.onSpellsSelected,
    required this.maxSpells,
    required this.maxConspiracies,
    required this.classKind,
  });

  @override
  State<SelectSpellsScreen> createState() => _SelectSpellsScreenState();
}

class _SelectSpellsScreenState extends State<SelectSpellsScreen> {
  final _selectedConspiracies = <Spell>[];
  final _selectedSpells = <Spell>[];

  late final _availableSpells = spellsLevel1
      .where(
        (e) => e.allowedSpecializations.contains(widget.classKind) && !widget.knownSpells.contains(e),
      )
      .toList();

  late final availableConspiracies = conspiracies
      .where(
        (e) => e.allowedSpecializations.contains(widget.classKind) && !widget.knownSpells.contains(e),
      )
      .toList();

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
                'Заклинания',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Text(
                'Заговоры: ${_selectedConspiracies.length}/${widget.maxConspiracies}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                'Заклинания: ${_selectedSpells.length}/${widget.maxSpells}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Gap(16),
              Expanded(
                child: ListView(
                  children: [
                    ...availableConspiracies.map(
                      (e) => SpellWidget(
                        onTap: () {
                          if (_selectedConspiracies.contains(e)) {
                            _selectedConspiracies.remove(e);
                          } else if (_selectedConspiracies.length < widget.maxConspiracies) {
                            _selectedConspiracies.add(e);
                          }
                          setState(() {});
                        },
                        backgroundColor: _selectedConspiracies.contains(e) ? null : Colors.transparent,
                        spell: e,
                      ),
                    ),
                    ..._availableSpells.map(
                      (e) => SpellWidget(
                        onTap: () {
                          if (_selectedSpells.contains(e)) {
                            _selectedSpells.remove(e);
                          } else if (_selectedSpells.length < widget.maxSpells) {
                            _selectedSpells.add(e);
                          }
                          setState(() {});
                        },
                        backgroundColor: _selectedSpells.contains(e) ? null : Colors.transparent,
                        spell: e,
                      ),
                    ),
                  ]
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          child: e,
                        ),
                      )
                      .toList(),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed:
                    _selectedSpells.length == widget.maxSpells && _selectedConspiracies.length == widget.maxConspiracies
                        ? () {
                            if (widget.onSpellsSelected != null) {
                              widget.onSpellsSelected!([..._selectedSpells, ..._selectedConspiracies]);
                            } else {
                              context
                                  .read<CreateCharacterCubit>()
                                  .setSpells([..._selectedSpells, ..._selectedConspiracies]);
                              context.pushRoute(
                                SelectSkillsRoute(
                                  maxSkills: widget.classKind.startSkillCount,
                                  availableSkills: widget.classKind.availableSkills,
                                  classKind: widget.classKind,
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
