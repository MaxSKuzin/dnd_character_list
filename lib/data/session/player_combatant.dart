import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_session/dnd_session.dart';

/// Персонаж в виде, который уходит мастеру: только данные, влияющие на бой.
extension PlayerCombatant on Player {
  CombatantProfile get combatantProfile => CombatantProfile(
        name: personality.name,
        classes: classes.map((e) => CombatClass(kind: e.classKind.name, name: e.name, level: e.level)).toList(),
        abilities: {for (final stat in stats.values) Ability.values.byName(stat.kind.name): stat.value},
        savingThrows: {for (final save in saveThrows) Ability.values.byName(save.origin.name): save.bonus},
        armorClass: protection,
        maxHits: maxHits,
        initiative: initiative,
        speed: speed,
        passivePerception: passivePerception,
      );

  CombatantState get combatantState {
    final maxExtras = this.maxExtras;
    return CombatantState(
      currentHits: currentHits,
      deathSuccesses: deathThrows.life,
      deathFailures: deathThrows.death,
      isDead: isDead,
      spellSlots: {
        for (final slot in spellSlotLevels.where((e) => e != SpellSlot.conspiracy))
          slot.level: CombatCounter(current: currentSpellSlots[slot] ?? 0, max: spellCells[slot] ?? 0),
      },
      counters: {
        for (final extra in maxExtras.entries)
          extra.key.name: CombatCounter(current: currentExtras[extra.key] ?? 0, max: extra.value),
      },
    );
  }
}
