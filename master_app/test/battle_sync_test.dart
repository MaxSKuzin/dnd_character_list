import 'package:dnd_master/data/master_session_source.dart';
import 'package:dnd_master/domain/bestiary.dart';
import 'package:dnd_master/domain/bloc/battle_cubit.dart';
import 'package:dnd_master/domain/models/battle.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter_test/flutter_test.dart';

const _profile = CombatantProfile(
  name: 'Лира',
  classes: [CombatClass(kind: 'bard', name: 'Бард', level: 1)],
  abilities: {},
  savingThrows: {},
  armorClass: 13,
  maxHits: 9,
  initiative: 2,
  speed: 30,
  passivePerception: 10,
);

void main() {
  late MasterSessionSource source;
  late BattleCubit cubit;
  late SessionClient client;

  setUp(() async {
    final host = SessionHost();
    source = MasterSessionSource(host: host);
    await source.start('Пещера');
    cubit = BattleCubit(source);
    client = SessionClient();
    final joined = cubit.stream.firstWhere((e) => e.players.isNotEmpty).timeout(const Duration(seconds: 5));
    await client.connect(
      SessionInfo(name: 'Пещера', host: '127.0.0.1', port: host.port!),
      playerId: 'p1',
      profile: _profile,
      state: const CombatantState(currentHits: 9),
    );
    await joined;
  });

  tearDown(() async {
    await client.dispose();
    await cubit.close();
    await source.stop();
  });

  Future<BattleSnapshot?> nextBattle(bool Function(BattleSnapshot?) test) =>
      client.battleStream.firstWhere(test).timeout(const Duration(seconds: 5));

  test('игрок дарит мастеру букет — мастер узнаёт, от кого', () async {
    final flowers = source.reactions.first.timeout(const Duration(seconds: 5));
    expect(client.react(Reaction.flowers), isTrue);
    expect(await flowers, (from: 'Лира', reaction: Reaction.flowers));
  });

  test('мастер кидает в игрока какашкой — игрок её получает, бой не меняется', () async {
    final before = cubit.state.active;
    final poop = client.reactions.first.timeout(const Duration(seconds: 5));
    expect(cubit.react('p1', Reaction.poop), isTrue);
    expect(await poop, (from: 'Мастер', reaction: Reaction.poop));
    expect(cubit.state.active, same(before));
    expect(cubit.react('нет такого', Reaction.poop), isFalse);
  });

  test('игрок вводит инициативу у себя — она в очереди мастера', () async {
    final received = cubit.stream
        .firstWhere((e) => e.active.initiative['p1'] == 14)
        .timeout(const Duration(seconds: 5));
    expect(client.sendInitiative(14), isTrue);
    await received;
  });

  test('игроки видят очередь и ход без хитов и прозвищ монстров, конец боя убирает очередь', () async {
    cubit
      ..addMonster(Bestiary.goblin, count: 2)
      ..markMonster('m1', marker: MonsterMarker.black, label: 'вожак')
      ..setInitiative('p1', 30);

    final started = nextBattle((e) => e != null);
    cubit.start();
    final battle = (await started)!;
    expect(battle.round, 1);
    expect(battle.currentId, 'p1');
    expect(battle.entries.first.name, 'Лира');
    expect(battle.entries.map((e) => e.name), unorderedEquals(['Лира', 'Гоблин 1', 'Гоблин 2']));
    final leader = battle.entries.firstWhere((e) => e.id == 'm1');
    expect(leader.name, 'Гоблин 2');
    expect(leader.marker, 'black');
    expect(leader.toJson().keys, isNot(contains('hits')));

    final moved = nextBattle((e) => e?.currentId != 'p1');
    cubit.nextTurn();
    expect((await moved)!.current!.isPlayer, isFalse);

    final ended = nextBattle((e) => e == null);
    cubit.finish();
    await ended;
  });

  test('мастер просит бросить инициативу только тех, у кого её нет', () async {
    final requested = client.initiativeRequests.first.timeout(const Duration(seconds: 5));
    cubit.requestInitiative();
    await requested;

    cubit.setInitiative('p1', 10);
    var asked = false;
    final subscription = client.initiativeRequests.listen((_) => asked = true);
    cubit.requestInitiative();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await subscription.cancel();
    expect(asked, isFalse);
  });

  test('мастер наносит урон игроку и ставит ему эффекты; истёкший эффект уходит с телефона', () async {
    final damage = client.hitsChanges.first.timeout(const Duration(seconds: 5));
    final player = cubit.state.order.whereType<PlayerCombatant>().single;
    expect(cubit.changeHits(player, -4), isTrue);
    expect(await damage, -4);

    final surprised = client.statusesStream.firstWhere((e) => e.isNotEmpty).timeout(const Duration(seconds: 5));
    cubit
      ..addMonster(Bestiary.goblin)
      ..setInitiative('p1', 20)
      ..setInitiative('m0', 1)
      ..addStatus('p1', title: 'Удивлён', description: 'Ты отказываешься биться', turns: 1)
      ..start();
    final status = (await surprised).single;
    expect(status.label, 'Удивлён · 1 ход');
    expect(status.description, 'Ты отказываешься биться');

    final expired = client.statusesStream.firstWhere((e) => e.isEmpty).timeout(const Duration(seconds: 5));
    cubit.nextTurn();
    await expired;
  });

  test('игрок не на связи — урон не отправлен', () async {
    final player = cubit.state.order.whereType<PlayerCombatant>().single;
    final left = cubit.stream.firstWhere((e) => !e.players.single.isConnected).timeout(const Duration(seconds: 5));
    await client.disconnect();
    await left;
    expect(cubit.changeHits(cubit.state.order.whereType<PlayerCombatant>().single, -4), isFalse);
    expect(player.id, 'p1');
  });

  test('игрок в нокауте виден всем в очереди, мастер приводит его в чувство', () async {
    final knockedOut = cubit.stream
        .firstWhere((e) => e.players.single.state.isKnockedOut)
        .timeout(const Duration(seconds: 5));
    client.update(state: const CombatantState(currentHits: 1, isKnockedOut: true));
    await knockedOut;

    final shown = nextBattle((e) => e?.entries.single.isKnockedOut ?? false);
    cubit
      ..setInitiative('p1', 10)
      ..start();
    await shown;

    final revived = client.revivals.first.timeout(const Duration(seconds: 5));
    expect(cubit.revive('p1'), isTrue);
    expect(await revived, 'Мастер');
  });
}
