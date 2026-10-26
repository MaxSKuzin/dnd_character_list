import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/inventory.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

Player _withRace(Race race) {
  final json = playerFixture(items: [InventoryItem(quantity: 1, item: greatswordFixture)]).toJson();
  return Player.fromJson({...json, 'race': race.index});
}

void main() {
  test('dwarf tiefling has tiefling traits in a halfling body', () {
    const race = Race.dwarfTiefling;

    expect(race.statBonuses, Race.tiefling.statBonuses);
    expect(race.knownLanguages, [Language.common, Language.infernal]);
    expect(race.spellForLevel(1), {SpellSlot.conspiracy: '/spells/thaumaturgy'});
    expect(race.peculiarities.map((e) => e.name),
        ['Адское сопротивление', 'Темное зрение', 'Маленький размер', 'Проворство полурослика']);
    expect((race.speed, race.isSmall), (25, true));
    expect(Race.tiefling.isSmall, isFalse);
  });

  test('race speed and heavy weapon disadvantage', () {
    final tiefling = _withRace(Race.tiefling).equipMainWeapon(greatswordFixture);
    final dwarf = _withRace(Race.dwarfTiefling).equipMainWeapon(greatswordFixture);

    expect(tiefling.speed, 30);
    expect(dwarf.speed, 25);
    expect(dwarf.charisma.value, tiefling.charisma.value);
    expect(dwarf.stats[StatKind.intelligence]!.value, tiefling.stats[StatKind.intelligence]!.value);
    expect(tiefling.attacks.single.hasDisadvantage, isFalse);
    expect(dwarf.attacks.single.hasDisadvantage, isTrue);
    expect(dwarf.attackWith(daggerFixture, WeaponSlot.mainHand).hasDisadvantage, isFalse);
  });
}
