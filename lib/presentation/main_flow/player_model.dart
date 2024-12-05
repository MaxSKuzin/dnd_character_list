import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/player_skill.dart';
import 'package:dnd_character_list/domain/models/save_throw.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:flutter/material.dart';

enum PlayerAspect {
  stats,
  health,
  skills,
  saveThrows,
  profiencyBonus,
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
    if (dependencies.contains(PlayerAspect.stats)) {
      return oldWidget.player.charisma != player.charisma ||
          oldWidget.player.constitution != player.constitution ||
          oldWidget.player.dexterity != player.dexterity ||
          oldWidget.player.intelligence != player.intelligence ||
          oldWidget.player.strength != player.strength ||
          oldWidget.player.wisdom != player.wisdom;
    }
    if (dependencies.contains(PlayerAspect.health)) {
      return oldWidget.player.currentHits != player.currentHits ||
          oldWidget.player.maxHits != player.maxHits ||
          oldWidget.player.isDead != player.isDead;
    }
    if (dependencies.contains(PlayerAspect.skills)) {
      return !oldWidget.player.skills.equals(player.skills);
    }
    if (dependencies.contains(PlayerAspect.saveThrows)) {
      return !oldWidget.player.saveThrows.equals(player.saveThrows);
    }
    if (dependencies.contains(PlayerAspect.profiencyBonus)) {
      return oldWidget.player.proficiencyBonus != player.proficiencyBonus;
    }
    return false;
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

  static (int, int) health(BuildContext context) {
    final player = InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.health)!.player;
    return (player.currentHits, player.maxHits);
  }

  static bool isDead(BuildContext context) {
    return InheritedModel.inheritFrom<PlayerModel>(context, aspect: PlayerAspect.health)!.player.isDead;
  }
}
