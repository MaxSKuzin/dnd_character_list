import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/data/ttg/ttg_client.dart';
import 'package:dnd_character_list/data/ttg/ttg_spells_mapper.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_replacement.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/level_up_flow/screens/replace_spell_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Spell _spell(String name, SpellSlot slot, {List<ClassKind> classes = const [ClassKind.bard]}) => Spell(
      link: '/spells/$name',
      name: name,
      nameEn: name,
      slot: slot,
      school: 'очарование',
      isConcentration: false,
      isRitual: false,
      components: const [SpellComponent.verbal],
      allowedSpecializations: classes,
    );

final _charm = _spell('Очарование', SpellSlot.level1);
final _heroism = _spell('Героизм', SpellSlot.level1);
final _sleep = _spell('Усыпление', SpellSlot.level1);
final _silence = _spell('Тишина', SpellSlot.level2);
final _fireball = _spell('Огненный шар', SpellSlot.level3);
final _magicMissile = _spell('Волшебная стрела', SpellSlot.level1, classes: const [ClassKind.sorcerer]);
final _mockery = _spell('Злая насмешка', SpellSlot.conspiracy);
final _light = _spell('Свет', SpellSlot.conspiracy);

/// Репозиторий без сети: список заклинаний задан, описания не загружаются.
class _FakeSpellsRepository extends SpellsRepository {
  _FakeSpellsRepository() : super(TtgClient(), TtgSpellsMapper());

  @override
  Future<List<Spell>> getSpells({bool forceRefresh = false}) async =>
      [_charm, _heroism, _sleep, _silence, _fireball, _magicMissile, _mockery, _light];

  @override
  Future<List<Spell>> withDetailsIfPossible(List<Spell> spells) async => spells;
}

void main() {
  setUpAll(() => getIt.registerSingleton<SpellsRepository>(_FakeSpellsRepository()));
  tearDownAll(() => getIt.reset());

  Future<List<SpellReplacement?>> pump(
    WidgetTester tester, {
    List<Spell> replaceable = const [],
    List<SpellSlot> slots = const [SpellSlot.level1, SpellSlot.level2],
    List<Spell> known = const [],
  }) async {
    final results = <SpellReplacement?>[];
    await tester.pumpWidget(
      MaterialApp(
        home: ReplaceSpellScreen(
          title: 'Замена заклинания',
          description: 'Можно заменить одно заклинание.',
          replaceableSpells: replaceable,
          classKind: ClassKind.bard,
          newSpellSlots: slots,
          knownSpells: known,
          onSelected: results.add,
        ),
      ),
    );
    return results;
  }

  Future<void> openCard(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// Названия заклинаний в открытом диалоге выбора.
  List<String> dialogSpells(WidgetTester tester) => tester
      .widgetList<ListTile>(find.descendant(of: find.byType(Dialog), matching: find.byType(ListTile)))
      .map((e) => (e.title as Text).data!)
      .toList();

  testWidgets('new spell list excludes known spells, other classes and too high levels', (tester) async {
    final results = await pump(tester, replaceable: [_charm, _heroism], known: [_charm, _heroism, _mockery]);

    // Пока не выбрано заклинание на замену, новое выбрать нельзя.
    expect(tester.widget<ListTile>(find.widgetWithText(ListTile, 'Новое заклинание')).enabled, isFalse);

    await openCard(tester, 'Заклинание на замену');
    expect(dialogSpells(tester), ['Очарование', 'Героизм']);
    await tester.tap(find.text('Очарование'));
    await tester.pumpAndSettle();

    await openCard(tester, 'Новое заклинание');
    // Уже известные, заклинания волшебника и 3 уровень при ячейках до 2 уровня не предлагаются.
    expect(dialogSpells(tester), ['Усыпление', 'Тишина']);
    await tester.tap(find.text('Тишина'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Тишина'), findsOneWidget);
    await tester.tap(find.text('Заменить'));
    await tester.pumpAndSettle();

    expect(results.single?.replaced, _charm);
    expect(results.single?.learned, _silence);
  });

  testWidgets('cantrip is replaced only by a cantrip', (tester) async {
    final results = await pump(
      tester,
      replaceable: [_mockery],
      slots: const [SpellSlot.conspiracy],
      known: [_mockery, _charm],
    );

    await openCard(tester, 'Заклинание на замену');
    await tester.tap(find.text('Злая насмешка'));
    await tester.pumpAndSettle();
    await openCard(tester, 'Новое заклинание');

    expect(dialogSpells(tester), ['Свет']);
    await tester.tap(find.text('Свет'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Заменить'));
    await tester.pumpAndSettle();

    expect(results.single?.learned, _light);
  });

  testWidgets('step can be skipped', (tester) async {
    final results = await pump(tester, replaceable: [_charm], known: [_charm]);

    expect(tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Заменить')).onPressed, isNull);
    await tester.tap(find.text('Пропустить'));
    await tester.pumpAndSettle();

    expect(results, [null]);
  });
}
