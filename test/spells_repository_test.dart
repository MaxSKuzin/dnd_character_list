import 'dart:io';

import 'package:dnd_character_list/data/dnd_su/dnd_su_client.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_spells_parser.dart';
import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:flutter_test/flutter_test.dart';

Spell _spell(int id) => Spell(
      id: id,
      link: '/spells/$id-spell/',
      name: 'Заклинание $id',
      nameEn: 'Spell $id',
      slot: SpellSlot.level1,
      school: 'Воплощение',
      isConcentration: false,
      isRitual: false,
      components: const [SpellComponent.verbal],
      castTimeType: null,
      allowedSpecializations: const [],
      tceSpecializations: const [],
    );

String _page(int id) => '''
<div class="cards-wrapper"><div class="card__body" itemprop="articleBody"><ul class="params">
<li class="size-type-alignment">1 уровень, воплощение</li>
<li><strong>Время накладывания:</strong> 1 действие</li>
<li class="subsection desc"><div itemprop="description"><p>Описание $id</p></div></li>
</ul></div></div>
<section class="comments-block">комментарии</section>''';

/// Так сайт иногда отвечает: страница есть, а карточки заклинания в ней нет.
const _pageWithoutCard = '<div class="cards-wrapper"></div><section class="comments-block">комментарии</section>';

class _FakeClient extends DndSuClient {
  final requests = <String, int>{};

  /// Сколько первых запросов к странице вернут страницу без карточки.
  final Map<String, int> brokenResponses;

  _FakeClient({this.brokenResponses = const {}});

  @override
  Future<String> get(String path) async {
    final count = requests[path] = (requests[path] ?? 0) + 1;
    if (count <= (brokenResponses[path] ?? 0)) return _pageWithoutCard;
    return _page(Spell.idFromLink(path));
  }
}

void main() {
  late Directory cacheDirectory;

  setUp(() async => cacheDirectory = await Directory.systemTemp.createTemp('spells_repository_test'));
  tearDown(() => cacheDirectory.delete(recursive: true));

  SpellsRepository repository(DndSuClient client) => SpellsRepository(
        client,
        DndSuSpellsParser(),
        cacheDirectory: () async => cacheDirectory,
      );

  test('retries when site returns page without spell card', () async {
    final client = _FakeClient(brokenResponses: {'/spells/1-spell/': 2});

    final spell = await repository(client).withDetails(_spell(1));

    expect(spell.details?.descriptionHtml, '<p>Описание 1</p>');
    expect(client.requests['/spells/1-spell/'], 3);
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

  test('keeps spell without details when page stays broken', () async {
    final client = _FakeClient(brokenResponses: {'/spells/2-spell/': 100});

    final loaded = await repository(client).loadDetails([_spell(1), _spell(2)]).toList();

    expect(loaded.firstWhere((e) => e.id == 1).details, isNotNull);
    expect(loaded.firstWhere((e) => e.id == 2).details, isNull);
  });
}
