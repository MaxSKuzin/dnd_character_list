import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/cur_max.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/player_skill.dart';
import 'package:dnd_character_list/domain/models/save_throw.dart';
import 'package:dnd_character_list/domain/models/spell_stat.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
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
    return update;
  }

  static List<Stat> stats(BuildContext context) {
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
}
