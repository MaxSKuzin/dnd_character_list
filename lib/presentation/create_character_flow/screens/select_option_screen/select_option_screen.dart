import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:flutter/material.dart';

/// Вариант выбора с подписью, например «Красный» — «Огонь».
class SelectOption {
  final String title;
  final String? subtitle;

  /// Описание варианта в html (например, текст умения с сайта): открывается кнопкой «i».
  final String? detailsHtml;

  const SelectOption({required this.title, this.subtitle, this.detailsHtml});
}

/// Выбор одного варианта из списка: драконьего предка, склонности «Божественной души» и т.п.
@RoutePage()
class SelectOptionScreen extends StatefulWidget {
  final String title;
  final String? description;
  final List<SelectOption> options;

  /// Получает номер выбранного варианта в [options].
  /// Может быть асинхронным: пока он выполняется, кнопка показывает загрузку.
  final FutureOr<void> Function(int index) onSelected;

  const SelectOptionScreen({
    super.key,
    required this.title,
    this.description,
    required this.options,
    required this.onSelected,
  });

  @override
  State<SelectOptionScreen> createState() => _SelectOptionScreenState();
}

class _SelectOptionScreenState extends State<SelectOptionScreen> {
  int? _selected;
  bool _isSaving = false;

  Future<void> _onContinue(int index) async {
    setState(() => _isSaving = true);
    try {
      await widget.onSelected(index);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      title: widget.title,
      description: widget.description,
      isBusy: _isSaving,
      onAction: _selected != null ? () => _onContinue(_selected!) : null,
      body: ChoiceList(
        children: [
          for (final (index, option) in widget.options.indexed)
            ChoiceCard(
              title: option.title,
              subtitle: option.subtitle,
              isSelected: index == _selected,
              onTap: () => setState(() => _selected = index == _selected ? null : index),
              onInfo: option.detailsHtml == null
                  ? null
                  : () => showDialog(
                        context: context,
                        builder: (_) => HtmlDialog(title: option.title, html: option.detailsHtml!),
                      ),
            ),
        ],
      ),
    );
  }
}
