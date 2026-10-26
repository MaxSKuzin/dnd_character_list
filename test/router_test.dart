import 'dart:io';

import 'package:dnd_character_list/router.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter_test/flutter_test.dart';

/// Маршруты, которые открываются в файлах потока: `SelectFightingStyleRoute(`.
Set<String> _routesUsedIn(List<String> paths) => {
      for (final path in paths)
        ...RegExp(r'\b([A-Z]\w+Route)\(').allMatches(File(path).readAsStringSync()).map((e) => e.group(1)!),
    };

Set<String> _childrenOf(String flow) =>
    AppRouter().routes.firstWhere((e) => e.name == flow).children!.routes.map((e) => e.name).toSet();

void main() {
  // Маршрут, которого нет среди дочерних маршрутов потока, падает при переходе: «Failed to navigate to …».
  test('create character steps open only routes of the create character flow', () {
    // Шаги следопыта 1 уровня открываются и при создании персонажа.
    final used = _routesUsedIn([
      'lib/presentation/create_character_flow/create_character_steps.dart',
      'lib/presentation/level_up_flow/ranger_steps.dart',
      'lib/presentation/level_up_flow/level_up_steps.dart',
    ]);

    expect(used, isNotEmpty);
    expect(_childrenOf(CreateCharacterRoute.name), containsAll(used));
  });

  test('level up steps open only routes of the level up flow', () {
    final files = Directory('lib/presentation/level_up_flow')
        .listSync()
        .whereType<File>()
        .map((e) => e.path)
        .where((e) => e.endsWith('.dart') && !e.endsWith('level_up_flow.dart'))
        .toList();
    final used = _routesUsedIn(files);

    expect(used, contains(SelectClassOptionsRoute.name));
    expect(_childrenOf(LevelUpFlowRoute.name), containsAll(used));
  });
}
