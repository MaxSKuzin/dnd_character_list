import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/models/class_option.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/loading_error.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Выбор особенностей класса из официальных книг ttg.club: вариантов метамагии чародея или приёмов мастера
/// боевых искусств.
@RoutePage()
class SelectClassOptionsScreen extends StatefulWidget {
  final ClassOptionKind kind;

  /// Заголовок; по умолчанию — название вида особенностей.
  final String? title;
  final String? description;

  /// Сколько вариантов нужно выбрать.
  final int count;

  /// Уже известные варианты: их нельзя выбрать снова.
  final List<ClassOption> known;

  /// Уровень класса: варианты с более высоким требованием ([ClassOption.level]) не показываются.
  final int? maxLevel;

  final void Function(List<ClassOption> options) onSelected;

  const SelectClassOptionsScreen({
    super.key,
    required this.kind,
    this.title,
    this.description,
    required this.count,
    this.known = const [],
    this.maxLevel,
    required this.onSelected,
  });

  @override
  State<SelectClassOptionsScreen> createState() => _SelectClassOptionsScreenState();
}

class _SelectClassOptionsScreenState extends State<SelectClassOptionsScreen> {
  final _repository = getIt<RulesRepository>();
  late Future<List<ClassOption>> _options = _repository.getOptions(widget.kind);
  final _selected = <ClassOption>[];

  void _toggle(ClassOption option) => setState(() {
        if (_selected.contains(option)) {
          _selected.remove(option);
        } else if (_selected.length < widget.count) {
          _selected.add(option);
        }
      });

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
                widget.title ?? widget.kind.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Gap(8),
              Text(
                [
                  if (widget.description != null) widget.description!,
                  'Выбрано: ${_selected.length} из ${widget.count}',
                ].join('\n'),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              Expanded(
                child: FutureBuilder(
                  future: _options,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return LoadingError(
                        message: 'Не удалось загрузить «${widget.kind.title}» с ttg.club.',
                        error: snapshot.error!,
                        onRetry: () => setState(() => _options = _repository.getOptions(widget.kind)),
                      );
                    }
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final options = snapshot.data!
                        .where((e) => !widget.known.contains(e))
                        .where((e) => widget.maxLevel == null || (e.level ?? 0) <= widget.maxLevel!)
                        .toList()
                      ..sort((a, b) => a.name.compareTo(b.name));
                    return ListView.separated(
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const Gap(8),
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = _selected.contains(option);
                        return Card(
                          color: isSelected ? context.customColors?.cardColor : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: isSelected ? Colors.white : Colors.white24),
                          ),
                          child: ListTile(
                            title: Text(option.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              [
                                if (option.source != null) option.source!,
                                if (option.level != null) 'с ${option.level} уровня'
                              ].join(' · '),
                            ),
                            onTap: () => _toggle(option),
                            trailing: IconButton(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => HtmlDialog(title: option.name, html: option.descriptionHtml),
                              ),
                              icon: const Icon(Icons.info),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selected.length == widget.count ? () => widget.onSelected([..._selected]) : null,
                child: const Text('Далее'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
