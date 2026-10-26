import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

class TtgException implements Exception {
  final String message;

  const TtgException(this.message);

  @override
  String toString() => 'TtgException: $message';
}

/// Клиент JSON api https://5e14.ttg.club (правила 2014 года). Описание api: `/v3/api-docs`.
///
/// Все запросы — `POST` с телом в JSON. Списки принимают `{page, size, search, filter, order}`,
/// `size: -1` возвращает список целиком. Страницы отдельных сущностей — `POST /api/v1/<раздел>/<slug>`.
@lazySingleton
class TtgClient {
  static const baseUrl = 'https://5e14.ttg.club';
  static const _apiPath = '/api/v1';
  static const _timeout = Duration(seconds: 30);

  /// Запрос всего списка без фильтров.
  static const allItems = {'page': 0, 'size': -1};

  final http.Client _client = http.Client();

  /// Отправляет запрос, например `post('/classes/bard')`, и возвращает разобранный JSON.
  Future<Object?> post(String path, [Map<String, Object?> body = const {}]) async {
    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$baseUrl$_apiPath$path'),
            headers: const {
              'User-Agent': 'dnd_character_list',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on Exception catch (e) {
      throw TtgException('Не удалось загрузить $path: $e');
    }
    if (response.statusCode != 200) {
      throw TtgException('Не удалось загрузить $path: HTTP ${response.statusCode}');
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException catch (e) {
      throw TtgException('Некорректный ответ на $path: $e');
    }
  }

  /// Загружает и разбирает ответ. При сетевой ошибке или неожиданном формате ответа
  /// пробует ещё несколько раз.
  Future<T> fetch<T>(
    String path,
    T Function(Object? json) parse, {
    Map<String, Object?> body = const {},
    int attempts = 3,
  }) async {
    for (var attempt = 1;; attempt++) {
      try {
        final json = await post(path, body);
        try {
          return parse(json);
        } on TypeError catch (e) {
          throw TtgException('Неожиданный формат ответа на $path: $e');
        }
      } on TtgException {
        if (attempt == attempts) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  /// Выполняет [load] для всех элементов, не больше [concurrency] запросов одновременно.
  static Future<List<R>> mapConcurrently<T, R>(
    List<T> items,
    Future<R> Function(T item) load, {
    int concurrency = 6,
  }) async {
    final results = List<R?>.filled(items.length, null);
    var next = 0;
    Future<void> worker() async {
      while (next < items.length) {
        final index = next++;
        results[index] = await load(items[index]);
      }
    }

    await Future.wait(List.generate(concurrency, (_) => worker()));
    return results.cast<R>();
  }

  @disposeMethod
  void dispose() => _client.close();
}
