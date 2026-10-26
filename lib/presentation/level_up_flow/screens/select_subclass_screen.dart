import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
                  itemCount: widget.subclasses.length,
                  separatorBuilder: (_, __) => const Gap(8),
                  itemBuilder: (context, index) {
                    final subclass = widget.subclasses[index];
                    final isSelected = subclass.id == _selected?.id;
                    return Card(
                      color: isSelected ? context.customColors?.cardColor : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isSelected ? Colors.white : Colors.white24),
                      ),
                      child: ListTile(
                        title: Text(subclass.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(
                          [
                            if (subclass.source != null) subclass.source!,
                            subclass.features.map((e) => e.name).toSet().join(', '),
                          ].join('\n'),
                        ),
                        onTap: () => setState(() => _selected = isSelected ? null : subclass),
                        trailing: IconButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => HtmlDialog(title: subclass.name, html: _fullHtml(subclass)),
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
