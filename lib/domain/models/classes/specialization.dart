import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor_proficiency.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/combat.dart';
import 'package:dnd_character_list/domain/models/classes/barbarian.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/paladin.dart';
import 'package:dnd_character_list/domain/models/classes/thief.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

abstract class Specialization {
  final bool isMain;
  final int level;

  Specialization({
    required this.level,
    required this.isMain,
  });

  FightingStyle? get fightingStyle => null;

  String get name;

  int get startHealth;

  int get healthPerLevel;

  /// КД без щита: 10 + Ловкость без доспеха; лёгкий доспех + Ловкость; средний + Ловкость (не больше 2);
  /// тяжёлый — без Ловкости.
  ArmorClass armorClass(Player player) {
    final dexterity = player.dexterity.bonus;
    final armor = player.armor;
    if (armor == null) return ArmorClass.of([('Без доспеха', 10), ('Ловкость', dexterity)]);
    final limit = armor.dexterityLimit;
    return ArmorClass.of([
      (armor.name, armor.protection),
      if (limit != 0) ('Ловкость', limit == null ? dexterity : min(dexterity, limit)),
    ]);
  }

  /// Владение оружием.
  WeaponProficiency get weaponProficiency => WeaponProficiency.none;

  int additionalDamage(Player player) => 0;

  int hitPoints(Player player) {
    return (isMain ? startHealth : 0) + player.constitution.bonus * level + healthPerLevel * (level - 1);
  }

  Dice get hitDice;

  List<StatKind> get chosenSaveThrows;

  double get magicLevelMultiplier => classKind.magicLevelMultiplier;

  StatKind? get spellKind => null;

  List<ClassExtras> get classExtras => [];

  String classExtraDescription(ClassExtras extra) => '';

  int getClassExtrasCount(Player player, ClassExtras extra) => 0;

  Map<StatKind, int> get statBonuses;

  List<Spell> get knownSpells => [];

  List<Peculiarity> get abilities => [];

  ClassKind get classKind;

  bool get canUseTwoWeapons => false;

  List<ArmorProficiency> get armorProficiencies => [];

  /// Черты, взятые вместо увеличения характеристик.
  List<ChosenFeat> get feats => [];

  /// Навыки с удвоенным бонусом мастерства.
  List<Skill> get expertise => [];

  /// Навыки, которыми класс наделяет помимо выбранных при создании (например, у коллегии знаний).
  List<Skill> get grantedSkills => [];

  /// «Мастер на все руки»: половина бонуса мастерства к проверкам без владения.
  bool get hasJackOfAllTrades => false;

  @override
  bool operator ==(Object other) {
    if (other is Specialization) {
      return name == other.name &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          isMain == other.isMain &&
          spellKind == other.spellKind &&
          knownSpells.equals(other.knownSpells);
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([
        name,
        runtimeType,
        level,
        isMain,
        spellKind,
        knownSpells,
      ]);

  Map<String, dynamic> toJson() => {
        'type': runtimeType.toString(),
      };

  factory Specialization.fromJson(Map<String, dynamic> json) => switch (json['type']) {
        'Bard' => Bard.fromJson(json),
        'Barbarian' => Barbarian.fromJson(json),
        'Paladin' => Paladin.fromJson(json),
        'Thief' => Thief.fromJson(json),
        _ => throw 'No such class',
      };
}
