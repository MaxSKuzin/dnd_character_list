import 'dart:convert';
import 'dart:io';

import 'package:dnd_character_list/data/ttg/ttg_client.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// Дисковый кэш данных ttg.club, уже переведённых в модели приложения.
///
/// Свежие данные (моложе `ttl`) берутся из кэша; иначе загружаются заново, а при
/// недоступности сайта используется устаревший кэш.
@lazySingleton
class TtgCache {
  final Future<Directory> Function() _directory;

  TtgCache({@ignoreParam Future<Directory> Function()? directory})
      : _directory = directory ?? getApplicationSupportDirectory;

  Future<T> load<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() fetch,
    required Object? Function(T value) toJson,
    required T Function(Object? json) fromJson,
  }) async {
    final file = await this.file(key);
    (DateTime, T)? cached;
    if (await file.exists()) {
      try {
        final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        cached = (DateTime.parse(json['savedAt']), fromJson(json['data']));
      } catch (_) {
        // Битый или устаревший по формату кэш просто загружаем заново.
      }
    }
    if (cached != null && DateTime.now().difference(cached.$1) < ttl) return cached.$2;

    try {
      final value = await fetch();
      await file.writeAsString(jsonEncode({'savedAt': DateTime.now().toIso8601String(), 'data': toJson(value)}));
      return value;
    } on TtgException {
      if (cached != null) return cached.$2;
      rethrow;
    }
  }

  /// Файл кэша; символы, недопустимые в имени файла (апострофы и запятые в slug), заменяются.
  Future<File> file(String key) async {
    final directory = await _directory();
    final file = File('${directory.path}/ttg/${key.replaceAll(RegExp(r"[^\w/-]"), '_')}.json');
    await file.parent.create(recursive: true);
    return file;
  }
}
