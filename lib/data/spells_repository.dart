import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/ttg/ttg_client.dart';
import 'package:dnd_character_list/data/ttg/ttg_spells_mapper.dart';
import 'package:dnd_character_list/data/ttg/ttg_text.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// Заклинания из официальных книг с ttg.club с кэшем на диске.
///
/// Общий список хранится [_indexTtl] и при недоступности сайта берётся из
/// устаревшего кэша. Описания заклинаний не меняются, поэтому кэшируются навсегда.
@lazySingleton
class SpellsRepository {
  static const _indexTtl = Duration(days: 7);
  static const _detailsConcurrency = 4;

  final TtgClient _client;
  final TtgSpellsMapper _mapper;

  List<Spell>? _spells;
  Future<List<Spell>>? _spellsLoading;
  final _details = <String, SpellDetails>{};
  final _detailsLoading = <String, Future<SpellDetails>>{};

  final Future<Directory> Function() _cacheDirectory;

  SpellsRepository(
    this._client,
    this._mapper, {
    @ignoreParam Future<Directory> Function()? cacheDirectory,
  }) : _cacheDirectory = cacheDirectory ?? getApplicationSupportDirectory;

  Future<List<Spell>> getSpells({bool forceRefresh = false}) {
    if (_spells != null && !forceRefresh) return Future.value(_spells);
    return _spellsLoading ??= _loadSpells(forceRefresh).whenComplete(() {
      _spellsLoading = null;
    });
  }

  /// Заклинание по ссылке из описаний, например `/spells/Thunderwave`.
  Future<Spell?> findByLink(String link) async {
    final normalized = TtgText.normalizeLink(link);
    return (await getSpells()).firstWhereOrNull((e) => e.link == normalized);
  }

  Future<Spell> withDetails(Spell spell) async {
    if (spell.details != null) return spell;
    return spell.copyWith(details: await _getDetails(spell));
  }

  /// Подгружает описания; если какое-то не загрузилось, заклинание остаётся без него.
  Future<List<Spell>> withDetailsIfPossible(List<Spell> spells) => Future.wait(
        spells.map((e) => withDetails(e).catchError((_) => e)),
      );

  /// Загружает полные данные заклинаний в порядке списка, не больше [_detailsConcurrency]
  /// запросов одновременно. Отдаёт каждое заклинание по мере готовности; если описание
  /// загрузить не удалось, заклинание приходит без него. Отмена подписки останавливает загрузку.
  Stream<Spell> loadDetails(List<Spell> spells) {
    final queue = [...spells];
    var isCancelled = false;
    late final StreamController<Spell> controller;

    Future<void> worker() async {
      while (queue.isNotEmpty && !isCancelled) {
        final spell = queue.removeAt(0);
        final loaded = await withDetails(spell).catchError((_) => spell);
        if (!isCancelled) controller.add(loaded);
      }
    }

    controller = StreamController<Spell>(
      onListen: () => Future.wait(List.generate(_detailsConcurrency, (_) => worker())).whenComplete(controller.close),
      onCancel: () => isCancelled = true,
    );
    return controller.stream;
  }

  /// Заклинания по ссылкам с описаниями, например заклинания происхождения чародея.
  Future<List<Spell>> resolveLinks(List<String> links) => Future.wait(links.map(_resolve));

  /// Находит заклинания по ссылкам, например для расовых заклинаний.
  Future<Map<SpellSlot, Spell>> resolve(Map<SpellSlot, String> links) async {
    final entries = await Future.wait(links.entries.map((e) async => MapEntry(e.key, await _resolve(e.value))));
    return Map.fromEntries(entries);
  }

  Future<Spell> _resolve(String link) async {
    final spell = await findByLink(link);
    if (spell == null) throw TtgException('Заклинание $link не найдено');
    return withDetails(spell).catchError((_) => spell);
  }

  Future<List<Spell>> _loadSpells(bool forceRefresh) async {
    final file = await _cacheFile('spells.json');
    _CachedIndex? cached;
    if (await file.exists()) {
      try {
        cached = _CachedIndex.fromJson(jsonDecode(await file.readAsString()));
      } catch (_) {
        cached = null;
      }
    }

    if (cached != null && !forceRefresh && DateTime.now().difference(cached.savedAt) < _indexTtl) {
      return _spells = cached.spells;
    }

    try {
      final spells = await _fetchSpells();
      await file.writeAsString(jsonEncode(_CachedIndex(savedAt: DateTime.now(), spells: spells).toJson()));
      return _spells = spells;
    } on TtgException {
      if (cached != null) return _spells = cached.spells;
      rethrow;
    }
  }

  /// В общем списке нет классов, поэтому списки классов запрашиваются отдельно фильтром по классу.
  Future<List<Spell>> _fetchSpells() async {
    final items = (await _client.fetch(
      '/spells',
      (json) => (json as List).cast<Map<String, dynamic>>(),
      body: TtgClient.allItems,
    ))
        .where((e) => TtgText.isOfficial(e['source']))
        .toList();
    final books = items.map((e) => TtgText.bookOf(e['source'])).nonNulls.toSet().toList();
    final classKinds = ClassKind.values.where((e) => e.ttgSpellsFilterId != null).toList();
    final classLists = await TtgClient.mapConcurrently(
      classKinds,
      (classKind) => _client.fetch(
        '/spells',
        (json) => (json as List).map((e) => TtgText.normalizeLink((e as Map)['url'])).toSet(),
        body: TtgSpellsMapper.classSpellsRequest(classKind, books),
      ),
    );
    return items.map((item) {
      final link = TtgText.normalizeLink(item['url']);
      final classes = [
        for (final (index, links) in classLists.indexed)
          if (links.contains(link)) classKinds[index],
      ];
      return _mapper.mapListItem(item, classes);
    }).toList();
  }

  Future<SpellDetails> _getDetails(Spell spell) async {
    final details = _details[spell.id];
    if (details != null) return details;
    // Колбэк не должен ничего возвращать: whenComplete дождался бы возвращённого Future,
    // а `remove` вернул бы этот же Future, и загрузка зависла бы навсегда.
    return _detailsLoading[spell.id] ??= _loadDetails(spell).whenComplete(() {
      _detailsLoading.remove(spell.id);
    });
  }

  Future<SpellDetails> _loadDetails(Spell spell) async {
    final file = await _cacheFile('spell_details/${TtgText.slug(spell.link)}.json');
    if (await file.exists()) {
      try {
        return _details[spell.id] = SpellDetails.fromJson(jsonDecode(await file.readAsString()));
      } catch (_) {
        // Битый кэш просто загружаем заново.
      }
    }

    final details = await _client.fetch(spell.link, (json) => _mapper.mapDetails(json as Map<String, dynamic>));
    await file.writeAsString(jsonEncode(details.toJson()));
    return _details[spell.id] = details;
  }

  Future<File> _cacheFile(String name) async {
    final directory = await _cacheDirectory();
    final file = File('${directory.path}/ttg/${name.replaceAll(RegExp(r"[^\w/.-]"), '_')}');
    await file.parent.create(recursive: true);
    return file;
  }
}

class _CachedIndex {
  final DateTime savedAt;
  final List<Spell> spells;

  const _CachedIndex({required this.savedAt, required this.spells});

  Map<String, dynamic> toJson() => {
        'savedAt': savedAt.toIso8601String(),
        'spells': spells.map((e) => e.toJson()).toList(),
      };

  factory _CachedIndex.fromJson(Map<String, dynamic> json) => _CachedIndex(
        savedAt: DateTime.parse(json['savedAt']),
        spells: (json['spells'] as List).map((e) => Spell.fromJson(e)).toList(),
      );
}
