import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/protection_widget.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  Future<void> pump(WidgetTester tester, Player player) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerModel(
              player: player,
              child: const Center(child: SizedBox(width: 120, height: 140, child: ProtectionWidget())),
            ),
          ),
        ),
      );

  testWidgets('tap shows armor class parts', (tester) async {
    // Ловкость 16 (+3), средний доспех ограничивает её до +2, щит +2.
    await pump(tester, playerFixture().equipArmor(scaleFixture).equipShield(shieldFixture));
    expect(find.text('18'), findsOneWidget);

    await tester.tap(find.byType(ProtectionWidget));
    await tester.pumpAndSettle();

    expect(find.text('Класс брони 18'), findsOneWidget);
    expect(find.text('Чешуйчатый'), findsOneWidget);
    expect(find.text('Средний доспех: базовый КД доспеха'), findsOneWidget);
    expect(find.text('Модификатор Ловкости, в среднем доспехе не больше +2'), findsOneWidget);
    expect(find.text('Щит'), findsOneWidget);
    expect(find.text('14 +2 +2 = 18'), findsOneWidget);
  });
}
