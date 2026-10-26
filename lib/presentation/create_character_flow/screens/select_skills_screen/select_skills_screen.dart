import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectSkillsScreen extends StatefulWidget {
  final int maxSkills;
  final List<Skill> availableSkills;
  final void Function(List<Skill> skills) onSkillsSelected;
  final String title;

  /// Пояснение под заголовком: откуда владение и что выбирать.
  final String? description;

  const SelectSkillsScreen({
    super.key,
    this.title = 'Навыки',
    this.description,
    required this.availableSkills,
    required this.maxSkills,
    required this.onSkillsSelected,
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
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.description != null) ...[
                const Gap(8),
                Text(widget.description!, textAlign: TextAlign.center),
              ],
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
                  children: widget.availableSkills
                      .sorted((a, b) => a.localizedName.compareTo(b.localizedName))
                      .map((e) {
                    final isSelected = _selectedSkills.contains(e);
                    return ListTile(
                      title: Text(e.localizedName),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSkills.remove(e);
                          } else if (_selectedSkills.length < widget.maxSkills) {
                            _selectedSkills.add(e);
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
                    ? () => widget.onSkillsSelected(_selectedSkills)
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
