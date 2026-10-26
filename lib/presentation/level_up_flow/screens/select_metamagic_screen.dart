import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/models/metamagic.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/loading_error.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Выбор вариантов метамагии чародея из официальных книг ttg.club.
@RoutePage()
class SelectMetamagicScreen extends StatefulWidget {
  final String title;
  final String? description;

  /// Сколько вариантов нужно выбрать.
  final int count;

  /// Уже известные варианты: их нельзя выбрать снова.
  final List<Metamagic> known;

  final void Function(List<Metamagic> options) onSelected;

  const SelectMetamagicScreen({
    super.key,
    this.title = 'Метамагия',
    this.description,
    required this.count,
    this.known = const [],
    required this.onSelected,
  });

  @override
  State<SelectMetamagicScreen> createState() => _SelectMetamagicScreenState();
}

class _SelectMetamagicScreenState extends State<SelectMetamagicScreen> {
  final _repository = getIt<RulesRepository>();
  late Future<List<Metamagic>> _options = _repository.getMetamagic();
  final _selected = <Metamagic>[];

  void _toggle(Metamagic option) => setState(() {
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
                widget.title,
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
                        message: 'Не удалось загрузить метамагию с ttg.club.',
                        error: snapshot.error!,
                        onRetry: () => setState(() => _options = _repository.getMetamagic()),
                      );
                    }
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final options = snapshot.data!.where((e) => !widget.known.contains(e)).toList()
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
                            subtitle: option.source == null ? null : Text(option.source!),
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
