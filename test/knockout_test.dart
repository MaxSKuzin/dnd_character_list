import 'package:dnd_character_list/data/session/player_combatant.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  test('три успеха спасбросков от смерти — 1 хит и нокаут', () {
    var player = playerFixture().takeDamage(playerFixture().maxHits);
    expect(player.currentHits, 0);

    player = player.changeDeadThrow(life: 1).changeDeadThrow(death: 1).changeDeadThrow(life: 2);
    expect(player.isKnockedOut, isFalse);
    player = player.changeDeadThrow(life: 3);

    expect(player.currentHits, 1);
    expect(player.isKnockedOut, isTrue);
    expect(player.deathThrows.life, 0);
    expect(player.deathThrows.death, 0);
    expect(player.combatantState.isKnockedOut, isTrue);
  });

  test('из нокаута выводят союзник, лечение и отдых; урон снова опускает к смерти', () {
    final knockedOut = playerFixture()
        .takeDamage(playerFixture().maxHits)
        .changeDeadThrow(life: 1)
        .changeDeadThrow(life: 2)
        .changeDeadThrow(life: 3);

    expect(knockedOut.wakeUp().isKnockedOut, isFalse);
    expect(knockedOut.wakeUp().currentHits, 1);
    expect(knockedOut.heal(3).isKnockedOut, isFalse);
    expect(knockedOut.longRest().isKnockedOut, isFalse);

    final hit = knockedOut.takeDamage(4);
    expect(hit.isKnockedOut, isFalse);
    expect(hit.currentHits, 0);
    expect(hit.isDead, isFalse);
  });

  test('третий провал — смерть, а не нокаут', () {
    final player = playerFixture()
        .takeDamage(playerFixture().maxHits)
        .changeDeadThrow(death: 1)
        .changeDeadThrow(death: 2)
        .changeDeadThrow(death: 3);
    expect(player.isDead, isTrue);
    expect(player.isKnockedOut, isFalse);
  });
}
