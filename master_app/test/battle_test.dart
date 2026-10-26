import 'dart:convert';
import 'dart:math';

import 'package:dnd_master/domain/bestiary.dart';
import 'package:dnd_master/domain/models/battle.dart';
import 'package:dnd_master/domain/models/encounter.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter_test/flutter_test.dart';

SessionPlayer _player(String id, {int initiative = 2, int hits = 20, bool dead = false}) => SessionPlayer(
  id: id,
  isConnected: true,
  profile: CombatantProfile(
    name: id,
    classes: const [CombatClass(kind: 'bard', name: 'Бард', level: 1)],
    abilities: const {},
    savingThrows: const {},
    armorClass: 14,
    maxHits: 20,
    initiative: initiative,
    speed: 30,
    passivePerception: 10,
  ),
  state: CombatantState(currentHits: hits, isDead: dead),
);

final _random = Random(7);

const _ambush = Encounter(
  id: 'ambush',
  name: 'Засада',
  monsters: [
    EncounterMonster(template: Bestiary.goblin, count: 2),
    EncounterMonster(template: Bestiary.bugbear, count: 1),
  ],
);

void main() {
  test('хиты бестиария — средние по формуле костей, как в статблоках', () {
    const expected = {
      'goblin': 7,
      'hobgoblin': 11,
      'bugbear': 27,
      'kobold': 5,
      'bandit': 11,
      'orc': 15,
      'skeleton': 13,
      'zombie': 22,
      'wolf': 11,
      'giant_rat': 7,
    };
    expect({for (final m in Bestiary.monsters) m.id: m.averageHits}, expected);
    expect(Bestiary.goblin.initiative, 2);
    expect(Bestiary.zombie.initiative, -2);
    expect(Bestiary.kobold.hitDice.toString(), '2к6 − 2');
  });

  test('ситуация сохраняется и разбирается вместе со статблоками', () {
    final restored = Encounter.fromJson(jsonDecode(jsonEncode(_ambush.toJson())));
    expect(restored.monsters.map((e) => e.template.id), ['goblin', 'bugbear']);
    expect(restored.monsters.map((e) => e.count), [2, 1]);
    expect(restored.experience, 50 * 2 + 200);
    final bugbear = restored.monsters[1].template;
    expect(bugbear.hitDice.toString(), '5к8 + 5');
    expect(bugbear.abilities[Ability.strength], 15);
    expect(bugbear.armorNote, 'шкурный доспех, щит');
    expect(bugbear.traits.map((e) => e.name), ['Громила', 'Внезапное нападение']);
    expect(bugbear.actions.last.text, Bestiary.bugbear.actions.last.text);
  });

  test('бой из ситуации: монстры пронумерованы, одиночный — без номера', () {
    final battle = Battle.fromEncounter(_ambush);
    final names = battle.order(const []).map((e) => e.name);
    expect(names, ['Гоблин 1', 'Гоблин 2', 'Багбир']);
    expect(battle.monsters.map((e) => e.currentHits), [7, 7, 27]);

    final more = battle.addMonster(Bestiary.goblin);
    expect(more.monsters.last.number, 3);
    expect(more.monsters.map((e) => e.id).toSet(), hasLength(4));
  });

  test('очередь: по инициативе, при равенстве по бонусу, без инициативы — в конце', () {
    final players = [_player('Лира', initiative: 3), _player('Торн', initiative: 0)];
    var battle = Battle.fromEncounter(_ambush);
    final goblin1 = battle.monsters[0].id;
    final bugbear = battle.monsters[2].id;
    battle = battle
        .setInitiative('Торн', 15, _random)
        .setInitiative(goblin1, 15, _random)
        .setInitiative(bugbear, 20, _random);

    expect(battle.order(players).map((e) => e.name), ['Багбир', 'Гоблин 1', 'Торн', 'Лира', 'Гоблин 2']);
  });

  test('при равных инициативе и бонусе порядок случайный, но не меняется от перерисовки', () {
    final players = [
      for (final name in ['А', 'Б', 'В', 'Г', 'Д']) _player(name, initiative: 1),
    ];
    final orders = <String>{};
    for (var seed = 0; seed < 20; seed++) {
      final random = Random(seed);
      var battle = Battle.free();
      for (final player in players) {
        battle = battle.setInitiative(player.id, 12, random);
      }
      final order = battle.order(players).map((e) => e.id).join();
      // Повторная сортировка и повторный ввод того же результата порядок не меняют.
      expect(battle.order(players).map((e) => e.id).join(), order);
      expect(battle.setInitiative('А', 12, random).order(players).map((e) => e.id).join(), order);
      orders.add(order);
    }
    expect(orders.length, greaterThan(1));
  });

  test('приложение бросает инициативу только монстрам, уже брошенная не меняется', () {
    final players = [_player('Лира')];
    final battle = Battle.fromEncounter(_ambush).setInitiative('m0', 1, _random).rollMonsterInitiative(Random(1));

    expect(battle.initiative['m0'], 1);
    expect(battle.initiative.keys, containsAll(['m1', 'm2']));
    for (final id in ['m1', 'm2']) {
      expect(battle.initiative[id], inInclusiveRange(1 + 2, 20 + 2));
    }
    // Игроки бросают сами — их инициатива вводится мастером.
    expect(battle.initiative.containsKey('Лира'), isFalse);
    expect(battle.isStarted, isFalse);

    final started = battle.setInitiative('Лира', 25, _random).start(players);
    expect(started.round, 1);
    expect(started.currentId, 'Лира');
  });

  test('одинаковые монстры различаются метками и прозвищами', () {
    var battle = Battle.fromEncounter(_ambush).addMonster(Bestiary.goblin);
    final goblins = battle.monsters.where((e) => e.template.id == 'goblin').toList();
    expect(goblins.map((e) => e.marker), [MonsterMarker.red, MonsterMarker.blue, MonsterMarker.green]);
    // Одиночный багбир тоже с меткой, нумерация у каждого вида своя.
    expect(battle.monsters[2].marker, MonsterMarker.red);

    battle = battle.markMonster('m1', marker: MonsterMarker.black, label: '  с луком ');
    expect(battle.monsters[1].marker, MonsterMarker.black);
    expect(battle.order(const []).map((e) => e.name), contains('Гоблин 2 «с луком»'));

    battle = battle.markMonster('m1', marker: MonsterMarker.black, label: ' ');
    expect(battle.monsters[1].label, isNull);
  });

  test('ходы: выбывшие монстры пропускаются, игрок с 0 хитов ходит, после последнего — новый раунд', () {
    final players = [_player('Лира', hits: 0), _player('Мёртвый', dead: true)];
    var battle = Battle.fromEncounter(_ambush)
        .setInitiative('Лира', 20, _random)
        .setInitiative('Мёртвый', 19, _random)
        .setInitiative('m0', 18, _random)
        .setInitiative('m1', 17, _random)
        .setInitiative('m2', 16, _random)
        .changeMonsterHits('m1', -100)
        .start(players);

    final turns = <String>[];
    for (var i = 0; i < 4; i++) {
      turns.add('${battle.round}:${battle.currentId}');
      battle = battle.nextTurn(players);
    }
    expect(turns, ['1:Лира', '1:m0', '1:m2', '2:Лира']);

    // После цикла ход уже у m0 второго раунда.
    battle = battle.previousTurn(players);
    expect('${battle.round}:${battle.currentId}', '2:Лира');
    battle = battle.previousTurn(players);
    expect('${battle.round}:${battle.currentId}', '1:m2');
  });

  test('хиты монстра не выходят за 0 и максимум; удалённый монстр передаёт ход', () {
    var battle = Battle.fromEncounter(_ambush).changeMonsterHits('m0', -3);
    expect(battle.monsters[0].currentHits, 4);
    battle = battle.changeMonsterHits('m0', 100);
    expect(battle.monsters[0].currentHits, 7);

    battle = battle.setInitiative('m0', 10, _random).setInitiative('m1', 5, _random).start(const []);
    expect(battle.currentId, 'm0');
    battle = battle.removeMonster('m0', const []);
    expect(battle.currentId, 'm1');
    expect(battle.initiative.containsKey('m0'), isFalse);
  });

  test('конец боя сбрасывает инициативу и раунды, хиты монстров остаются', () {
    final battle = Battle.fromEncounter(
      _ambush,
    ).changeMonsterHits('m2', -10).rollMonsterInitiative(Random(1)).start(const []).finish();
    expect(battle.isStarted, isFalse);
    expect(battle.initiative, isEmpty);
    expect(battle.monsters[2].currentHits, 17);
  });

  test('эффекты: длительность уменьшается в конце хода участника, истёкшие снимаются', () {
    final players = [_player('Лира')];
    var battle = Battle.fromEncounter(_ambush)
        .setInitiative('Лира', 20, _random)
        .setInitiative('m0', 15, _random)
        .setInitiative('m1', 10, _random)
        .setInitiative('m2', 5, _random)
        .addStatus('Лира', title: 'Удивлён', description: 'Ты отказываешься биться', turns: 2)
        .addStatus('Лира', condition: Condition.poisoned)
        .addStatus('m0', condition: Condition.prone, turns: 1)
        .start(players);

    String labels(String id) =>
        battle.order(players).firstWhere((e) => e.id == id).statuses.map((e) => e.label).join(', ');
    expect(labels('Лира'), 'Удивлён · 2 хода, Отравлен');

    battle = battle.nextTurn(players); // ход Лиры закончился
    expect(labels('Лира'), 'Удивлён · 1 ход, Отравлен');
    // Эффект гоблина не тронут: его ход ещё не закончился.
    expect(labels('m0'), 'Сбит с ног · 1 ход');

    battle = battle.nextTurn(players); // ход гоблина закончился
    expect(labels('m0'), isEmpty);
    expect(battle.statuses.containsKey('m0'), isFalse);

    battle = battle.nextTurn(players).nextTurn(players).nextTurn(players); // снова ход Лиры закончился
    expect(labels('Лира'), 'Отравлен');

    final snapshot = battle.snapshot(players)!;
    expect(snapshot.entries.firstWhere((e) => e.id == 'Лира').statuses.single.condition, Condition.poisoned);

    final poisonId = battle.statuses['Лира']!.single.id;
    battle = battle.removeStatus('Лира', poisonId);
    expect(battle.statuses, isEmpty);
  });
}
