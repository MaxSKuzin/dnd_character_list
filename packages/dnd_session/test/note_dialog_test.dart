import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('диалог возвращает текст без пробелов по краям, пустой — null', (tester) async {
    String? result = 'не открывали';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async => result = await NoteDialog.show(context, to: 'Лира', replyTo: 'Можно?'),
            child: const Text('Открыть'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    expect(find.text('Сообщение: Лира'), findsOneWidget);
    expect(find.text('Можно?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  Да, бросай  ');
    await tester.tap(find.text('Отправить'));
    await tester.pumpAndSettle();
    expect(result, 'Да, бросай');

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Отправить'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
