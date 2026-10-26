import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

class DndSuException implements Exception {
  final String message;

  const DndSuException(this.message);

  @override
  String toString() => 'DndSuException: $message';
}

/// Страница загрузилась, но в ней нет ожидаемых данных.
class DndSuMissingContentException extends DndSuException {
  const DndSuMissingContentException(super.message);
}

/// Загружает html-страницы dnd.su. У сайта нет api, поэтому данные достаются
/// из тех же страниц и фрагментов, которые подгружает браузер.
@lazySingleton
class DndSuClient {
  static const baseUrl = 'https://dnd.su';
  static const _timeout = Duration(seconds: 30);

  final http.Client _client = http.Client();

  static Uri resolve(String path) => Uri.parse(baseUrl).resolve(path);

  Future<String> get(String path) async {
    final http.Response response;
    try {
      response = await _client.get(
        resolve(path),
        headers: const {
          'User-Agent': 'Mozilla/5.0 (dnd_character_list)',
          'Accept': 'text/html',
        },
      ).timeout(_timeout);
    } on Exception catch (e) {
      throw DndSuException('Не удалось загрузить $path: $e');
    }
    if (response.statusCode != 200) {
      throw DndSuException('Не удалось загрузить $path: HTTP ${response.statusCode}');
    }
    return utf8.decode(response.bodyBytes);
  }

  /// Загружает и разбирает страницу. Сайт периодически отвечает страницей без основного
  /// содержимого, поэтому при ошибке загрузки или разбора пробуем ещё несколько раз.
  Future<T> getParsed<T>(String path, T Function(String body) parse, {int attempts = 3}) async {
    for (var attempt = 1;; attempt++) {
      try {
        return parse(await get(path));
      } on DndSuException {
        if (attempt == attempts) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  /// Выполняет [load] для всех элементов, не больше [concurrency] запросов одновременно.
  static Future<List<R>> mapConcurrently<T, R>(
    List<T> items,
    Future<R> Function(T item) load, {
    int concurrency = 4,
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
