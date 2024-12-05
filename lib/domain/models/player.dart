import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/armor.dart';
import 'package:dnd_character_list/domain/models/player_skill.dart';
import 'package:dnd_character_list/domain/models/save_throw.dart';
import 'package:dnd_character_list/domain/models/shield.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

class Player {
  final Stat strength;
  final Stat dexterity;
  final Stat constitution;
  final Stat intelligence;
  final Stat wisdom;
  final Stat charisma;
  final List<Specialization> classes;
  final List<Skill> chosenSkills;
  late final int currentHits;
  final Armor? armor;
  final Shield? shield;
  bool isDead;

  Player({
    required strength,
    required dexterity,
    required constitution,
    required intelligence,
    required wisdom,
    required charisma,
    required this.classes,
    required this.chosenSkills,
    required this.armor,
    required this.shield,
    int? hits,
    this.isDead = false,
  })  : assert(classes.isNotEmpty),
        strength = Stat(value: strength, kind: StatKind.strength),
        dexterity = Stat(value: dexterity, kind: StatKind.dexterity),
        constitution = Stat(value: constitution, kind: StatKind.constitution),
        intelligence = Stat(value: intelligence, kind: StatKind.intelligence),
        wisdom = Stat(value: wisdom, kind: StatKind.wisdom),
        charisma = Stat(value: charisma, kind: StatKind.charisma) {
    currentHits = hits ?? maxHits;
  }

  List<Stat> get stats => [
        strength,
        dexterity,
        constitution,
        intelligence,
        wisdom,
        charisma,
      ];

  int get maxHits => classes.fold(0, (previous, spec) => previous + spec.hitPoints(this));

  Player takeDamage(int value) {
    bool isDead = currentHits - value <= -maxHits;
    return _copyWith(
      currentHits: max(0, currentHits - value),
      isDead: isDead,
    );
  }

  Player heal(int health) {
    return _copyWith(
      currentHits: min(maxHits, currentHits + health),
      isDead: false,
    );
  }

  Player healFull() {
    return _copyWith(
      currentHits: maxHits,
      isDead: false,
    );
  }

  String get hitDices => classes.map((e) => '${e.level}${e.hitDice.name}').join(', ');

  int get level => classes.fold(0, (previous, spec) => previous + spec.level);

  ///Does not modify the original object!
  Player levelUp<T extends Specialization>() {
    final newClasses = classes
        .map(
          (e) => e is T && e.runtimeType != Specialization ? e.levelUp() : e,
        )
        .toList();
    return _copyWith(
      classes: newClasses,
    );
  }

  ///Does not modify the original object!
  Player addClass<T extends Specialization>(T spec) {
    if (classes.where((e) => e is T && e.runtimeType != Specialization).isNotEmpty) {
      throw "Can't duplicate existing class";
    }
    return _copyWith(
      classes: [...classes, spec],
    );
  }

  int get proficiencyBonus => (level - 1) ~/ 4 + 2;

  List<PlayerSkill> get skills => Skill.values
      .map(
        (e) => PlayerSkill(
          isChosen: chosenSkills.contains(e),
          origin: e,
          bonus: e.getBonus(this),
        ),
      )
      .toList();

  List<SaveThrow> get saveThrows {
    final mainClass = classes.firstWhere((e) => e.isMain);
    final throws = StatKind.values.map(
      (e) {
        var mainBonus = switch (e) {
          StatKind.strength => strength.bonus,
          StatKind.dexterity => dexterity.bonus,
          StatKind.constitution => constitution.bonus,
          StatKind.intelligence => intelligence.bonus,
          StatKind.wisdom => wisdom.bonus,
          StatKind.charisma => charisma.bonus,
        };

        final bool isChosen = mainClass.chosenSaveThrows.contains(e);

        if (isChosen) {
          mainBonus += proficiencyBonus;
        }
        return SaveThrow(
          bonus: mainBonus,
          origin: e,
          isChosen: isChosen,
        );
      },
    );
    return throws.toList();
  }

  int get protection {
    var maxProtection = 0;
    for (var spec in classes) {
      maxProtection = max(maxProtection, spec.getProtection(this));
    }
    if (shield != null) {
      maxProtection += shield!.defense;
    }
    return maxProtection;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Player) {
      return false;
    }

    bool isEqual = true;
    isEqual &= strength == other.strength;
    isEqual &= dexterity == other.dexterity;
    isEqual &= constitution == other.constitution;
    isEqual &= intelligence == other.intelligence;
    isEqual &= wisdom == other.wisdom;
    isEqual &= charisma == other.charisma;
    isEqual &= classes.equals(other.classes);
    isEqual &= chosenSkills.equals(other.chosenSkills);
    isEqual &= currentHits == other.currentHits;
    isEqual &= isDead == other.isDead;
    isEqual &= armor == other.armor;
    isEqual &= shield == other.shield;

    return isEqual;
  }

  @override
  int get hashCode => Object.hashAll([
        strength,
        dexterity,
        constitution,
        intelligence,
        wisdom,
        charisma,
        classes,
        chosenSkills,
        currentHits,
        isDead,
        armor,
        shield,
      ]);

  Player _copyWith({
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
    List<Specialization>? classes,
    List<Skill>? chosenSkills,
    int? currentHits,
    bool? isDead,
    Armor? Function()? armor,
    Shield? Function()? shield,
  }) =>
      Player(
        strength: strength ?? this.strength.value,
        dexterity: dexterity ?? this.dexterity.value,
        constitution: constitution ?? this.constitution.value,
        intelligence: intelligence ?? this.intelligence.value,
        wisdom: wisdom ?? this.wisdom.value,
        charisma: charisma ?? this.charisma.value,
        classes: classes ?? this.classes,
        chosenSkills: chosenSkills ?? this.chosenSkills,
        hits: currentHits ?? this.currentHits,
        isDead: isDead ?? this.isDead,
        armor: armor != null ? armor.call() : this.armor,
        shield: shield != null ? shield.call() : this.shield,
      );
}
