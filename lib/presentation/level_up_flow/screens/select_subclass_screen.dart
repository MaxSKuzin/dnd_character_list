import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:flutter/material.dart';

/// Выбор подкласса (коллегии бардов, происхождения чародея) из описания класса на ttg.club.
@RoutePage()
class SelectSubclassScreen extends StatefulWidget {
  final String title;
  final String? description;
  final List<Subclass> subclasses;

  /// Может быть асинхронным: пока он выполняется, кнопка показывает загрузку.
  final FutureOr<void> Function(Subclass subclass) onSelected;

  const SelectSubclassScreen({
    super.key,
    required this.title,
    this.description,
    required this.subclasses,
    required this.onSelected,
  });

  @override
  State<SelectSubclassScreen> createState() => _SelectSubclassScreenState();
}

class _SelectSubclassScreenState extends State<SelectSubclassScreen> {
  Subclass? _selected;
  bool _isSaving = false;

  Future<void> _onContinue(Subclass subclass) async {
    setState(() => _isSaving = true);
    try {
      await widget.onSelected(subclass);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Описание и все умения подкласса одной страницей, как на сайте.
  static String _fullHtml(Subclass subclass) => [
        if (subclass.source != null) '<p><strong>Источник: «${subclass.source}»</strong></p>',
        subclass.descriptionHtml,
        for (final feature in subclass.features)
          '<h3>${feature.name}</h3><p><em>${feature.level}-й уровень</em></p>${feature.descriptionHtml}',
      ].join('\n');

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      title: widget.title,
      description: widget.description,
      isBusy: _isSaving,
      onAction: _selected != null ? () => _onContinue(_selected!) : null,
      body: ChoiceList(
        children: [
          for (final subclass in widget.subclasses)
            ChoiceCard(
              title: subclass.name,
              subtitle: [
                if (subclass.source != null) subclass.source!,
                subclass.features.map((e) => e.name).toSet().join(', '),
              ].join('\n'),
              isSelected: subclass.id == _selected?.id,
              onTap: () => setState(() => _selected = subclass.id == _selected?.id ? null : subclass),
              onInfo: () => showDialog(
                context: context,
                builder: (_) => HtmlDialog(title: subclass.name, html: _fullHtml(subclass)),
              ),
            ),
        ],
      ),
    );
  }
}
