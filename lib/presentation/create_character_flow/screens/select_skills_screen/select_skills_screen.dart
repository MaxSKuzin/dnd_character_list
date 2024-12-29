import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectSkillsScreen extends StatefulWidget {
  final int maxSkills;
  final List<Skill> availableSkills;
  final ClassKind classKind;
  final void Function(List<Skill> skills)? onSkillsSelected;

  const SelectSkillsScreen({
    super.key,
    required this.classKind,
    required this.availableSkills,
    required this.maxSkills,
    this.onSkillsSelected,
  });

  @override
  State<SelectSkillsScreen> createState() => _SelectSkillsScreenState();
}

class _SelectSkillsScreenState extends State<SelectSkillsScreen> {
  final _selectedSkills = <Skill>[];

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
                'Навыки',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Text(
                'Выбрано навыков: ${_selectedSkills.length}/${widget.maxSkills}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Gap(16),
              Expanded(
                child: ListView(
                  children: widget.availableSkills.sorted((a, b) => a.name.compareTo(b.name)).map((e) {
                    final isSelected = _selectedSkills.contains(e);
                    return ListTile(
                      title: Text(e.name),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSkills.remove(e);
                          } else {
                            if (_selectedSkills.length < widget.maxSkills) {
                              _selectedSkills.add(e);
                            }
                          }
                        });
                      },
                      selected: isSelected,
                    );
                  }).toList(),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selectedSkills.length == widget.maxSkills
                    ? () {
                        if (widget.onSkillsSelected == null) {
                          context.read<CreateCharacterCubit>().setSkills(_selectedSkills);
                          context.router.push(
                            SelectWeaponsRoute(
                              startEquip: widget.classKind.equipment,
                            ),
                          );
                        } else {
                          widget.onSkillsSelected!(_selectedSkills);
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
