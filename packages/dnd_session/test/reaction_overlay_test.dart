import 'package:dnd_session/dnd_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final reaction in Reaction.values) {
    testWidgets('${reaction.name}: flies in, shows the sender, does not block taps and disappears', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (taps++ == 0) ReactionOverlay.show(context, reaction: reaction, from: 'Лира');
                  },
                  child: const Text('Кнопка'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Кнопка'));
      await tester.pump();
      expect(find.text(reaction.emoji), findsOneWidget);

      // Нажатия проходят сквозь анимацию.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Кнопка'), warnIfMissed: false);
      expect(taps, 2);

      // Сработала: частицы и подпись, от кого.
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('Лира ${reaction.phrase}'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text(reaction.emoji), findsNothing);
      expect(find.text('Лира ${reaction.phrase}'), findsNothing);
    });
  }

  testWidgets('several reactions stack with their own trajectories', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => ReactionOverlay.show(context, reaction: Reaction.poop, from: 'Лира'),
                child: const Text('Кнопка'),
              ),
            ),
          ),
        ),
      ),
    );

    // Три какашки подряд: все на экране одновременно, каждая в своём месте.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Кнопка'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 900));
    final poops = find.text('💩');
    expect(poops, findsNWidgets(3));
    final centers = poops.evaluate().map((e) => tester.getCenter(find.byWidget(e.widget))).toSet();
    expect(centers, hasLength(3));

    await tester.pumpAndSettle();
    expect(poops, findsNothing);
  });

  test('reactions survive the protocol', () {
    for (final reaction in Reaction.values) {
      final message = SessionMessage.decode(ReactionMessage(reaction, from: 'Лира').encode());
      expect(message, isA<ReactionMessage>().having((e) => e.reaction, 'reaction', reaction));
    }
    // Неизвестная реакция из новой версии пропускается.
    expect(SessionMessage.decode('{"type":"reaction","reaction":"unicorn","from":"Лира"}'), isNull);
  });
}
