import 'package:dnd_master/data/encounters_repository.dart';
import 'package:dnd_master/data/master_session_source.dart';
import 'package:dnd_master/domain/bloc/battle_cubit.dart';
import 'package:dnd_master/domain/bloc/encounters_cubit.dart';
import 'package:dnd_master/presentation/session_screen.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  testWidgets('игроки не пропадают при переключении вкладок «Бой» и «Игроки»', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final encounters = EncountersRepository(await SharedPreferences.getInstance());
    final host = SessionHost();
    final source = MasterSessionSource(host: host);
    final client = SessionClient();

    await tester.runAsync(() => source.start('Пещера'));
    final battle = BattleCubit(source);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => EncountersCubit(encounters)),
          BlocProvider.value(value: battle),
        ],
        child: MaterialApp(home: SessionScreen(source: source)),
      ),
    );

    // Игрок подключается уже после того, как экран сессии построен.
    await tester.runAsync(() async {
      final joined = source.playersStream.firstWhere((e) => e.isNotEmpty);
      await client.connect(
        SessionInfo(name: 'Пещера', host: '127.0.0.1', port: host.port!),
        playerId: 'p1',
        profile: _profile,
        state: const CombatantState(currentHits: 9),
      );
      await joined;
    });
    await tester.pump();

    await tester.tap(find.text('Игроки'));
    await tester.pumpAndSettle();
    expect(find.text('Лира'), findsOneWidget);

    await tester.tap(find.text('Бой'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Игроки'));
    await tester.pumpAndSettle();
    expect(find.text('Лира'), findsOneWidget);

    await tester.runAsync(() async {
      await client.dispose();
      await battle.close();
      await source.stop();
    });
  });
}
