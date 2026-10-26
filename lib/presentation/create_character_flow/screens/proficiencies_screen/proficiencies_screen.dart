import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/models/equipment_catalog.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/loading_error.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Выбор владений: инструменты «на ваш выбор» и языки.
@RoutePage()
class ProficienciesScreen extends StatefulWidget {
  final String title;

  /// Пояснение под заголовком: откуда владения.
  final String? description;
  final List<ToolProficiencyOption> tools;
  final int languagesCount;
  final List<Language> knownLanguages;

  /// Инструменты, которыми персонаж уже владеет: их нельзя выбрать повторно.
  final List<String> knownTools;

  /// Каталог предметов; по умолчанию загружается с ttg.club.
  final EquipmentCatalog? catalog;

  /// Получает названия инструментов (указанных и выбранных) и выбранные языки.
  final void Function(List<String> tools, List<Language> languages) onSelected;

  const ProficienciesScreen({
    super.key,
    required this.title,
    required this.onSelected,
    this.description,
    this.tools = const [],
    this.languagesCount = 0,
    this.knownLanguages = const [],
    this.knownTools = const [],
    this.catalog,
  });

  @override
  State<ProficienciesScreen> createState() => _ProficienciesScreenState();
}

class _ProficienciesScreenState extends State<ProficienciesScreen> {
  late Future<EquipmentCatalog> _catalog = _loadCatalog();

  Future<EquipmentCatalog> _loadCatalog() =>
      widget.catalog != null ? Future.value(widget.catalog) : getIt<RulesRepository>().getEquipment();

  late final _choices = widget.tools.where((e) => e.isChoice).toList();
  late final _selectedTools = {for (final option in _choices) option: <String>[]};
  final _selectedLanguages = <Language>[];

  /// Инструмент уже есть у персонажа, даётся этим же экраном без выбора
  /// или выбран в другом разделе.
  bool _isTaken(ToolProficiencyOption option, String tool) {
    final name = tool.toLowerCase();
    final owned = [...widget.knownTools, ...widget.tools.where((e) => !e.isChoice).map((e) => e.title)];
    return owned.any((e) => e.toLowerCase() == name) ||
        _selectedTools.entries.any((e) => e.key != option && e.value.contains(tool));
  }

  bool get _isComplete =>
      _choices.every((e) => _selectedTools[e]!.length == e.choose) &&
      _selectedLanguages.length == widget.languagesCount;

  void _toggle<T>(List<T> selected, T value, int max) => setState(() {
        if (selected.contains(value)) {
          selected.remove(value);
        } else if (selected.length < max) {
          selected.add(value);
        }
      });

  @override
  Widget build(BuildContext context) {
    final fixedTools = widget.tools.where((e) => !e.isChoice).map((e) => e.title).toList();
    final hint = context.theme.textTheme.bodySmall?.copyWith(color: Colors.white60);
    return StepScaffold(
      title: widget.title,
      description: widget.description,
      onAction: _isComplete
          ? () => widget.onSelected(
                [...fixedTools, ..._selectedTools.values.expand((e) => e)],
                _selectedLanguages,
              )
          : null,
      body: FutureBuilder(
        future: _catalog,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LoadingError(
              message: 'Не удалось загрузить инструменты с ttg.club.',
              error: snapshot.error!,
              onRetry: () => setState(() => _catalog = _loadCatalog()),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final catalog = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (fixedTools.isNotEmpty) ...[
                SheetSection(
                  icon: Icons.handyman_outlined,
                  title: 'Вы получаете',
                  child: Text(fixedTools.join(', ')),
                ),
                const Gap(12),
              ],
              for (final option in _choices) ...[
                SheetSection(
                  icon: Icons.handyman_outlined,
                  title: option.categories.map((e) => e.localizedName).join(' или '),
                  trailing: _Counter(selected: _selectedTools[option]!.length, total: option.choose),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        [
                          'Владение инструментами: ${option.title.toLowerCase()}',
                          if (widget.knownTools.isNotEmpty) 'Уже владеете: ${widget.knownTools.join(', ')}',
                        ].join('\n'),
                        style: hint,
                      ),
                      const Gap(8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: option.categories
                            .expand(catalog.toolsOf)
                            .map(
                              (tool) => FilterChip(
                                label: Text(tool.name),
                                selected: _selectedTools[option]!.contains(tool.name),
                                onSelected: _isTaken(option, tool.name)
                                    ? null
                                    : (_) => _toggle(_selectedTools[option]!, tool.name, option.choose),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
              ],
              if (widget.languagesCount > 0)
                SheetSection(
                  icon: Icons.translate,
                  title: 'Языки',
                  trailing: _Counter(selected: _selectedLanguages.length, total: widget.languagesCount),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.knownLanguages.isNotEmpty) ...[
                        Text(
                          'Уже знаете: ${widget.knownLanguages.map((e) => e.localizedName).join(', ')}',
                          style: hint,
                        ),
                        const Gap(8),
                      ],
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: Language.values
                            .where((e) => !widget.knownLanguages.contains(e))
                            .map(
                              (language) => FilterChip(
                                label: Text(language.localizedName),
                                selected: _selectedLanguages.contains(language),
                                onSelected: (_) => _toggle(_selectedLanguages, language, widget.languagesCount),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Сколько выбрано в разделе: «1 из 2», когда набрано — цветом темы.
class _Counter extends StatelessWidget {
  final int selected;
  final int total;

  const _Counter({required this.selected, required this.total});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: SheetBadge('$selected из $total', color: selected == total ? context.theme.colorScheme.primary : null),
      );
}
