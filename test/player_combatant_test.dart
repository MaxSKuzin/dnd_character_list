import 'package:dnd_character_list/data/session/player_combatant.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_session/dnd_session.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  test('мастеру уходят только боевые данные персонажа', () {
    final player = playerFixture();
    final profile = player.combatantProfile;

    expect(profile.name, 'Тест');
    expect(profile.classes.single.kind, 'bard');
    expect(profile.classes.single.name, 'Бард');
    expect(profile.level, 1);
    expect(profile.abilities[Ability.dexterity], player.dexterity.value);
    expect(profile.savingThrows[Ability.charisma], player.saveThrows.last.bonus);
    expect(profile.armorClass, player.protection);
    expect(profile.maxHits, player.maxHits);
    expect(profile.initiative, player.initiative);
    expect(profile.passivePerception, player.passivePerception);

    // Ни инвентаря, ни описаний, ни внешности.
    final json = profile.toJson();
    for (final key in ['inventory', 'personality', 'background', 'features']) {
      expect(json, isNot(contains(key)));
    }
  });

  test('состояние: хиты, ячейки без заговоров и ресурсы классов', () {
    final player = playerFixture().takeDamage(3).spendSpellSlot(SpellSlot.level1).useExtra(ClassExtras.inspiration);
    final state = player.combatantState;

    expect(state.currentHits, player.maxHits - 3);
    expect(state.spellSlots.keys, [1]);
    expect(state.spellSlots[1]!.current, player.spellCells[SpellSlot.level1]! - 1);
    expect(state.counters[ClassExtras.inspiration.name]!.current, player.maxExtras[ClassExtras.inspiration]! - 1);
    expect(CombatantState.fromJson(state.toJson()), state);
  });
}
