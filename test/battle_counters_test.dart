import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/death_throws_widget.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/spell_slots_section.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

void main() {
  late PlayerCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cubit = PlayerCubit(playerFixture(), await SpSource.init());
  });

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: BlocBuilder<PlayerCubit, Player>(
                builder: (_, player) => PlayerModel(player: player, child: SingleChildScrollView(child: child)),
              ),
            ),
          ),
        ),
      );

  testWidgets('spell slot is spent and restored with the tile buttons', (tester) async {
    await pump(tester, const SpellSlotsSection());
    final max = cubit.state.spellCells[SpellSlot.level1]!;
    final restore = find.byTooltip('Вернуть ячейку 1 уровня');
    // Ячейки полные — возвращать нечего.
    expect(tester.widget<IconButton>(find.ancestor(of: restore, matching: find.byType(IconButton))).onPressed, isNull);

    await tester.tap(find.byTooltip('Потратить ячейку 1 уровня'));
    await tester.pump();
    expect(cubit.state.currentSpellSlots[SpellSlot.level1], max - 1);

    await tester.tap(restore);
    await tester.pump();
    expect(cubit.state.currentSpellSlots[SpellSlot.level1], max);
  });

  testWidgets('death saves are marked only at 0 hits', (tester) async {
    Finder mark(String row, int index) => find
        .descendant(
            of: find.ancestor(of: find.text(row), matching: find.byType(Row)), matching: find.byType(InkResponse))
        .at(index);

    await pump(tester, const DeathThrowsWidget());
    // С хитами плитка приглушена и не нажимается.
    await tester.tap(mark('Успех', 1), warnIfMissed: false);
    await tester.pump();
    expect(cubit.state.deathThrows.life, 0);

    await tester.runAsync(() async => cubit.takeDamage(cubit.state.currentHits));
    await tester.pump();
    await tester.tap(mark('Успех', 1));
    await tester.pump();
    await tester.tap(mark('Провал', 0));
    await tester.pump();
    expect(cubit.state.deathThrows.life, 2);
    expect(cubit.state.deathThrows.death, 1);
  });
}
