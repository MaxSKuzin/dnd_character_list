import 'package:dnd_master/data/encounters_repository.dart';
import 'package:dnd_master/data/master_session_source.dart';
import 'package:dnd_master/domain/bestiary.dart';
import 'package:dnd_master/domain/bloc/battle_cubit.dart';
import 'package:dnd_master/domain/bloc/encounters_cubit.dart';
import 'package:dnd_master/domain/models/battle.dart';
import 'package:dnd_master/presentation/battle/battle_view.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late BattleCubit battle;

  Future<void> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final encounters = EncountersRepository(await SharedPreferences.getInstance());
    // Сессия не запущена: в бою только монстры.
    battle = BattleCubit(MasterSessionSource(host: SessionHost()));
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => EncountersCubit(encounters)),
          BlocProvider.value(value: battle),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const EncounterSwitcher(), actions: const [BattleMenu()]),
            body: const BattleView(),
          ),
        ),
      ),
    );
  }

  testWidgets('монстры добавляются, бой начинается и ходы переключаются', (tester) async {
    await pump(tester);
    expect(find.text('Свободный бой'), findsOneWidget);
    expect(find.text('Добавьте монстров или дождитесь игроков'), findsOneWidget);

    battle.addMonster(Bestiary.goblin, count: 2);
    await tester.pump();
    expect(find.text('Гоблин 1'), findsOneWidget);
    expect(find.text('Гоблин 2'), findsOneWidget);

    await tester.tap(find.text('Начать бой'));
    await tester.pump();
    expect(find.text('Раунд 1'), findsOneWidget);
    final first = battle.state.active.currentId;

    await tester.tap(find.text('Следующий ход'));
    await tester.pump();
    expect(battle.state.active.currentId, isNot(first));
  });

  testWidgets('в карточке монстра меняются метка и прозвище', (tester) async {
    await pump(tester);
    battle.addMonster(Bestiary.goblin, count: 2);
    await tester.pump();

    await tester.tap(find.text('Гоблин 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Чёрный'));
    await tester.enterText(find.widgetWithText(TextField, 'Прозвище'), 'с луком');
    await tester.pump();

    final goblin = battle.state.active.monsters[1];
    expect(goblin.marker, MonsterMarker.black);
    expect(goblin.label, 'с луком');
    expect(find.text('Гоблин 2 «с луком»'), findsWidgets);
  });

  testWidgets('мастер добавляет свой эффект с описанием и длительностью', (tester) async {
    await pump(tester);
    battle.addMonster(Bestiary.goblin);
    await tester.pump();

    await tester.tap(find.text('Гоблин'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Добавить эффект'), 100, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text('Добавить эффект'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Название'), 'Удивлён');
    await tester.enterText(find.widgetWithText(TextField, 'Описание'), 'Ты отказываешься биться');
    await tester.enterText(find.widgetWithText(TextField, 'Длительность в ходах'), '2');
    await tester.pump();
    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle();

    final status = battle.state.active.statuses['m0']!.single;
    expect(status.label, 'Удивлён · 2 хода');
    expect(status.description, 'Ты отказываешься биться');
    expect(find.text('Удивлён · 2 хода'), findsWidgets);
  });
}
