import 'package:dnd_character_list/domain/models/classes/monk.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/martial_arts_dice.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  final monk = Monk(
    level: 5,
    isMain: true,
    features: const [
      Peculiarity(name: 'БОЕВЫЕ ИСКУССТВА', description: '<p>Кость боевых искусств.</p>', isHtml: true),
    ],
    martialArtsDice: Dice.k6,
  );

  Future<void> pump(WidgetTester tester, Player player) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerModel(
              player: player,
              child: const Center(child: SizedBox(width: 200, height: 100, child: MartialArtsDice())),
            ),
          ),
        ),
      );

  testWidgets('shows martial arts die and its description', (tester) async {
    await pump(tester, playerFixture(spec: monk));

    expect(find.text('1к6'), findsOneWidget);
    expect(find.text('Не действует в доспехе или со щитом'), findsNothing);

    await tester.tap(find.byType(MartialArtsDice));
    await tester.pumpAndSettle();
    expect(find.text('Кость боевых искусств.'), findsOneWidget);
  });

  testWidgets('martial arts do not work in armor', (tester) async {
    await pump(tester, playerFixture(spec: monk).equipArmor(leatherFixture));

    expect(find.text('Не действует в доспехе или со щитом'), findsOneWidget);
  });
}
