import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<BuildContext> pumpApp(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        ),
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return Center(
                child: ElevatedButton(onPressed: () {}, child: const Text('Кнопка')),
              );
            },
          ),
        ),
      ),
    );
    return context;
  }

  testWidgets('сообщения складываются стопкой, новое сверху, и уходят сами', (tester) async {
    final context = await pumpApp(tester);
    NoteOverlay.show(context, from: 'Мастер', text: 'Бросьте восприятие');
    await tester.pump(const Duration(seconds: 1));
    NoteOverlay.show(context, from: 'Борин', text: 'Прикрой меня');
    await tester.pumpAndSettle();

    expect(find.text('МАСТЕР'), findsOneWidget);
    expect(find.text('БОРИН'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Прикрой меня')).dy,
      lessThan(tester.getTopLeft(find.text('Бросьте восприятие')).dy),
    );
    // Экран под сообщениями нажимается.
    await tester.tap(find.text('Кнопка'));

    await tester.pump(NoteOverlay.durationFor('Прикрой меня'));
    await tester.pumpAndSettle();
    expect(find.text('Бросьте восприятие'), findsNothing);
    expect(find.text('Прикрой меня'), findsNothing);

    // После того как стопка опустела, новое сообщение снова показывается.
    NoteOverlay.show(context, from: 'Мастер', text: 'Ещё одно');
    await tester.pumpAndSettle();
    expect(find.text('Ещё одно'), findsOneWidget);
    await tester.tap(find.byTooltip('Закрыть'));
    await tester.pumpAndSettle();
    expect(find.text('Ещё одно'), findsNothing);
  });

  testWidgets('«Ответить» закрывает сообщение и вызывает ответ', (tester) async {
    final context = await pumpApp(tester);
    var replied = false;
    NoteOverlay.show(context, from: 'Лира', text: 'Можно?', onReply: () => replied = true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ответить'));
    await tester.pumpAndSettle();
    expect(replied, isTrue);
    expect(find.text('Можно?'), findsNothing);
  });

  testWidgets('больше трёх сообщений — старые убираются', (tester) async {
    final context = await pumpApp(tester);
    for (var i = 1; i <= 5; i++) {
      NoteOverlay.show(context, from: 'Мастер', text: 'Сообщение $i');
    }
    await tester.pumpAndSettle();
    expect(find.text('Сообщение 1'), findsNothing);
    expect(find.text('Сообщение 2'), findsNothing);
    expect(find.text('Сообщение 5'), findsOneWidget);
    await tester.pump(const Duration(seconds: 20));
    await tester.pumpAndSettle();
  });
}
