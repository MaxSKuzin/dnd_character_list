import 'package:dnd_session/dnd_session.dart';
import 'package:flutter_test/flutter_test.dart';

const _profile = CombatantProfile(
  name: 'Лира',
  classes: [CombatClass(kind: 'bard', name: 'Бард', level: 3)],
  abilities: {
    Ability.strength: 8,
    Ability.dexterity: 14,
    Ability.constitution: 12,
    Ability.intelligence: 10,
    Ability.wisdom: 13,
    Ability.charisma: 17,
  },
  savingThrows: {
    Ability.strength: -1,
    Ability.dexterity: 4,
    Ability.constitution: 1,
    Ability.intelligence: 0,
    Ability.wisdom: 1,
    Ability.charisma: 5,
  },
  armorClass: 13,
  maxHits: 20,
  initiative: 3,
  speed: 30,
  passivePerception: 11,
);

const _state = CombatantState(
  currentHits: 20,
  spellSlots: {1: CombatCounter(current: 4, max: 4), 2: CombatCounter(current: 2, max: 2)},
  counters: {'Вдохновение': CombatCounter(current: 3, max: 3)},
);

Future<List<SessionPlayer>> _nextPlayers(SessionHost host, bool Function(List<SessionPlayer>) test) =>
    host.playersStream.firstWhere(test).timeout(const Duration(seconds: 5));

Future<SessionStatus> _nextStatus(SessionClient client, bool Function(SessionStatus) test) =>
    client.statusStream.firstWhere(test).timeout(const Duration(seconds: 5));

void main() {
  late SessionHost host;
  late SessionClient client;
  late SessionInfo session;

  setUp(() async {
    host = SessionHost();
    await host.start(name: 'Пещера');
    session = SessionInfo(name: 'Пещера', host: '127.0.0.1', port: host.port!);
    client = SessionClient();
  });

  tearDown(() async {
    await client.dispose();
    await host.dispose();
  });

  test('сообщения кодируются и разбираются без потерь', () {
    const join = JoinMessage(playerId: 'p1', profile: _profile, state: _state);
    final decoded = SessionMessage.decode(join.encode()) as JoinMessage;
    expect(decoded.playerId, 'p1');
    expect(decoded.profile, _profile);
    expect(decoded.state, _state);
    expect(decoded.state.counters['Вдохновение']!.max, 3);
    expect(SessionMessage.decode('{"type":"unknown"}'), isNull);
    expect(SessionMessage.decode('not json'), isNull);
  });

  test('игрок подключается, мастер видит его данные и изменения хитов', () async {
    final joined = _nextPlayers(host, (players) => players.isNotEmpty);
    await client.connect(session, playerId: 'p1', profile: _profile, state: _state);

    expect(client.status, isA<SessionConnected>().having((e) => e.sessionName, 'sessionName', 'Пещера'));
    final player = (await joined).single;
    expect(player.profile.name, 'Лира');
    expect(player.profile.level, 3);
    expect(player.isConnected, isTrue);

    final damaged = _nextPlayers(host, (players) => players.single.state.currentHits == 12);
    client.update(state: const CombatantState(currentHits: 12));
    expect((await damaged).single.profile.armorClass, 13);
  });

  test('после отключения игрок остаётся у мастера офлайн', () async {
    await client.connect(session, playerId: 'p1', profile: _profile, state: _state);
    final left = _nextPlayers(host, (players) => players.isNotEmpty && !players.single.isConnected);
    await client.disconnect();
    expect((await left).single.state.currentHits, 20);
  });

  test('повторное подключение того же игрока не создаёт новую запись', () async {
    await client.connect(session, playerId: 'p1', profile: _profile, state: _state);
    final second = SessionClient();
    addTearDown(second.dispose);
    final updated = _nextPlayers(host, (players) => players.single.state.currentHits == 5);
    await second.connect(session, playerId: 'p1', profile: _profile, state: const CombatantState(currentHits: 5));
    expect((await updated).single.isConnected, isTrue);
    expect(host.players, hasLength(1));
  });

  test('мастер завершает сессию — игрок отключается с причиной и не переподключается', () async {
    await client.connect(session, playerId: 'p1', profile: _profile, state: _state);
    final closed = _nextStatus(client, (status) => status is SessionDisconnected);
    await host.stop();
    expect((await closed as SessionDisconnected).reason, 'Мастер завершил сессию');
  });

  test('недоступный адрес — отключено с причиной', () async {
    final port = host.port!;
    await host.stop();
    await client.connect(
      SessionInfo(name: 'нет', host: '127.0.0.1', port: port),
      playerId: 'p1',
      profile: _profile,
      state: _state,
    );
    expect(client.status, isA<SessionDisconnected>().having((e) => e.reason, 'reason', isNotNull));
  });

  test('мастер показывает бой подключённым и новым игрокам, конец боя убирает его', () async {
    await client.connect(session, playerId: 'p1', profile: _profile, state: _state);
    const battle = BattleSnapshot(
      round: 1,
      currentId: 'm0',
      entries: [
        BattleEntry(id: 'm0', name: 'Гоблин 1', isPlayer: false, initiative: 17, marker: 'red'),
        BattleEntry(id: 'p1', name: 'Лира', isPlayer: true, initiative: 12),
      ],
    );
    final shown = client.battleStream.firstWhere((e) => e != null).timeout(const Duration(seconds: 5));
    host.setBattle(battle);
    final received = (await shown)!;
    expect(received.current!.name, 'Гоблин 1');
    expect(received.next!.id, 'p1');
    expect(received.entries.first.marker, 'red');

    // Игрок, подключившийся посреди боя, сразу видит очередь.
    final late = SessionClient();
    addTearDown(late.dispose);
    final lateShown = late.battleStream.firstWhere((e) => e != null).timeout(const Duration(seconds: 5));
    await late.connect(session, playerId: 'p2', profile: _profile, state: _state);
    expect((await lateShown)!.round, 1);

    final ended = client.battleStream.firstWhere((e) => e == null).timeout(const Duration(seconds: 5));
    host.setBattle(null);
    await ended;
    expect(client.battle, isNull);
  });

  test('игрок отправляет инициативу, мастер просит её бросить', () async {
    await client.connect(session, playerId: 'p1', profile: _profile, state: _state);

    final requested = client.initiativeRequests.first.timeout(const Duration(seconds: 5));
    host.requestInitiative(['p1', 'нет такого']);
    await requested;

    final initiative = host.initiatives.first.timeout(const Duration(seconds: 5));
    expect(client.sendInitiative(15), isTrue);
    expect(await initiative, (playerId: 'p1', value: 15));

    await client.disconnect();
    expect(client.sendInitiative(15), isFalse);
  });

  test('мастер наносит урон и ставит эффекты; эффекты приходят снова после переподключения', () async {
    await client.connect(session, playerId: 'p1', profile: _profile, state: _state);

    final damage = client.hitsChanges.first.timeout(const Duration(seconds: 5));
    expect(host.changeHits('p1', -6), isTrue);
    expect(await damage, -6);
    expect(host.changeHits('нет такого', -6), isFalse);

    const statuses = [
      StatusEffect.condition(Condition.poisoned, id: 's1'),
      StatusEffect.custom(id: 's2', title: 'Удивлён', description: 'Ты отказываешься биться', turns: 2),
    ];
    final received = client.statusesStream.firstWhere((e) => e.isNotEmpty).timeout(const Duration(seconds: 5));
    host.setStatuses('p1', statuses);
    expect(await received, statuses);
    expect(client.statuses[1].description, 'Ты отказываешься биться');

    await client.disconnect();
    expect(client.statuses, isEmpty);
    final again = client.statusesStream.firstWhere((e) => e.isNotEmpty).timeout(const Duration(seconds: 5));
    await client.connect(session, playerId: 'p1', profile: _profile, state: _state);
    expect(await again, statuses);

    final cleared = client.statusesStream.firstWhere((e) => e.isEmpty).timeout(const Duration(seconds: 5));
    host.setStatuses('p1', const []);
    await cleared;
  });

  test('эффекты: описание состояния из книги, счёт ходов, неизвестные пропускаются', () {
    const poisoned = StatusEffect.condition(Condition.poisoned, id: 's1', turns: 2);
    expect(poisoned.title, 'Отравлен');
    expect(poisoned.description, startsWith('Помеха'));
    expect(poisoned.afterTurn()!.turns, 1);
    expect(poisoned.afterTurn()!.afterTurn(), isNull);
    expect(poisoned.label, 'Отравлен · 2 хода');
    expect([1, 2, 5, 11, 21, 22, 112].map(turnsLabel), [
      '1 ход',
      '2 хода',
      '5 ходов',
      '11 ходов',
      '21 ход',
      '22 хода',
      '112 ходов',
    ]);
    const endless = StatusEffect.custom(id: 's2', title: 'Проклят');
    expect(endless.afterTurn(), endless);

    const entry = BattleEntry(id: 'm0', name: 'Гоблин', isPlayer: false, statuses: [poisoned]);
    expect(BattleEntry.fromJson(entry.toJson()).statuses, [poisoned]);
    expect(
      StatusEffect.listFromJson([
        {'id': 'x', 'condition': 'exhaustion'},
        {'id': 'y', 'condition': 'exhaustion', 'title': 'Истощение 2'},
      ]).map((e) => e.title),
      ['Истощение 2'],
    );
  });

  test('союзник приводит в чувство только персонажа в нокауте, мастер — тоже', () async {
    const knockedOut = CombatantState(currentHits: 1, isKnockedOut: true);
    expect(CombatantState.fromJson(knockedOut.toJson()).isKnockedOut, isTrue);

    final ally = SessionClient();
    addTearDown(ally.dispose);
    final joined = _nextPlayers(host, (players) => players.length == 2);
    await client.connect(session, playerId: 'p1', profile: _profile, state: knockedOut);
    await ally.connect(session, playerId: 'p2', profile: _profileNamed('Торн'), state: _state);
    await joined;

    final revived = client.revivals.first.timeout(const Duration(seconds: 5));
    expect(ally.revive('p1'), isTrue);
    expect(await revived, 'Торн');

    // Персонажа не в нокауте привести в чувство нельзя — сообщение не доходит.
    var allyRevived = false;
    final subscription = ally.revivals.listen((_) => allyRevived = true);
    client.revive('p2');
    expect(host.revive('p1', by: 'Мастер'), isTrue);
    expect(await client.revivals.first.timeout(const Duration(seconds: 5)), 'Мастер');
    await subscription.cancel();
    expect(allyRevived, isFalse);
  });
}

CombatantProfile _profileNamed(String name) => CombatantProfile(
  name: name,
  classes: _profile.classes,
  abilities: _profile.abilities,
  savingThrows: _profile.savingThrows,
  armorClass: _profile.armorClass,
  maxHits: _profile.maxHits,
  initiative: _profile.initiative,
  speed: _profile.speed,
  passivePerception: _profile.passivePerception,
);
