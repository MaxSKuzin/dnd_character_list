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

  @disposeMethod
  void dispose() => _client.close();
}
