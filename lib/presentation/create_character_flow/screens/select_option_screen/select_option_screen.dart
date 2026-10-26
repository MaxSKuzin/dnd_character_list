import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (widget.description != null) ...[
                const Gap(8),
                Text(widget.description!, textAlign: TextAlign.center),
              ],
              const Gap(16),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.options.length,
                  separatorBuilder: (_, __) => const Gap(8),
                  itemBuilder: (context, index) {
                    final option = widget.options[index];
                    final isSelected = index == _selected;
                    return Card(
                      color: isSelected ? context.customColors?.cardColor : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isSelected ? Colors.white : Colors.white24),
                      ),
                      child: ListTile(
                        title: Text(option.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: option.subtitle == null ? null : Text(option.subtitle!),
                        onTap: () => setState(() => _selected = isSelected ? null : index),
                        trailing: option.detailsHtml == null
                            ? null
                            : IconButton(
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) => HtmlDialog(title: option.title, html: option.detailsHtml!),
                                ),
                                icon: const Icon(Icons.info),
                              ),
                      ),
                    );
                  },
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selected != null && !_isSaving ? () => _onContinue(_selected!) : null,
                child: _isSaving
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
