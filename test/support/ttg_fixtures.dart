import 'dart:convert';
import 'dart:io';

/// Сокращённые копии реальных ответов api ttg.club из `test/fixtures/ttg/`.
Object? ttgJson(String name) => jsonDecode(File('test/fixtures/ttg/$name.json').readAsStringSync());

Map<String, dynamic> ttgFixture(String name) => ttgJson(name) as Map<String, dynamic>;
