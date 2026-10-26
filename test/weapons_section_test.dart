import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/damage_type.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:dnd_character_list/domain/models/weapon_kind.dart';
import 'package:dnd_character_list/domain/models/weapon_type.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/weapons_section.dart';
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
    cubit = PlayerCubit(playerFixture().equipWeapon(rapierFixture, WeaponSlot.mainHand), await SpSource.init());
  });

  Future<void> pumpSection(WidgetTester tester) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: BlocBuilder<PlayerCubit, Player>(
                builder: (context, player) => PlayerModel(
                  player: player,
                  child: const SingleChildScrollView(child: WeaponsSection()),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('attacks follow equipped weapons', (tester) async {
    await pumpSection(tester);
    expect(find.text('Рапира'), findsOneWidget);

    await tester.runAsync(() async {
      await cubit.equipWeapon(daggerFixture, WeaponSlot.mainHand);
      await cubit.equipWeapon(daggerFixture, WeaponSlot.secondHand);
    });
    await tester.pump();

    expect(find.text('Рапира'), findsNothing);
    expect(find.text('Кинжал'), findsNWidgets(2));
  });

  testWidgets('thrown weapon appears in attacks', (tester) async {
    await pumpSection(tester);

    await tester.runAsync(() => cubit.equipWeapon(daggerFixture, WeaponSlot.mainRange));
    await tester.pump();

    expect(find.text('Рапира'), findsOneWidget);
    expect(find.text('Кинжал'), findsOneWidget);
    expect(find.textContaining('Метательное'), findsOneWidget);
  });

  testWidgets('elemental damage is a separate chip with its own type', (tester) async {
    final flameTongue = Weapon(
      name: 'Язык пламени',
      damage: Dice.k8,
      damageType: DamageType.chopping,
      kind: WeaponKind.martialMelee,
      type: WeaponType.oneHanded,
      elementalDamage: [ElementalDamage(type: ElementalType.fire, damage: Dice.k6, count: 2)],
    );
    await pumpSection(tester);
    await tester.runAsync(() async {
      await cubit.addItem(InventoryItem(item: flameTongue, quantity: 1));
      await cubit.equipWeapon(flameTongue, WeaponSlot.mainHand);
    });
    await tester.pump();

    expect(find.text('1к8 − 1 рубящий', findRichText: true), findsOneWidget);
    expect(find.text('+2к6 огонь', findRichText: true), findsOneWidget);
  });
}
