import 'package:dnd_character_list/data/sp_source.dart';
import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/fighter.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/concentration_banner.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/health_section.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/rest_button.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fixtures.dart';

Bard _bard(int level) =>
    Bard(level: level, isMain: true, knownSpells: const [], features: const [], inspirationDice: Dice.k6);

void main() {
  group('текущее состояние сохраняется', () {
    test('хиты, временные хиты, ячейки, ресурсы, кости хитов, концентрация и вдохновение', () {
      final player = playerFixture(spec: _bard(3))
          .takeDamage(5)
          .gainTempHits(4)
          .spendSpellSlot(SpellSlot.level1)
          .useExtra(ClassExtras.inspiration)
          .shortRest(0, dice: {ClassKind.bard: 2})
          .concentrate('Благословение')
          .setInspiration(true);

      final loaded = Player.fromJson(player.toJson());

      expect(loaded, player);
      expect(loaded.currentHits, player.maxHits - 5);
      expect(loaded.tempHits, 4);
      expect(loaded.currentSpellSlots[SpellSlot.level1], player.spellCells[SpellSlot.level1]! - 1);
      expect(loaded.currentExtras[ClassExtras.inspiration], player.maxExtras[ClassExtras.inspiration]! - 1);
      expect(loaded.spentHitDice, {ClassKind.bard: 2});
      expect(loaded.concentration, 'Благословение');
      expect(loaded.inspiration, isTrue);
    });

    test('спасброски от смерти, смерть и нокаут', () {
      final dying = playerFixture().takeDamage(playerFixture().maxHits).changeDeadThrow(death: 1);
      expect(Player.fromJson(dying.toJson()).deathThrows, dying.deathThrows);

      final dead = dying.takeDamage(1).takeDamage(1);
      expect(Player.fromJson(dead.toJson()).isDead, isTrue);

      final knockedOut = dying.changeDeadThrow(life: 1).changeDeadThrow(life: 2).changeDeadThrow(life: 3);
      expect(Player.fromJson(knockedOut.toJson()).isKnockedOut, isTrue);
    });

    test('кубит сохраняет каждое изменение, в том числе урон', () async {
      SharedPreferences.setMockInitialValues({});
      final source = await SpSource.init();
      final cubit = PlayerCubit(playerFixture(), source);

      cubit.takeDamage(3);
      await Future<void>.delayed(Duration.zero);

      expect(source.getSavedPlayers().single.currentHits, playerFixture().maxHits - 3);
    });
  });

  group('урон на 0 хитах', () {
    final dying =
        playerFixture().takeDamage(playerFixture().maxHits).changeDeadThrow(death: 1).changeDeadThrow(life: 1);

    test('добавляет провал и не сбрасывает успехи', () {
      final hit = dying.takeDamage(2);
      expect(hit.deathThrows.death, 2);
      expect(hit.deathThrows.life, 1);
      expect(hit.isDead, isFalse);
    });

    test('критическое попадание — два провала, третий провал — смерть', () {
      final crit = dying.takeDamage(2, critical: true);
      expect(crit.deathThrows.death, 3);
      expect(crit.isDead, isTrue);
    });

    test('урон не меньше максимума хитов убивает сразу', () {
      final killed = playerFixture().takeDamage(playerFixture().maxHits).takeDamage(playerFixture().maxHits);
      expect(killed.isDead, isTrue);
    });

    test('мёртвому урон ничего не меняет', () {
      final dead = dying.takeDamage(1, critical: true);
      expect(dead.takeDamage(5), dead);
    });
  });

  group('временные хиты', () {
    test('тратятся первыми, не складываются, пропадают после продолжительного отдыха', () {
      final player = playerFixture().gainTempHits(5);
      expect(player.gainTempHits(3).tempHits, 5);
      expect(player.gainTempHits(8).tempHits, 8);
      expect(player.gainTempHits(0).tempHits, 0);

      final absorbed = player.takeDamage(3);
      expect(absorbed.tempHits, 2);
      expect(absorbed.currentHits, player.maxHits);

      final through = player.takeDamage(7);
      expect(through.tempHits, 0);
      expect(through.currentHits, player.maxHits - 2);

      expect(player.longRest().tempHits, 0);
    });

    test('на 0 хитах урон, поглощённый временными хитами, не даёт провала', () {
      final dying = playerFixture().takeDamage(playerFixture().maxHits).gainTempHits(4);
      final hit = dying.takeDamage(3);
      expect(hit.deathThrows.death, 0);
      expect(hit.tempHits, 1);
    });
  });

  group('кости хитов', () {
    test('короткий отдых тратит кости, но не больше, чем есть', () {
      final player = playerFixture(spec: _bard(3)).takeDamage(10);
      final rested = player.shortRest(6, dice: {ClassKind.bard: 2});
      expect(rested.currentHits, player.currentHits + 6);
      expect(rested.hitDiceLeft(rested.classes.single), 1);
      expect(rested.hitDices, '1к8');
      expect(rested.maxHitDices, '3к8');

      expect(rested.shortRest(4, dice: {ClassKind.bard: 5}).spentHitDice, {ClassKind.bard: 3});
    });

    test('продолжительный отдых возвращает половину всех костей, но не меньше одной', () {
      final spent = playerFixture(spec: _bard(5)).shortRest(0, dice: {ClassKind.bard: 5});
      expect(spent.longRest().spentHitDice, {ClassKind.bard: 3});
      expect(spent.canRestOnLongRest, isTrue);

      final one = playerFixture(spec: _bard(1)).shortRest(0, dice: {ClassKind.bard: 1});
      expect(one.longRest().spentHitDice, isEmpty);
    });

    test('в мультиклассе сначала возвращаются большие кости', () {
      final fighter =
          Fighter(level: 2, isMain: false, features: const [], fightingStyles: const [FightingStyle.defence]);
      final player =
          playerFixture(spec: _bard(2)).addClass(fighter).shortRest(0, dice: {ClassKind.bard: 2, ClassKind.warrior: 2});

      // Всего 4 кости — возвращаются 2, обе к10 воина.
      expect(player.longRest().spentHitDice, {ClassKind.bard: 2});
    });
  });

  group('концентрация', () {
    final concentrating = playerFixture().concentrate('Благословение');

    test('держится при уроне и прерывается на 0 хитах и после продолжительного отдыха', () {
      expect(concentrating.takeDamage(3).concentration, 'Благословение');
      expect(concentrating.takeDamage(concentrating.maxHits).concentration, isNull);
      expect(concentrating.longRest().concentration, isNull);
      expect(concentrating.endConcentration().concentration, isNull);
    });

    test('Сл спасброска — 10 или половина урона', () {
      expect(Player.concentrationSaveDc(7), 10);
      expect(Player.concentrationSaveDc(25), 12);
      expect(
        concentrationNotice(concentrating, concentrating.takeDamage(3), 3),
        'Концентрация на «Благословение»: спасбросок Телосложения, Сл 10',
      );
      expect(
        concentrationNotice(concentrating, concentrating.takeDamage(concentrating.maxHits), concentrating.maxHits),
        'Концентрация на «Благословение» прервана',
      );
      expect(concentrationNotice(playerFixture(), playerFixture().takeDamage(3), 3), isNull);
    });
  });

  group('экран боя', () {
    Future<PlayerCubit> pump(WidgetTester tester, Player player) async {
      SharedPreferences.setMockInitialValues({});
      final cubit = PlayerCubit(player, await SpSource.init());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: BlocBuilder<PlayerCubit, Player>(
                builder: (_, player) => PlayerModel(
                  player: player,
                  child: const Column(children: [HealthSection(), RestButton()]),
                ),
              ),
            ),
          ),
        ),
      );
      return cubit;
    }

    testWidgets('урон на 0 хитах спрашивает про критическое попадание', (tester) async {
      final cubit = await pump(tester, playerFixture().takeDamage(playerFixture().maxHits));

      await tester.tap(find.byTooltip('Урон'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '3');
      await tester.pump();
      await tester.tap(find.text('Подтвердить'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Критическое'));
      await tester.pumpAndSettle();

      expect(cubit.state.deathThrows.death, 2);
    });

    testWidgets('после урона — напоминание о спасброске концентрации', (tester) async {
      await pump(tester, playerFixture().concentrate('Благословение'));

      await tester.tap(find.byTooltip('Урон'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '3');
      await tester.pump();
      await tester.tap(find.text('Подтвердить'));
      await tester.pumpAndSettle();

      expect(find.text('Концентрация на «Благословение»: спасбросок Телосложения, Сл 10'), findsOneWidget);
    });

    testWidgets('короткий отдых: потраченные кости хитов и вернувшиеся хиты', (tester) async {
      final cubit = await pump(tester, playerFixture(spec: _bard(3)).takeDamage(10));

      await tester.tap(find.text('Отдых'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Короткий отдых'));
      await tester.pumpAndSettle();
      expect(find.text('осталось 3'), findsOneWidget);
      // Без потраченных костей поле суммы недоступно; с костями отдых ждёт сумму.
      await tester.tap(find.byTooltip('Больше'));
      await tester.tap(find.byTooltip('Больше'));
      await tester.pump();
      expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Отдохнуть')).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '7');
      await tester.pump();
      await tester.tap(find.text('Отдохнуть'));
      await tester.pumpAndSettle();

      expect(cubit.state.spentHitDice, {ClassKind.bard: 2});
      expect(cubit.state.currentHits, cubit.state.maxHits - 3);
    });
  });
}
