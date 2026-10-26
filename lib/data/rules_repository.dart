import 'package:dnd_character_list/data/ttg/ttg_backgrounds_mapper.dart';
import 'package:dnd_character_list/data/ttg/ttg_cache.dart';
import 'package:dnd_character_list/data/ttg/ttg_class_mapper.dart';
import 'package:dnd_character_list/data/ttg/ttg_client.dart';
import 'package:dnd_character_list/data/ttg/ttg_equipment_mapper.dart';
import 'package:dnd_character_list/data/ttg/ttg_feats_mapper.dart';
import 'package:dnd_character_list/data/ttg/ttg_text.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/equipment_catalog.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/gear.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:injectable/injectable.dart';

/// Классы, предыстории, черты и предметы «Книги игрока» с ttg.club.
@lazySingleton
class RulesRepository {
  /// Правила меняются редко, а при недоступности сайта используется устаревший кэш.
  static const _ttl = Duration(days: 30);

  /// Предыстории, черты и предметы берутся только из «Книги игрока».
  static const _book = 'PHB';

  /// Категории `/items`, которые не входят в снаряжение каталога: транспорт, товары и
  /// предметы, которые описаны в разделах оружия и доспехов.
  static const _excludedItemCategories = [
    'MOUNT',
    'VEHICLE_LAND',
    'VEHICLE_WATER',
    'VEHICLE_AIR',
    'TRADE_GOOD',
    'SIEGE_EQUIPMENT',
    'WEAPON',
    'ARMOR',
    'SHIELD',
  ];

  final TtgClient _client;
  final TtgCache _cache;
  final TtgClassMapper _classMapper;
  final TtgBackgroundsMapper _backgroundsMapper;
  final TtgFeatsMapper _featsMapper;
  final TtgEquipmentMapper _equipmentMapper;

  final _classes = <String, Future<ClassInfo>>{};
  Future<List<Background>>? _backgrounds;
  Future<List<Feat>>? _feats;
  Future<EquipmentCatalog>? _equipment;

  RulesRepository(
    this._client,
    this._cache,
    this._classMapper,
    this._backgroundsMapper,
    this._featsMapper,
    this._equipmentMapper,
  );

  /// Описание класса по ссылке, например `/classes/bard`, вместе с официальными подклассами.
  Future<ClassInfo> getClass(String link) => _classes[link] ??= _cache
      .load(
        key: 'class_${TtgText.slug(link)}',
        ttl: _ttl,
        fetch: () => _loadClass(link),
        toJson: (value) => value.toJson(),
        fromJson: (json) => ClassInfo.fromJson(json as Map<String, dynamic>),
      )
      .catchError((Object e) => throw _forget(() => _classes.remove(link), e));

  Future<ClassInfo> _loadClass(String link) async {
    final json = await _client.fetch(link, (json) => json as Map<String, dynamic>);
    final subclasses = await TtgClient.mapConcurrently(
      _classMapper.subclassLinks(json),
      (link) => _client.fetch(link, (json) => json as Map<String, dynamic>),
    );
    return _classMapper.map(json, subclasses: subclasses);
  }

  Future<List<Background>> getBackgrounds() => _backgrounds ??= _cache
      .load(
        key: 'backgrounds',
        ttl: _ttl,
        // «Собственная предыстория» — правило создания своей предыстории, без навыков и снаряжения.
        fetch: () async => (await _loadAll('/backgrounds', _backgroundsMapper.map))
            .where((e) => e.skills.isNotEmpty)
            .toList(),
        toJson: (value) => value.map((e) => e.toJson()).toList(),
        fromJson: (json) => (json as List).map((e) => Background.fromJson(e)).toList(),
      )
      .catchError((Object e) => throw _forget(() => _backgrounds = null, e));

  Future<List<Feat>> getFeats() => _feats ??= _cache
      .load(
        key: 'feats',
        ttl: _ttl,
        fetch: () => _loadAll('/feats', _featsMapper.map),
        toJson: (value) => value.map((e) => e.toJson()).toList(),
        fromJson: (json) => (json as List).map((e) => Feat.fromJson(e)).toList(),
      )
      .catchError((Object e) => throw _forget(() => _feats = null, e));

  Future<EquipmentCatalog> getEquipment() => _equipment ??= _cache
      .load(
        key: 'equipment',
        ttl: _ttl,
        fetch: _loadEquipment,
        toJson: (value) => value.toJson(),
        fromJson: (json) => EquipmentCatalog.fromJson(json as Map<String, dynamic>),
      )
      .catchError((Object e) => throw _forget(() => _equipment = null, e));

  Future<EquipmentCatalog> _loadEquipment() async {
    final mapper = _equipmentMapper;
    final (weapons, armors, items, categories) = await (
      _loadAll('/weapons', mapper.weapon),
      _loadAll('/armors', mapper.armor),
      _list('/items'),
      _itemCategories(),
    ).wait;

    final tools = <(Map<String, dynamic>, ToolCategory)>[];
    final packs = <Map<String, dynamic>>[];
    final gear = <Gear>[];
    for (final item in items) {
      final link = TtgText.normalizeLink(item['url']);
      final category = categories[link];
      if (_excludedItemCategories.contains(category)) continue;
      final toolCategory = TtgEquipmentMapper.toolCategory(link, category);
      if (toolCategory != null || (category != null && TtgEquipmentMapper.toolCategories.containsKey(category))) {
        // У отдельных инструментов (`TOOL`) категория определяется по названию.
        final resolved = toolCategory ?? TtgText.toolCategoryIn(TtgText.names(item['name']).$1);
        if (resolved != null) tools.add((item, resolved));
      } else if (category == TtgEquipmentMapper.setsCategory && TtgEquipmentMapper.isPack(item)) {
        packs.add(item);
      } else {
        gear.add(mapper.gear(item, group: TtgEquipmentMapper.gearGroups[category]));
      }
    }

    final (loadedTools, loadedPacks) = await (
      TtgClient.mapConcurrently(
        tools,
        (tool) => _client.fetch(tool.$1['url'], (json) => mapper.tool(json as Map<String, dynamic>, tool.$2)),
      ),
      TtgClient.mapConcurrently(
        packs,
        (pack) => _client.fetch(pack['url'], (json) => mapper.pack(pack['url'], json as Map<String, dynamic>)),
      ),
    ).wait;

    return EquipmentCatalog(
      weapons: weapons,
      armors: armors.whereType<Armor>().toList(),
      shields: armors.whereType<Shield>().toList(),
      gear: gear,
      packs: loadedPacks,
      tools: loadedTools,
    );
  }

  /// Категория каждого предмета «Книги игрока» по ссылке. У предмета может быть несколько
  /// категорий; берётся первая из перечисленных, поэтому инструменты и наборы идут первыми.
  Future<Map<String, String>> _itemCategories() async {
    final requested = [
      ...TtgEquipmentMapper.toolCategories.keys,
      TtgEquipmentMapper.setsCategory,
      ..._excludedItemCategories,
      ...TtgEquipmentMapper.gearGroups.keys,
    ];
    final lists = await TtgClient.mapConcurrently(
      requested,
      (category) => _list('/items', filter: {
        'category': [category],
        'book': [_book],
      }),
    );
    final categories = <String, String>{};
    for (final (index, list) in lists.indexed) {
      for (final item in list) {
        categories.putIfAbsent(TtgText.normalizeLink(item['url']), () => requested[index]);
      }
    }
    return categories;
  }

  /// Неудачная загрузка не запоминается, чтобы следующий запрос попробовал снова.
  Object _forget(void Function() reset, Object error) {
    reset();
    return error;
  }

  /// Список раздела; без фильтра остаются только предметы из «Книги игрока».
  Future<List<Map<String, dynamic>>> _list(String path, {Map<String, Object?>? filter}) async {
    final items = await _client.fetch(
      path,
      (json) => (json as List).cast<Map<String, dynamic>>(),
      body: {...TtgClient.allItems, if (filter != null) 'filter': filter},
    );
    return filter != null ? items : items.where((e) => TtgText.bookOf(e['source']) == _book).toList();
  }

  /// Список раздела и ответы по каждому элементу из «Книги игрока».
  Future<List<T>> _loadAll<T>(String path, T Function(String link, Map<String, dynamic> json) map) async {
    final items = await _list(path);
    return TtgClient.mapConcurrently(
      items.map((e) => e['url'] as String).toList(),
      (link) => _client.fetch(link, (json) => map(link, json as Map<String, dynamic>)),
    );
  }
}
