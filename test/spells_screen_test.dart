import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/spells_screen/spells_screen.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_tile.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

Spell _spell(String name, SpellSlot slot, {bool isConcentration = false}) => Spell(
      link: '/spells/$name',
      name: name,
      nameEn: name,
      slot: slot,
      school: 'Воплощение',
      isConcentration: isConcentration,
      isRitual: false,
      components: const [SpellComponent.verbal],
      allowedSpecializations: const [],
    );

void main() {
  late SpSource source;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    source = await SpSource.init();
    getIt.registerSingleton<SpSource>(source);
  });
  tearDown(() => getIt.reset());

  Player player() {
    final bard = Bard(
      level: 3,
      isMain: true,
      knownSpells: [
        _spell('Огненный снаряд', SpellSlot.conspiracy),
        _spell('Усыпление', SpellSlot.level1),
        _spell('Благословение', SpellSlot.level1, isConcentration: true),
        _spell('Невидимость', SpellSlot.level2, isConcentration: true),
        // Название в две строки и метка: плитка не должна переполняться.
        _spell('Защита от добра и зла и прочих напастей', SpellSlot.level2, isConcentration: true),
      ],
      features: const [],
      inspirationDice: Dice.k6,
    );
    final json = playerFixture(spec: bard).toJson();
    return Player.fromJson(json)
        .copyWith(raceSpells: {SpellSlot.conspiracy: _spell('Чудотворство', SpellSlot.conspiracy)});
  }

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlayerModel(player: player(), child: const SpellsScreen())),
        ),
      );

  testWidgets('switches between list and grid and remembers the choice', (tester) async {
    await pump(tester);
    expect(find.byType(SpellWidget), findsWidgets);
    expect(find.byType(SpellTile), findsNothing);

    await tester.tap(find.byTooltip('Показать сеткой'));
    await tester.pumpAndSettle();

    expect(find.byType(SpellWidget), findsNothing);
    expect(find.byType(SpellTile), findsNWidgets(6));
    expect(find.text('ЗАГОВОРЫ'), findsOneWidget);
    expect(find.text('1 УРОВЕНЬ'), findsOneWidget);
    expect(find.text('2 УРОВЕНЬ'), findsOneWidget);
    // Внутри уровня — по названию; расовое заклинание и концентрация отмечены.
    final level1 = tester.widgetList<SpellTile>(find.byType(SpellTile)).where((e) => e.spell.slot == SpellSlot.level1);
    expect(level1.map((e) => e.spell.name), ['Благословение', 'Усыпление']);
    expect(find.text('Раса'), findsOneWidget);
    expect(find.text('Конц.'), findsNWidgets(3));
    expect(find.text('В'), findsNWidgets(6));
    expect(source.isSpellsGrid, isTrue);

    // Вид запоминается: заново открытый экран показывает сетку.
    await tester.pumpWidget(const SizedBox());
    await pump(tester);
    expect(find.byType(SpellTile), findsNWidgets(6));

    await tester.tap(find.byTooltip('Показать списком'));
    await tester.pumpAndSettle();
    expect(find.byType(SpellTile), findsNothing);
    expect(source.isSpellsGrid, isFalse);
  });
}
