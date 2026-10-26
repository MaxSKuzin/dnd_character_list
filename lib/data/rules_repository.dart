import 'package:dnd_character_list/data/dnd_su/dnd_su_backgrounds_parser.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_cache.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_class_parser.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_client.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_feats_parser.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:injectable/injectable.dart';

/// Классы, предыстории и черты «Книги игрока» с dnd.su.
@lazySingleton
class RulesRepository {
  /// Правила меняются редко, а при недоступности сайта используется устаревший кэш.
  static const _ttl = Duration(days: 30);

  final DndSuClient _client;
  final DndSuCache _cache;
  final DndSuClassParser _classParser;
  final DndSuBackgroundsParser _backgroundsParser;
  final DndSuFeatsParser _featsParser;

  final _classes = <String, Future<ClassInfo>>{};
  Future<List<Background>>? _backgrounds;
  Future<List<Feat>>? _feats;

  RulesRepository(
    this._client,
    this._cache,
    this._classParser,
    this._backgroundsParser,
    this._featsParser,
  );

  /// Описание класса по ссылке, например `/class/88-bard/`.
  Future<ClassInfo> getClass(String link) => _classes[link] ??= _cache
      .load(
        key: 'class_${link.replaceAll(RegExp(r'[^\w-]'), '')}',
        ttl: _ttl,
        fetch: () => _client.getParsed(link, (body) => _classParser.parseClass(link, body)),
        toJson: (value) => value.toJson(),
        fromJson: (json) => ClassInfo.fromJson(json as Map<String, dynamic>),
      )
      .catchError((Object e) => throw _forget(() => _classes.remove(link), e));

  Future<List<Background>> getBackgrounds() => _backgrounds ??= _cache
      .load(
        key: 'backgrounds',
        ttl: _ttl,
        fetch: () => _loadAll(
          DndSuBackgroundsParser.indexPath,
          _backgroundsParser.parseIndex,
          _backgroundsParser.parseBackground,
        ),
        toJson: (value) => value.map((e) => e.toJson()).toList(),
        fromJson: (json) => (json as List).map((e) => Background.fromJson(e)).toList(),
      )
      .catchError((Object e) => throw _forget(() => _backgrounds = null, e));

  Future<List<Feat>> getFeats() => _feats ??= _cache
      .load(
        key: 'feats',
        ttl: _ttl,
        fetch: () => _loadAll(DndSuFeatsParser.indexPath, _featsParser.parseIndex, _featsParser.parseFeat),
        toJson: (value) => value.map((e) => e.toJson()).toList(),
        fromJson: (json) => (json as List).map((e) => Feat.fromJson(e)).toList(),
      )
      .catchError((Object e) => throw _forget(() => _feats = null, e));

  /// Неудачная загрузка не запоминается, чтобы следующий запрос попробовал снова.
  Object _forget(void Function() reset, Object error) {
    reset();
    return error;
  }

  Future<List<T>> _loadAll<T>(
    String indexPath,
    List<DndSuListItem> Function(String body) parseIndex,
    T Function(String link, String body) parse,
  ) async {
    final items = await _client.getParsed(indexPath, parseIndex);
    return DndSuClient.mapConcurrently(
      items,
      (item) => _client.getParsed(item.link, (body) => parse(item.link, body)),
    );
  }
}
