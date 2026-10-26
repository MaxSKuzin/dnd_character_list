import 'dart:convert';
import 'dart:io';

import 'package:dnd_master/data/ttg/ttg_bestiary.dart';
import 'package:dnd_master/data/ttg/ttg_monster_mapper.dart';
import 'package:dnd_master/domain/models/monster.dart';
import 'package:dnd_master/presentation/monsters/monster_picker.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Сокращённые копии реальных ответов api ttg.club из `test/fixtures/ttg/`.
String _fixture(String name) => File('test/fixtures/ttg/$name.json').readAsStringSync();

Map<String, dynamic> _monster(String name) => jsonDecode(_fixture('monster_$name'));

/// Бестиарий на фикстурах без http: экран выбора проверяется отдельно от клиента.
class _FakeBestiary extends TtgBestiary {
  @override
  Future<List<MonsterSummary>> list() async => TtgMonsterMapper.summaries(jsonDecode(_fixture('bestiary_list')));

  @override
  Future<MonsterTemplate> monster(String url) async => TtgMonsterMapper.monster(_monster(url.split('/').last));
}

/// Api бестиария на фикстурах; `failures` — сколько первых запросов ответят ошибкой.
MockClient _api({List<String>? requests, int failures = 0}) => MockClient((request) async {
  requests?.add(request.url.path);
  if (failures-- > 0) return http.Response('', 502);
  final body = switch (request.url.path) {
    '/api/v1/bestiary' => _fixture('bestiary_list'),
    '/api/v1/bestiary/goblin' => _fixture('monster_goblin'),
    _ => null,
  };
  return body == null
      ? http.Response('', 404)
      : http.Response.bytes(utf8.encode(body), 200, headers: {'content-type': 'application/json'});
});

void main() {
  test('статблок: защита, хиты, характеристики, действия без html', () {
    final goblin = TtgMonsterMapper.monster(_monster('goblin'));
    expect(goblin.id, '/bestiary/goblin');
    expect(goblin.name, 'Гоблин');
    expect(goblin.kind, 'Маленький гуманоид (гоблиноид), нейтрально-злой');
    expect(goblin.challenge, '1/4');
    expect(goblin.experience, 50);
    expect(goblin.armorClass, 15);
    expect(goblin.armorNote, 'кожаный доспех, щит');
    expect(goblin.hitDice.toString(), '2к6');
    expect(goblin.averageHits, 7);
    expect(goblin.speed, 30);
    expect(goblin.speedNote, isNull);
    expect(goblin.abilities[Ability.dexterity], 14);
    expect(goblin.abilities[Ability.wisdom], 8);
    expect(goblin.initiative, 2);
    expect(goblin.passivePerception, 9);
    expect(goblin.properties.map((e) => '${e.name}: ${e.text}'), [
      'Навыки: Скрытность +6',
      'Чувства: тёмное зрение 60 фт.',
      'Языки: Гоблинский, Общий',
    ]);
    expect(goblin.traits.single.name, 'Ловкий побег');
    expect(goblin.traits.single.text, contains('совершать действие Засада или Отход.'));
    expect(
      goblin.actions.first.text,
      'Рукопашная атака оружием: +4 к попаданию, досягаемость 5 фт., одна цель. '
      'Попадание: 5 (1к6 + 2) рубящего урона.',
    );
  });

  test('статблок: отрицательный бонус хитов, другие скорости, спасброски, реакции и легендарные действия', () {
    expect(TtgMonsterMapper.monster(_monster('kobold')).hitDice.toString(), '2к6 − 2');

    final dragon = TtgMonsterMapper.monster(_monster('adult_red_dragon'));
    expect(dragon.kind, startsWith('Огромный дракон (цветной)'));
    expect(dragon.hitDice.toString(), '19к12 + 133');
    expect(dragon.averageHits, 256);
    expect(dragon.speed, 40);
    expect(dragon.speedNote, 'летая 80 фт., лазая 40 фт.');
    expect(dragon.properties.first.text, 'Лов +6, Тел +13, Мдр +7, Хар +11');
    expect(dragon.properties.map((e) => e.name), contains('Иммунитет к урону'));
    expect(dragon.actions.first.name, 'Мультиатака');
    expect(dragon.legendaryActions.map((e) => e.name), contains('Атака хвостом'));

    expect(TtgMonsterMapper.monster(_monster('knight')).reactions.single.name, 'Парирование');
  });

  test('статблок с сайта сохраняется в ситуации и разбирается обратно', () {
    final dragon = TtgMonsterMapper.monster(_monster('adult_red_dragon'));
    final restored = MonsterTemplate.fromJson(jsonDecode(jsonEncode(dragon.toJson())));
    expect(jsonEncode(restored.toJson()), jsonEncode(dragon.toJson()));
  });

  test('текст: абзацы с новой строки, кубики формулой, без английских названий', () {
    expect(
      TtgMonsterMapper.plainText(
        '<p>Через (<dice-roller formula="1к10"/>) дней.</p><p>Заговоры: луч холода [ray of frost], '
        '<a href="/spells/mage_hand">волшебная рука [mage hand]</a>&nbsp;&mdash; всегда.</p>',
      ),
      'Через (1к10) дней.\nЗаговоры: луч холода, волшебная рука — всегда.',
    );
  });

  test('скорость только полётом: «летая 20 фт. (парит)»', () {
    final json = _monster('goblin')
      ..['speed'] = [
        {'value': 0},
        {'name': 'летая', 'value': 20, 'additional': 'парит'},
      ];
    final monster = TtgMonsterMapper.monster(json);
    expect(monster.speed, 0);
    expect(monster.speedNote, 'летая 20 фт. (парит)');
  });

  test('хиты без формулы — постоянное значение', () {
    final json = _monster('goblin')..['hits'] = {'average': 1};
    final monster = TtgMonsterMapper.monster(json);
    expect(monster.averageHits, 1);
    expect(monster.hitDice.toString(), '1');
  });

  test('поиск в списке: русское и английское название, без учёта регистра и «ё»', () {
    final list = TtgMonsterMapper.summaries(jsonDecode(_fixture('bestiary_list')));
    List<String> find(String query) => list.where((e) => e.matches(query)).map((e) => e.name).toList();
    expect(find('ГОБЛИН'), ['Гоблин', 'Хобгоблин', 'Босс гоблинов']);
    expect(find('owlbear'), ['Совомед']);
    final homebrew = list.firstWhere((e) => e.url == '/bestiary/forest_dragon');
    expect(homebrew.isOfficial, isFalse);
    expect(list.firstWhere((e) => e.url == '/bestiary/goblin').book, 'MM');
  });

  test('список загружается один раз, статблок кэшируется, ошибки не запоминаются', () async {
    final requests = <String>[];
    final bestiary = TtgBestiary(client: _api(requests: requests, failures: 3));
    await expectLater(bestiary.list(), throwsA(isA<TtgException>()));
    expect(requests, hasLength(3));

    expect(await bestiary.list(), hasLength(6));
    await bestiary.list();
    final goblin = await bestiary.monster('/bestiary/goblin');
    expect(identical(await bestiary.monster('/bestiary/goblin'), goblin), isTrue);
    expect(requests.skip(3), ['/api/v1/bestiary', '/api/v1/bestiary/goblin']);
  });

  testWidgets('выбор: встроенный бестиарий и поиск на ttg.club', (tester) async {
    // Встроенный бестиарий и результаты с сайта помещаются на экран целиком.
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    MonsterTemplate? picked;
    final bestiary = _FakeBestiary();
    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => picked = await Navigator.push(
                  context,
                  MaterialPageRoute<MonsterTemplate>(
                    builder: (_) => Scaffold(body: MonsterPicker(bestiary: bestiary)),
                  ),
                ),
                child: const Text('Добавить'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle();
    expect(find.text('Введите название, чтобы найти монстра на сайте'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'гоб');
    await tester.pumpAndSettle();
    // Встроенный «Гоблин» и он же с сайта, хобгоблин, босс гоблинов.
    expect(find.text('Гоблин'), findsNWidgets(2));
    expect(find.text('Босс гоблинов'), findsOneWidget);
    expect(find.text('ПО 1/4 · гуманоид · MM'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'дракон');
    await tester.pumpAndSettle();
    expect(find.text('Взрослый красный дракон'), findsOneWidget);
    expect(find.textContaining('неофициальный'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'гоблин');
    await tester.pumpAndSettle();
    await tester.tap(find.text('ПО 1/4 · гуманоид · MM'));
    await tester.pumpAndSettle();
    expect(picked?.id, '/bestiary/goblin');
    expect(picked?.traits.single.name, 'Ловкий побег');
  });
}
