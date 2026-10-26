import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/fighter.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/spells_screen/spells_screen.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_slots_fab.dart';
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
    // Длинное название — одной строкой с многоточием, метка «Конц.» — в строке школы.
    final longName = find.descendant(
      of: find.byType(SpellTile),
      matching: find.text('Защита от добра и зла и прочих напастей'),
    );
    expect(tester.widget<Text>(longName).maxLines, 1);
    expect(tester.getSize(longName).height, lessThan(25));

    // Вид запоминается: заново открытый экран показывает сетку.
    await tester.pumpWidget(const SizedBox());
    await pump(tester);
    expect(find.byType(SpellTile), findsNWidgets(6));

    await tester.tap(find.byTooltip('Показать списком'));
    await tester.pumpAndSettle();
    expect(find.byType(SpellTile), findsNothing);
    expect(source.isSpellsGrid, isFalse);
  });

  testWidgets('search focus hides filters and shows the active ones', (tester) async {
    await pump(tester);
    final levelChip = find.widgetWithText(ChoiceChip, '1 уровень');
    await tester.tap(levelChip);
    await tester.pump();

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNothing);
    // Фильтр по-прежнему действует — он виден строкой.
    expect(find.text('1 уровень'), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);

    // Нажатие мимо поля снимает фокус, и фильтры возвращаются.
    await tester.tapAt(const Offset(5, 590));
    await tester.pumpAndSettle();
    expect(levelChip, findsOneWidget);
    expect(find.byIcon(Icons.filter_alt_outlined), findsNothing);
  });

  testWidgets('header hides on scroll down and returns on scroll up', (tester) async {
    await pump(tester);
    // «е» есть в пяти заклинаниях из шести — список всё ещё длиннее экрана.
    await tester.enterText(find.byType(TextField), 'е');
    await tester.pump();
    expect(tester.getRect(find.byType(TextField)).top, greaterThanOrEqualTo(0));

    // Прокрутка вниз — шапка уезжает.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.byType(TextField).hitTestable(), findsNothing);

    // Небольшая прокрутка вверх — шапка возвращается, хотя до начала списка далеко; текст поиска на месте.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 150));
    await tester.pumpAndSettle();
    expect(find.byType(TextField).hitTestable(), findsOneWidget);
    expect(find.widgetWithText(TextField, 'е'), findsOneWidget);
    expect(find.text('Чудотворство'), findsNothing);
  });

  testWidgets('slots button opens a grid with current spell slots', (tester) async {
    await pump(tester);
    final fab = find.byType(SpellSlotsFab);
    expect(find.descendant(of: fab, matching: find.text('ЯЧЕЙКИ ЗАКЛИНАНИЙ')), findsNothing);

    await tester.tap(find.byTooltip('Ячейки заклинаний'));
    await tester.pumpAndSettle();
    // Бард 3 уровня: 4 ячейки 1 уровня и 2 ячейки 2 уровня, все на месте.
    expect(find.descendant(of: fab, matching: find.text('ЯЧЕЙКИ ЗАКЛИНАНИЙ')), findsOneWidget);
    expect(find.descendant(of: fab, matching: find.text('1 уровень')), findsOneWidget);
    expect(find.descendant(of: fab, matching: find.text('4/4')), findsOneWidget);
    expect(find.descendant(of: fab, matching: find.text('2/2')), findsOneWidget);
    expect(find.descendant(of: fab, matching: find.byIcon(Icons.circle)), findsNWidgets(6));

    // Закрытие анимировано: в середине анимации карточка ещё видна и прозрачнее, после — исчезает.
    await tester.tap(find.byTooltip('Скрыть ячейки'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final title = find.descendant(of: fab, matching: find.text('ЯЧЕЙКИ ЗАКЛИНАНИЙ'));
    expect(title, findsOneWidget);
    final opacity =
        tester.widget<FadeTransition>(find.ancestor(of: title, matching: find.byType(FadeTransition)).first);
    expect(opacity.opacity.value, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(title, findsNothing);
  });

  testWidgets('no slots button without spell slots', (tester) async {
    final fighter = Fighter(level: 3, isMain: true, features: const [], fightingStyles: const [FightingStyle.archery]);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PlayerModel(player: playerFixture(spec: fighter), child: const SpellsScreen())),
      ),
    );
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
