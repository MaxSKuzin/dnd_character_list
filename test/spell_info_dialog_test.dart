import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

const _spell = Spell(
  link: '/spells/faerie-fire',
  name: 'Огонь фей',
  nameEn: 'Faerie Fire',
  slot: SpellSlot.level1,
  school: 'Воплощение',
  isConcentration: true,
  isRitual: false,
  components: [SpellComponent.verbal, SpellComponent.material],
  allowedSpecializations: [],
  details: SpellDetails(
    levelAndSchool: '1 уровень, воплощение',
    castTime: '1 действие',
    distance: '60 футов',
    components: 'В, М (светлячок)',
    duration: 'Концентрация, вплоть до 1 минуты',
    classes: 'Бард, друид',
    subclasses: null,
    source: "Player's Handbook",
    descriptionHtml: '<p>Предметы очерчиваются светом.</p>',
  ),
);

void main() {
  late PlayerCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final bard = Bard(level: 3, isMain: true, knownSpells: const [], features: const [], inspirationDice: Dice.k6);
    cubit = PlayerCubit(playerFixture(spec: bard), await SpSource.init());
  });

  Future<void> open(WidgetTester tester, {bool canChangeSlot = true}) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => SpellInfoDialog.show(context, spell: _spell, canChangeSlot: canChangeSlot),
                child: const Text('Открыть'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows parameters as tiles and spends the chosen slot', (tester) async {
    await open(tester);

    expect(find.text('Концентрация'), findsOneWidget);
    expect(find.text('60 футов'), findsOneWidget);
    expect(find.text('В, М'), findsOneWidget);
    expect(find.text('светлячок', findRichText: true), findsNothing);
    expect(find.textContaining('светлячок', findRichText: true), findsOneWidget);
    expect(find.text('1 ур.'), findsOneWidget);
    expect(find.text('2 ур.'), findsOneWidget);

    final level2 = cubit.state.currentSpellSlots[SpellSlot.level2]!;
    await tester.tap(find.text('2 ур.'));
    await tester.pump();
    await tester.tap(find.text('Использовать'));
    await tester.pump();
    expect(cubit.state.currentSpellSlots[SpellSlot.level2], level2 - 1);

    await tester.tap(find.byTooltip('Закрыть'));
    await tester.pumpAndSettle();
    expect(find.text('Огонь фей'), findsNothing);
  });

  testWidgets('racial spell is cast only with its own level', (tester) async {
    await open(tester, canChangeSlot: false);
    expect(find.text('1 ур.'), findsOneWidget);
    expect(find.text('2 ур.'), findsNothing);
  });
}
