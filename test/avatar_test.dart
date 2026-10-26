import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dnd_character_list/data/avatar_store.dart';
import 'package:dnd_character_list/data/session/player_combatant.dart';
import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/character_avatar.dart';
import 'package:dnd_character_list/presentation/common/widgets/pixel_avatar/avatar_renderer.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/personality_screen/personality_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

void main() {
  late Directory documents;

  setUp(() => documents = Directory.systemTemp.createTempSync('avatars'));
  tearDown(() => documents.deleteSync(recursive: true));

  test('avatar is copied into the app folder and deleted', () async {
    final store = AvatarStore(documents: () async => documents);
    final source = File('${documents.path}/picked.png')..writeAsBytesSync([1, 2, 3]);

    final name = await store.save(source.path);
    expect(name, endsWith('.png'));
    final file = await store.file(name);
    expect(file!.path, '${documents.path}/avatars/$name');
    expect(file.readAsBytesSync(), [1, 2, 3]);

    await store.delete(name);
    expect(await store.file(name), isNull);
    expect(await store.file(null), isNull);
  });

  test('avatar is saved with the character but never sent to the master', () {
    final player = playerFixture();
    final withAvatar = player.copyWith(personality: player.personality.copyWith(avatar: () => 'avatar_1.jpg'));

    expect(Player.fromJson(withAvatar.toJson()).personality.avatar, 'avatar_1.jpg');
    expect(withAvatar.personality.copyWith(avatar: () => null).avatar, isNull);
    expect(jsonEncode(withAvatar.combatantProfile.toJson()), isNot(contains('avatar')));
    expect(jsonEncode(withAvatar.combatantState.toJson()), isNot(contains('avatar')));
  });

  testWidgets('character screen shows header, sections and avatar picker', (tester) async {
    SharedPreferences.setMockInitialValues({});
    getIt
      ..registerSingleton<AvatarStore>(AvatarStore(documents: () async => documents))
      ..registerSingleton<AvatarRenderer>(AvatarRenderer());
    addTearDown(getIt.reset);
    final cubit = PlayerCubit(playerFixture(), await SpSource.init());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: BlocBuilder<PlayerCubit, Player>(
              builder: (context, player) => PlayerModel(player: player, child: const PersonalityScreen()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Тест'), findsOneWidget);
    expect(find.text('Новый уровень'), findsOneWidget);
    expect(find.text('ВНЕШНОСТЬ'), findsOneWidget);
    expect(find.text('170 см'), findsOneWidget);
    // Без аватара — первая буква имени.
    expect(find.descendant(of: find.byType(CharacterAvatar), matching: find.text('Т')), findsOneWidget);

    await tester.dragUntilVisible(find.text('ОСОБЕННОСТИ'), find.byType(ListView), const Offset(0, -200));
    expect(find.text('ОСОБЕННОСТИ'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, 2000));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CharacterAvatar));
    await tester.pumpAndSettle();
    expect(find.text('Выбрать из галереи'), findsOneWidget);
    // Аватара ещё нет — убирать нечего.
    expect(find.text('Убрать аватар'), findsNothing);
  });

  test('avatar frame is saved and changes the player state', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = PlayerCubit(playerFixture(), await SpSource.init());
    final states = <Player>[];
    final subscription = cubit.stream.listen(states.add);

    // Раньше Player.== не сравнивал личность, и bloc пропускал состояние с новым аватаром.
    await cubit.setAvatar('avatar_1.jpg', frame: const AvatarFrame(scale: 2, dx: -0.5, dy: -0.25));
    await Future<void>.delayed(Duration.zero);
    expect(states, hasLength(1));
    expect(states.single.personality.avatar, 'avatar_1.jpg');
    expect(Player.fromJson(states.single.toJson()).personality.avatarFrame,
        const AvatarFrame(scale: 2, dx: -0.5, dy: -0.25));
    await subscription.cancel();
  });

  testWidgets('chosen avatar appears without restart', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = AvatarStore(documents: () async => documents);
    getIt
      ..registerSingleton<AvatarStore>(store)
      ..registerSingleton<AvatarRenderer>(AvatarRenderer());
    addTearDown(getIt.reset);
    final cubit = PlayerCubit(playerFixture(), await SpSource.init());
    final png = await tester.runAsync(() => _png(200, 100));
    final name = await tester.runAsync(() async {
      final source = File('${documents.path}/picked.png')..writeAsBytesSync(png!);
      return store.save(source.path);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: BlocBuilder<PlayerCubit, Player>(
              builder: (context, player) => PlayerModel(player: player, child: const PersonalityScreen()),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(FramedAvatarImage), findsNothing);

    await tester.runAsync(() => cubit.setAvatar(name));
    expect(tester.widget<CharacterAvatar>(find.byType(CharacterAvatar)).avatar, isNull);
    await _settleFiles(tester);
    expect(tester.widget<CharacterAvatar>(find.byType(CharacterAvatar)).avatar, name);
    expect(find.byType(FramedAvatarImage), findsOneWidget);
  });

  testWidgets('editor centers a new photo and returns its frame', (tester) async {
    final png = await tester.runAsync(() => _png(200, 100));
    final file = File('${documents.path}/wide.png')..writeAsBytesSync(png!);
    AvatarFrame? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await AvatarEditorScreen.show(context, file: file),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await _settleFiles(tester);
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();
    // Широкая фотография 2:1 по центру: сдвиг на половину стороны круга влево.
    expect(result!.scale, 1);
    expect(result!.dx, closeTo(-0.5, 0.001));
    expect(result!.dy, 0);
  });

  test('deleting a character removes it and its avatar', () async {
    SharedPreferences.setMockInitialValues({});
    final store = AvatarStore(documents: () async => documents);
    getIt.registerSingleton<AvatarStore>(store);
    addTearDown(getIt.reset);
    final source = await SpSource.init();
    final picked = File('${documents.path}/picked.png')..writeAsBytesSync([1, 2, 3]);
    final name = await store.save(picked.path);
    final player = playerFixture();
    final cubit = PlayerCubit(player.copyWith(personality: player.personality.copyWith(avatar: () => name)), source);
    await source.savePlayer(cubit.state);
    expect(source.getSavedPlayers(), hasLength(1));

    await cubit.delete();

    expect(source.getSavedPlayers(), isEmpty);
    expect(await store.file(name), isNull);
  });

  testWidgets('delete button asks for confirmation', (tester) async {
    SharedPreferences.setMockInitialValues({});
    getIt
      ..registerSingleton<AvatarStore>(AvatarStore(documents: () async => documents))
      ..registerSingleton<AvatarRenderer>(AvatarRenderer());
    addTearDown(getIt.reset);
    final source = await SpSource.init();
    final cubit = PlayerCubit(playerFixture(), source);
    await tester.runAsync(() => source.savePlayer(cubit.state));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: PlayerModel(player: cubit.state, child: const PersonalityScreen()),
          ),
        ),
      ),
    );
    await tester.scrollUntilVisible(find.text('Удалить персонажа'), 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Удалить персонажа'));
    await tester.pumpAndSettle();
    expect(find.text('Удалить «Тест»?'), findsOneWidget);

    // Отмена ничего не удаляет.
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(find.text('Удалить «Тест»?'), findsNothing);
    expect(source.getSavedPlayers(), hasLength(1));
  });
}

/// Чтение файлов в виджет-тестах завершается только в реальном времени: несколько пауз с кадрами между ними.
Future<void> _settleFiles(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  }
  await tester.pump();
}

/// Картинка PNG заданного размера.
Future<List<int>> _png(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const ui.Color(0xFF3366FF),
  );
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}
