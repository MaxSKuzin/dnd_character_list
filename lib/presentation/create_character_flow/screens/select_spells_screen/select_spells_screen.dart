import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/conspiracies/conspiracies.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level1/spells_level_1.dart';
import 'package:dnd_character_list/domain/models/spell/spells_entities/level2/spells_level_w.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_info_dialog.dart';
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
  final List<SpellSlot> availableSlots;

  const SelectSpellsScreen({
    super.key,
    this.knownSpells = const [],
    List<SpellSlot>? availableSlots,
    this.onSpellsSelected,
    required this.maxSpells,
    required this.maxConspiracies,
    required this.classKind,
  }) : availableSlots = availableSlots ?? const [SpellSlot.conspiracy, SpellSlot.level1];

  @override
  State<SelectSpellsScreen> createState() => _SelectSpellsScreenState();
}

class _SelectSpellsScreenState extends State<SelectSpellsScreen> {
  final _selectedConspiracies = <Spell>[];
  final _selectedSpells = <Spell>[];
  SpellSlot? _selectedSpellSlot;

  late final _availableSpells = widget.availableSlots
      .map((e) => switch (e) {
            SpellSlot.conspiracy => conspiracies,
            SpellSlot.level1 => spellsLevel1,
            SpellSlot.level2 => spellsLevel2,
            SpellSlot.level3 => [],
            SpellSlot.level4 => throw UnimplementedError(),
            SpellSlot.level5 => throw UnimplementedError(),
            SpellSlot.level6 => throw UnimplementedError(),
            SpellSlot.level7 => throw UnimplementedError(),
            SpellSlot.level8 => throw UnimplementedError(),
            SpellSlot.level9 => throw UnimplementedError(),
          })
      .expand((e) => e)
      .where(
        (e) => e.allowedSpecializations.contains(widget.classKind) && !widget.knownSpells.contains(e),
      )
      .sorted((a, b) => a.slot.compareTo(b.slot))
      .toList();

  @override
  Widget build(BuildContext context) {
    final availableSpells = _availableSpells
        .where(
          (e) => _selectedSpellSlot == null || e.slot == _selectedSpellSlot,
        )
        .toList();
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
              if (widget.maxConspiracies > 0)
                Text(
                  'Заговоры: ${_selectedConspiracies.length}/${widget.maxConspiracies}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              if (widget.maxSpells > 0)
                Text(
                  'Заклинания: ${_selectedSpells.length}/${widget.maxSpells}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              const Gap(16),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: widget.availableSlots
                      .map(
                        (e) => GestureDetector(
                          onTap: () => setState(() {
                            if (e != _selectedSpellSlot) {
                              _selectedSpellSlot = e;
                            } else {
                              _selectedSpellSlot = null;
                            }
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Chip(
                              label: Text(
                                e.name,
                                style: TextStyle(
                                  color: _selectedSpellSlot == e ? context.theme.scaffoldBackgroundColor : null,
                                ),
                              ),
                              color: WidgetStatePropertyAll(
                                _selectedSpellSlot == e ? Colors.white : null,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Gap(16),
              Expanded(
                child: ListView(
                  children: availableSpells
                      .map(
                        (e) => Stack(
                          children: [
                            SpellWidget(
                              onTap: () {
                                if (e.slot != SpellSlot.conspiracy) {
                                  if (_selectedSpells.contains(e)) {
                                    _selectedSpells.remove(e);
                                  } else if (_selectedSpells.length < widget.maxSpells) {
                                    _selectedSpells.add(e);
                                  }
                                } else {
                                  if (_selectedConspiracies.contains(e)) {
                                    _selectedConspiracies.remove(e);
                                  } else if (_selectedConspiracies.length < widget.maxConspiracies) {
                                    _selectedConspiracies.add(e);
                                  }
                                }
                                setState(() {});
                              },
                              backgroundColor: _selectedSpells.contains(e) || _selectedConspiracies.contains(e)
                                  ? null
                                  : Colors.transparent,
                              spell: e,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                onPressed: () => SpellInfoDialog.show(
                                  context,
                                  canDrainMana: false,
                                  spell: e,
                                  spellDescription: e.rawDescription,
                                ),
                                icon: const Icon(Icons.info),
                              ),
                            ),
                          ],
                        ),
                      )
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
                              context.read<CreateCharacterCubit>().setSpells([
                                ...widget.knownSpells,
                                ..._selectedSpells,
                                ..._selectedConspiracies,
                              ]);
                              context.pushRoute(
                                SelectBackgroundRoute(
                                  onContinue: () {
                                    context.pushRoute(
                                      SelectSkillsRoute(
                                        isInitial: true,
                                        maxSkills: widget.classKind.startSkillCount,
                                        availableSkills: widget.classKind.availableSkills,
                                        classKind: widget.classKind,
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
