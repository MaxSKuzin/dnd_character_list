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
}
