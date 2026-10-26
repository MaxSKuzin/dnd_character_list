import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/models/equipment_catalog.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/starting_equipment.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/loading_error.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/item_texts.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Стартовое снаряжение класса: в каждой строке списка выбирается один вариант,
/// а «любое простое оружие» и подобное — конкретным предметом из каталога ttg.club.
@RoutePage()
class StartingEquipmentScreen extends StatefulWidget {
  final String title;
  final List<StartingEquipmentChoice> choices;
  final void Function(List<InventoryItem> items) onSelected;

  /// Каталог предметов; по умолчанию загружается с ttg.club.
  final EquipmentCatalog? catalog;

  const StartingEquipmentScreen({
    super.key,
    required this.title,
    required this.choices,
    required this.onSelected,
    this.catalog,
  });

  @override
  State<StartingEquipmentScreen> createState() => _StartingEquipmentScreenState();
}

class _StartingEquipmentScreenState extends State<StartingEquipmentScreen> {
  late Future<EquipmentCatalog> _catalog = _loadCatalog();

  /// Выбранный вариант в каждой строке; строки с одним вариантом выбраны сразу.
  late final _options = [for (final choice in widget.choices) choice.options.length == 1 ? 0 : null];

  /// Предметы, выбранные из категорий: ключ — (строка, ссылка, номер предмета).
  final _picks = <(int, int, int), Object>{};

  Future<EquipmentCatalog> _loadCatalog() =>
      widget.catalog != null ? Future.value(widget.catalog) : getIt<RulesRepository>().getEquipment();

  Iterable<(int, int, EquipmentRef)> _choiceRefs(int choice) sync* {
    final option = _options[choice];
    if (option == null) return;
    for (final (index, ref) in widget.choices[choice].options[option].items.indexed) {
      if (ref.isChoice) yield (choice, index, ref);
    }
  }

  bool get _isComplete => [
        for (var choice = 0; choice < widget.choices.length; choice++)
          _options[choice] != null &&
              _choiceRefs(choice)
                  .every((e) => List.generate(e.$3.quantity, (n) => _picks[(e.$1, e.$2, n)]).every((e) => e != null)),
      ].every((e) => e);

  List<InventoryItem> _items(EquipmentCatalog catalog) => [
        for (var choice = 0; choice < widget.choices.length; choice++)
          for (final (index, ref) in widget.choices[choice].options[_options[choice]!].items.indexed)
            if (ref.isChoice)
              for (var n = 0; n < ref.quantity; n++) InventoryItem(quantity: 1, item: _picks[(choice, index, n)]!)
            else
              InventoryItem(quantity: ref.quantity, item: catalog.find(ref) ?? _capitalize(ref.text)),
      ];

  static String _capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: _catalog,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return LoadingError(
                  message: 'Не удалось загрузить предметы с ttg.club.',
                  error: snapshot.error!,
                  onRetry: () => setState(() => _catalog = _loadCatalog()),
                );
              }
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final catalog = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Gap(8),
                  const Text(
                    'В каждой строке выберите один вариант. Снаряжение добавляется к снаряжению предыстории.',
                    textAlign: TextAlign.center,
                  ),
                  const Gap(16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: widget.choices.length,
                      separatorBuilder: (_, __) => const Gap(12),
                      itemBuilder: (context, index) => _buildChoice(catalog, index),
                    ),
                  ),
                  const Gap(16),
                  OutlinedButton(
                    onPressed: _isComplete ? () => widget.onSelected(_items(catalog)) : null,
                    child: const Text('Далее'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChoice(EquipmentCatalog catalog, int choice) {
    final options = widget.choices[choice].options;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white24),
      ),
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: RadioGroup<int>(
          groupValue: _options[choice],
          onChanged: (value) => setState(() => _options[choice] = value),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, option) in options.indexed) ...[
                if (options.length > 1)
                  RadioListTile<int>(
                    value: index,
                    title: Text(_capitalize(option.text)),
                    subtitle: _describe(catalog, option),
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.check),
                    title: Text(_capitalize(option.text)),
                    subtitle: _describe(catalog, option),
                  ),
                if (_options[choice] == index)
                  for (final (ref, refIndex)
                      in option.items.indexed.map((e) => (e.$2, e.$1)).where((e) => e.$1.isChoice))
                    for (var n = 0; n < ref.quantity; n++)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                        child: DropdownButtonFormField<Object>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: ref.quantity > 1 ? '${_capitalize(ref.text)}: ${n + 1}' : _capitalize(ref.text),
                            border: const OutlineInputBorder(),
                          ),
                          initialValue: _picks[(choice, refIndex, n)],
                          items: catalog
                              .choicesFor(ref)
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    [ItemTexts.name(item), ItemTexts.subtitle(item)].nonNulls.join(' · '),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (item) => setState(() => _picks[(choice, refIndex, n)] = item!),
                        ),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Что именно даёт вариант: предметы каталога со свойствами.
  Widget? _describe(EquipmentCatalog catalog, StartingEquipmentOption option) {
    final lines = option.items.where((e) => !e.isChoice).map((ref) {
      final item = catalog.find(ref);
      if (item == null) return null;
      final details = ItemTexts.subtitle(item);
      // Если вариант — один предмет, его название уже в заголовке.
      if (option.items.length == 1 && ref.quantity == 1) return details;
      return '${ref.quantity > 1 ? '${ref.quantity} × ' : ''}${ItemTexts.name(item)}${details == null ? '' : ': $details'}';
    }).nonNulls;
    if (lines.isEmpty) return null;
    return Text(lines.join('\n'), style: context.theme.textTheme.bodySmall);
  }
}
