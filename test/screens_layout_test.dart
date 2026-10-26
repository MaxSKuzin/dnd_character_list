import 'dart:io';

import 'package:dnd_character_list/data/avatar_store.dart';
import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/bloc/created_characters_cubit.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/theme_extensions.dart';
import 'package:dnd_character_list/presentation/inventory_screen/inventory_screen.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/main_screen/main_screen.dart';
import 'package:dnd_character_list/presentation/select_character_screen/select_character_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

void main() {
  late SpSource source;
  late PlayerCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    source = await SpSource.init();
    cubit = PlayerCubit(playerFixture(), source);
    final documents = Directory.systemTemp.createTempSync('layout');
    getIt
      ..registerSingleton<SpSource>(source)
      ..registerSingleton<AvatarStore>(AvatarStore(documents: () async => documents))
      ..registerFactory(() => CreatedCharactersCubit(source));
  });
  tearDown(() => getIt.reset());

  // Экран телефона: переполнения видны как исключения.
  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        // Цвет карточек — как в приложении: без него у разделов нет фона.
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          extensions: [CustomColors(cardColor: const Color.fromARGB(255, 29, 31, 48))],
        ),
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: BlocBuilder<PlayerCubit, Player>(builder: (_, player) => PlayerModel(player: player, child: screen)),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('stats screen: header, abilities, saves and skills by ability', (tester) async {
    await pump(tester, const MainScreen());

    // «Телосложение» в две колонки спасбросков — одной строкой.
    final constitution = find.text('Телосложение').first;
    expect(tester.getSize(constitution).height, lessThan(30));

    expect(find.text('Бонус мастерства'), findsOneWidget);
    // Пассивное восприятие от Мудрости: 10 + Восприятие (Мудрость 10, без владения).
    expect(find.text('Пассивное восприятие'), findsOneWidget);
    expect(find.text('Мудрость (Восприятие)'), findsOneWidget);
    expect(find.text('Анализ'), findsNothing);
    // Плитки одного ряда — одной высоты, хотя у восприятия есть подпись под значением.
    double tileHeight(String label) =>
        tester.getSize(find.ancestor(of: find.text(label), matching: find.byType(InfoTile)).first).height;
    expect(tileHeight('Бонус мастерства'), tileHeight('Пассивное восприятие'));
    expect(find.text('+2'), findsWidgets);
    expect(find.text('ХАРАКТЕРИСТИКИ'), findsOneWidget);
    // Ловкость 16 у тестового персонажа: +3.
    expect(find.text('16'), findsOneWidget);
    expect(find.text('СПАСБРОСКИ'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Скрытность'), 200);
    expect(find.text('НАВЫКИ'), findsOneWidget);
  });

  testWidgets('inventory screen: wallet, equipment and item groups', (tester) async {
    await pump(tester, const InventoryScreen());

    expect(find.text('КОШЕЛЁК'), findsOneWidget);
    expect(find.text('Золото'), findsOneWidget);
    expect(find.text('ЭКИПИРОВКА'), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
    _expectListTilesOnMaterial(tester);
    await tester.scrollUntilVisible(find.text('ОРУЖИЕ'), 300);
    expect(find.text('Рапира'), findsOneWidget);
    _expectListTilesOnMaterial(tester);
  });

  testWidgets('character selection: header, cards and new character', (tester) async {
    await source.savePlayer(playerFixture());
    await pump(tester, const SelectCharacterScreen());
    await tester.pump();

    expect(find.text('Персонажи'), findsOneWidget);
    expect(find.text('Тест'), findsOneWidget);
    expect(find.text('Тифлинг · 1 уровень'), findsOneWidget);
    expect(find.text('Новый персонаж'), findsOneWidget);
  });
}

/// У каждого `ListTile` ближайший фон — `Material`: на цветном `DecoratedBox` подсветка и нажатия не видны
/// (в новых версиях Flutter это ошибка «ListTile background color or ink splashes may be invisible»).
void _expectListTilesOnMaterial(WidgetTester tester) {
  for (final tile in find.byType(ListTile).evaluate()) {
    Widget? background;
    tile.visitAncestorElements((element) {
      final widget = element.widget;
      final isColoredBox = widget is DecoratedBox &&
          switch (widget.decoration) {
            BoxDecoration(color: final color?) || ShapeDecoration(color: final color?) => color.a > 0,
            _ => false,
          };
      if (widget is Material || isColoredBox) {
        background = widget;
        return false;
      }
      return true;
    });
    expect(background, isA<Material>(), reason: 'ListTile ${tile.widget} без Material');
  }
}
