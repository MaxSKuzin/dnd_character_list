import 'dart:convert';

import 'package:dnd_master/data/ttg/ttg_monster_mapper.dart';
import 'package:dnd_master/domain/models/monster.dart';
import 'package:http/http.dart' as http;

class TtgException implements Exception {
  final String message;

  const TtgException(this.message);

  @override
  String toString() => message;
}

/// Бестиарий https://5e14.ttg.club (правила 2014 года). Описание api: `/v3/api-docs`.
///
/// Список (~2500 существ) загружается один раз за запуск и ищется на устройстве, статблок — при выборе
/// монстра. В подготовленных ситуациях статблок хранится целиком, поэтому кэша на диске нет.
class TtgBestiary {
  static const _baseUrl = 'https://5e14.ttg.club/api/v1';
  static const _timeout = Duration(seconds: 30);
  static const _attempts = 3;

  final http.Client _client;
  Future<List<MonsterSummary>>? _list;
  final _monsters = <String, Future<MonsterTemplate>>{};

  TtgBestiary({http.Client? client}) : _client = client ?? http.Client();

  /// Весь список; неудачная загрузка не запоминается.
  Future<List<MonsterSummary>> list() => _list ??= _remember(
    _fetch('/bestiary', TtgMonsterMapper.summaries, body: const {'page': 0, 'size': -1}),
    () => _list = null,
  );

  /// Статблок по ссылке из списка: `/bestiary/goblin`.
  Future<MonsterTemplate> monster(String url) => _monsters[url] ??= _remember(
    _fetch(url, (json) => TtgMonsterMapper.monster(json as Map<String, dynamic>)),
    () => _monsters.remove(url),
  );

  static Future<T> _remember<T>(Future<T> future, void Function() forget) async {
    try {
      return await future;
    } catch (_) {
      forget();
      rethrow;
    }
  }

  /// Все запросы — `POST` с JSON. При ошибке сети или неожиданном формате ответа — ещё несколько попыток.
  Future<T> _fetch<T>(String path, T Function(Object? json) parse, {Map<String, Object?> body = const {}}) async {
    for (var attempt = 1; ; attempt++) {
      try {
        return parse(await _post(path, body));
      } on Object catch (e) {
        if (attempt == _attempts) {
          throw e is TtgException ? e : TtgException('Неожиданный ответ ttg.club на $path: $e');
        }
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  Future<Object?> _post(String path, Map<String, Object?> body) async {
    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: const {
              'User-Agent': 'dnd_master',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on Exception catch (e) {
      throw TtgException('Не удалось загрузить данные с ttg.club: $e');
    }
    if (response.statusCode != 200) {
      throw TtgException('Не удалось загрузить данные с ttg.club: HTTP ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  void dispose() => _client.close();
}
