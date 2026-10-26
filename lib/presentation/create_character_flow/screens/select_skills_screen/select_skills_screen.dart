import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';

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
    final skills = widget.availableSkills.sorted((a, b) => a.localizedName.compareTo(b.localizedName));
    final isComplete = _selectedSkills.length == widget.maxSkills;
    return StepScaffold(
      title: widget.title,
      description: widget.description,
      counter: '${_selectedSkills.length} из ${widget.maxSkills}',
      isCounterDone: isComplete,
      onAction: isComplete ? () => widget.onSkillsSelected(_selectedSkills) : null,
      body: ChoiceList(
        children: [
          for (final skill in skills)
            Builder(
              builder: (context) {
                final isSelected = _selectedSkills.contains(skill);
                return ChoiceCard(
                  title: skill.localizedName,
                  subtitle: skill.origin.localizedName,
                  isSelected: isSelected,
                  isMultiple: true,
                  // Когда набрано нужное число, остальные навыки гаснут.
                  onTap: isSelected || !isComplete
                      ? () => setState(() => isSelected ? _selectedSkills.remove(skill) : _selectedSkills.add(skill))
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
