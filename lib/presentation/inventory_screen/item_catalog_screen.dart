import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/equipment_catalog.dart';
import 'package:dnd_character_list/domain/models/gear.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/loading_error.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/item_texts.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Предметы «Книги игрока» с ttg.club для добавления в инвентарь.
@RoutePage()
class ItemCatalogScreen extends StatefulWidget {
  final PlayerCubit playerCubit;

  const ItemCatalogScreen({super.key, required this.playerCubit});

  @override
  State<ItemCatalogScreen> createState() => _ItemCatalogScreenState();
}

enum _Category {
  weapons('Оружие'),
  armor('Доспехи и щиты'),
  tools('Инструменты'),
  packs('Наборы'),
  gear('Снаряжение');

  final String title;

  const _Category(this.title);

  List<Object> of(EquipmentCatalog catalog) => switch (this) {
        _Category.weapons => catalog.weapons,
        _Category.armor => [...catalog.armors, ...catalog.shields],
        _Category.tools => catalog.tools,
        _Category.packs => catalog.packs,
        _Category.gear => catalog.gear,
      };
}

class _ItemCatalogScreenState extends State<ItemCatalogScreen> {
  final _repository = getIt<RulesRepository>();
  late Future<EquipmentCatalog> _catalog = _repository.getEquipment();
  _Category _category = _Category.weapons;
  String _query = '';

  /// Набор распаковывается в отдельные вещи, чтобы расходуемые можно было считать.
  void _add(EquipmentCatalog catalog, Object item) {
    for (final inventoryItem in catalog.inventoryItems(item)) {
      widget.playerCubit.addItem(inventoryItem);
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Добавлено: ${ItemTexts.name(item)}'), duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить предмет'),
        actions: [
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _CustomItemTypeDialog(playerCubit: widget.playerCubit),
            ),
            child: const Text('Свой предмет'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Поиск по названию',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
              ),
              const Gap(8),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final category in _Category.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category.title),
                          selected: category == _category,
                          onSelected: (_) => setState(() => _category = category),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _catalog,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return LoadingError(
                        message: 'Не удалось загрузить предметы с ttg.club.',
                        error: snapshot.error!,
                        onRetry: () => setState(() => _catalog = _repository.getEquipment()),
                      );
                    }
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final items = (_query.isEmpty ? _category.of(snapshot.data!) : snapshot.data!.all)
                        .where((e) => ItemTexts.name(e).toLowerCase().contains(_query))
                        .toList();
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final subtitle = ItemTexts.subtitle(item);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(ItemTexts.name(item)),
                          subtitle: Text(
                            [if (subtitle != null) subtitle, if (_cost(item) case final cost?) cost].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.theme.textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            onPressed: () => _add(snapshot.data!, item),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                          onTap: () => _add(snapshot.data!, item),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _cost(Object item) => switch (item) {
        Weapon item => item.cost?.toString(),
        Armor item => item.cost?.toString(),
        Shield item => item.cost?.toString(),
        Tool item => item.price.toString(),
        Gear item => item.cost?.toString(),
        EquipmentPack item => item.cost?.toString(),
        _ => null,
      };
}

/// Свой предмет: магическое оружие, особый доспех или произвольная вещь.
class _CustomItemTypeDialog extends StatelessWidget {
  final PlayerCubit playerCubit;

  const _CustomItemTypeDialog({required this.playerCubit});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Свой предмет', textAlign: TextAlign.center),
      children: [
        for (final (type, title) in [
          (Weapon, 'Оружие'),
          (Armor, 'Доспех'),
          (Shield, 'Щит'),
          (CustomInvetoryItem, 'Предмет с описанием'),
          (String, 'Предмет'),
        ])
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              context.router.push(InventoryAddItemRoute(itemType: type, playerCubit: playerCubit));
            },
            child: Text(title),
          ),
      ],
    );
  }
}
