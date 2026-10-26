import 'dart:io';

import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/data/ttg/ttg_client.dart';
import 'package:dnd_character_list/data/ttg/ttg_spells_mapper.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ttg_fixtures.dart';

Spell _spell(int id) => Spell(
      link: '/spells/spell_$id',
      name: 'Заклинание $id',
      nameEn: 'Spell $id',
      slot: SpellSlot.level1,
      school: 'воплощение',
      isConcentration: false,
      isRitual: false,
      components: const [SpellComponent.verbal],
      allowedSpecializations: const [],
    );

Map<String, Object?> _details(String path) => {
      ...ttgFixture('spell_bless'),
      'url': path,
      'description': '<p>Описание $path</p>',
    };

/// Классы, у которых в фикстуре есть заклинания: остальные фильтры возвращают пустой список.
const _classSpells = {
  ClassKind.sorcerer: ['/spells/fire_bolt', '/spells/grease'],
  ClassKind.wizard: ['/spells/fire_bolt', '/spells/grease', '/spells/magic_mouth'],
  ClassKind.cliric: ['/spells/bless', '/spells/thaumaturgy'],
};

class _FakeClient extends TtgClient {
  final requests = <String, int>{};

  /// Сколько первых запросов к пути завершатся ошибкой сервера.
  final Map<String, int> failures;

  _FakeClient({this.failures = const {}});

  @override
  Future<Object?> post(String path, [Map<String, Object?> body = const {}]) async {
    final count = requests[path] = (requests[path] ?? 0) + 1;
    if (count <= (failures[path] ?? 0)) throw const TtgException('HTTP 500');
    if (path != '/spells') return _details(path);
    final filter = body['filter'] as Map?;
    if (filter == null) return ttgJson('spells');
    final classKind = ClassKind.values.firstWhere((e) => '${e.ttgSpellsFilterId}' == (filter['class'] as List).single);
    return [
      for (final link in _classSpells[classKind] ?? const <String>[]) {'url': link},
    ];
  }
}

void main() {
  late Directory cacheDirectory;

  setUp(() async => cacheDirectory = await Directory.systemTemp.createTemp('spells_repository_test'));
  tearDown(() => cacheDirectory.delete(recursive: true));

  SpellsRepository repository(TtgClient client) => SpellsRepository(
        client,
        TtgSpellsMapper(),
        cacheDirectory: () async => cacheDirectory,
      );

  test('loads official spells with class lists', () async {
    final client = _FakeClient();
    final spells = await repository(client).getSpells();

    // Заклинание из стороннего источника (MHH) не попадает в список.
    expect(spells.map((e) => e.link), isNot(contains('/spells/absolute_command')));
    final grease = spells.firstWhere((e) => e.link == '/spells/grease');
    expect(grease.allowedSpecializations, [ClassKind.wizard, ClassKind.sorcerer]);
    expect(grease.components, SpellComponent.values);
    expect(spells.firstWhere((e) => e.link == '/spells/magic_mouth').isRitual, isTrue);
    expect(spells.firstWhere((e) => e.link == '/spells/fire_bolt').slot, SpellSlot.conspiracy);
  });

  test('finds spell by link from descriptions in any case', () async {
    final spell = await repository(_FakeClient()).findByLink('/spells/Grease');
    expect(spell?.name, 'Скольжение');
  });

  test('maps details', () {
    final details = TtgSpellsMapper().mapDetails(ttgFixture('spell_bless'));
    expect(details.levelAndSchool, '1 уровень, очарование');
    expect(details.components, 'В, С, М (капля святой воды)');
    expect(details.castTime, '1 действие');
    // Шаман на сайте — homebrew.
    expect(details.classes, 'Жрец, Паладин');
    expect(details.descriptionHtml, contains('На больших уровнях'));
  });

  test('retries when server fails', () async {
    final client = _FakeClient(failures: {'/spells/spell_1': 2});

    final spell = await repository(client).withDetails(_spell(1));

    expect(spell.details?.descriptionHtml, contains('Описание /spells/spell_1'));
    expect(client.requests['/spells/spell_1'], 3);
  });

  test('loads all spells with details and caches them on disk', () async {
    final spells = List.generate(10, (index) => _spell(index + 1));
    final client = _FakeClient();

    final loaded = await repository(client).loadDetails(spells).toList();

    expect(loaded.map((e) => e.id).toSet(), spells.map((e) => e.id).toSet());
    expect(loaded.every((e) => e.details != null), isTrue);

    // Новый экземпляр репозитория берёт описания из дискового кэша без запросов.
    final offlineClient = _FakeClient();
    final cached = await repository(offlineClient).loadDetails(spells).toList();
    expect(cached.every((e) => e.details != null), isTrue);
    expect(offlineClient.requests, isEmpty);
  });

  test('keeps spell without details when server keeps failing', () async {
    final client = _FakeClient(failures: {'/spells/spell_2': 100});

    final loaded = await repository(client).loadDetails([_spell(1), _spell(2)]).toList();

    expect(loaded.firstWhere((e) => e.link == '/spells/spell_1').details, isNotNull);
    expect(loaded.firstWhere((e) => e.link == '/spells/spell_2').details, isNull);
  });
}
