import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('new snack bar replaces the shown one without a queue', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => SingleSnackBarMessenger(child: child!),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  for (var i = 1; i <= 5; i++) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Уведомление $i')));
                  }
                },
                child: const Text('Кнопка'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Кнопка'));
    await tester.pumpAndSettle();
    // Сразу последнее, остальные убраны, а не ждут в очереди.
    expect(find.text('Уведомление 5'), findsOneWidget);
    for (var i = 1; i <= 4; i++) {
      expect(find.text('Уведомление $i'), findsNothing);
    }

    // После того как оно закроется, из очереди ничего не всплывает.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });
}
