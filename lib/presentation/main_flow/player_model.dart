import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/cur_max.dart';
import 'package:dnd_character_list/domain/models/death_throws.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/player_skill.dart';
import 'package:dnd_character_list/domain/models/save_throw.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_stat.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/weapon.dart';
import 'package:flutter/material.dart';

enum PlayerAspect {
  stats,
  health,
  skills,
  saveThrows,
  profiencyBonus,
  protection,
  weapons,
  mana,
  spellKinds,
  deathThrows,
  extras,
  classes,
  spells,
}

class PlayerModel extends InheritedModel<PlayerAspect> {
  final Player player;

  const PlayerModel({
    super.key,
    required super.child,
    required this.player,
  });

  @override
  bool updateShouldNotify(PlayerModel oldWidget) {
    return oldWidget.player != player;
  }

  @override
  bool updateShouldNotifyDependent(PlayerModel oldWidget, Set<PlayerAspect> dependencies) {
    bool update = false;
    if (dependencies.contains(PlayerAspect.stats)) {
      update |= oldWidget.player.charisma != player.charisma ||
          oldWidget.player.constitution != player.constitution ||
          oldWidget.player.dexterity != player.dexterity ||
          oldWidget.player.intelligence != player.intelligence ||
          oldWidget.player.strength != player.strength ||
          oldWidget.player.wisdom != player.wisdom;
    }
    if (dependencies.contains(PlayerAspect.health)) {
      update |= oldWidget.player.currentHits != player.currentHits ||
          oldWidget.player.maxHits != player.maxHits ||
          oldWidget.player.isDead != player.isDead;
    }
    if (dependencies.contains(PlayerAspect.mana)) {
      update |= oldWidget.player.currentMana != player.currentMana || oldWidget.player.maxMana != player.maxMana;
    }
    if (dependencies.contains(PlayerAspect.skills)) {
      update |= !oldWidget.player.skills.equals(player.skills);
    }
    if (dependencies.contains(PlayerAspect.saveThrows)) {
      update |= !oldWidget.player.saveThrows.equals(player.saveThrows);
    }
    if (dependencies.contains(PlayerAspect.profiencyBonus)) {
      update |= oldWidget.player.proficiencyBonus != player.proficiencyBonus;
    }
    if (dependencies.contains(PlayerAspect.protection)) {
      update |= oldWidget.player.protection != player.protection;
    }
    if (dependencies.contains(PlayerAspect.weapons)) {
      update |= !oldWidget.player.weapons.equals(player.weapons);
    }
    if (dependencies.contains(PlayerAspect.spellKinds)) {
      update |= !oldWidget.player.spellKinds.equals(player.spellKinds);
    }
    if (dependencies.contains(PlayerAspect.classes)) {
      update |= !oldWidget.player.classes.equals(player.classes);
    }
    if (dependencies.contains(PlayerAspect.spells)) {
      player.spells.forEach((key, value) {
        update |= !(oldWidget.player.spells[key] ?? []).equals(value);
      });
    }
    if (dependencies.contains(PlayerAspect.deathThrows)) {
      update |= oldWidget.player.deathThrows != player.deathThrows;
    }
    if (dependencies.contains(PlayerAspect.extras)) {
      player.currentExtras.forEach((key, value) {
        update |= oldWidget.player.currentExtras[key] != value;
      });
    }
    return update;
  }

  static Map<StatKind, Stat> stats(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.stats)!.player.stats;
  }

  static List<PlayerSkill> skills(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.skills)!.player.skills;
  }

  static int proficiencyBonus(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.profiencyBonus)!
        .player
        .proficiencyBonus;
  }

  static List<SaveThrow> saveThrows(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.saveThrows)!.player.saveThrows;
  }

  static Player getPlayer(BuildContext context) {
    return context.getInheritedWidgetOfExactType<PlayerModel>()!.player;
  }

  static CurMax<int> health(BuildContext context) {
    final player = InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.health)!.player;
    return CurMax(current: player.currentHits, max: player.maxHits);
  }

  static CurMax<int> mana(BuildContext context) {
    final player = InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.mana)!.player;
    return CurMax(current: player.currentMana, max: player.maxMana);
  }

  static bool isDead(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.health)!.player.isDead;
  }

  static int protection(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.protection)!.player.protection;
  }

  static List<Weapon> weapons(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.weapons)!.player.weapons;
  }

  static List<SpellStat> spellStats(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.spellKinds)!.player.spellKinds;
  }

  static DeathThrows deathThrows(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.deathThrows)!.player.deathThrows;
  }

  static Map<ClassExtras, int> extras(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.extras)!.player.currentExtras;
  }

  static List<Specialization> classes(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.classes)!.player.classes;
  }

  static Map<Specialization, List<Spell>> spells(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.spells)!.player.spells;
  }
}
