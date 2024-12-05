import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/player_skill.dart';
import 'package:dnd_character_list/domain/models/save_throw.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/specialization.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

class Player {
  final Stat _strength;
  final Stat _dexterity;
  final Stat _constitution;
  final Stat _intelligence;
  final Stat _wisdom;
  final Stat _charisma;
  final List<Specialization> _classes;
  final List<Skill> _chosenSkills;
  late final int currentHits;

  Player({
    required int strength,
    required int dexterity,
    required int constitution,
    required int intelligence,
    required int wisdom,
    required int charisma,
    required List<Specialization> classes,
    required List<Skill> chosenSkills,
    int? hits,
  })  : assert(classes.isNotEmpty),
        _classes = classes,
        _strength = Stat(value: strength, kind: StatKind.strength),
        _dexterity = Stat(value: dexterity, kind: StatKind.dexterity),
        _constitution = Stat(value: constitution, kind: StatKind.constitution),
        _intelligence = Stat(value: intelligence, kind: StatKind.intelligence),
        _wisdom = Stat(value: wisdom, kind: StatKind.wisdom),
        _charisma = Stat(value: charisma, kind: StatKind.charisma),
        _chosenSkills = chosenSkills {
    currentHits = hits ?? maxHits;
  }

  Stat get strength => _strength;
  Stat get dexterity => _dexterity;
  Stat get constitution => _constitution;
  Stat get intelligence => _intelligence;
  Stat get wisdom => _wisdom;
  Stat get charisma => _charisma;

  List<Stat> get stats => [_strength, _dexterity, _constitution, _intelligence, _wisdom, _charisma];

  List<Specialization> get classes => _classes;

  List<Skill> get chosenSkills => _chosenSkills;

  int get maxHits => _classes.fold(0, (previous, spec) => previous + spec.hitPoints(this));

  Player takeDamage(int value) {
    return _copyWith(
      currentHits: max(0, currentHits - value),
    );
  }

  Player heal(int health) {
    return _copyWith(
      currentHits: max(maxHits, currentHits + health),
    );
  }

  Player healFull() {
    return _copyWith(
      currentHits: maxHits,
    );
  }

  String get hitDices => _classes.map((e) => '${e.level}${e.hitDice.name}').join(', ');

  int get level => _classes.fold(0, (previous, spec) => previous + spec.level);

  ///Does not modify the original object!
  Player levelUp<T extends Specialization>() {
    final newClasses = _classes.map((e) => e is T ? e.levelUp() : e).toList();
    return _copyWith(
      classes: newClasses,
    );
  }

  ///Does not modify the original object!
  Player addClass<T extends Specialization>(T spec) {
    if (_classes.whereType<T>().isNotEmpty) {
      throw "Can't duplicate existing class";
    }
    return _copyWith(
      classes: [..._classes, spec],
    );
  }

  int get proficiencyBonus => (level - 1) ~/ 4 + 2;

  List<PlayerSkill> get skills => Skill.values
      .map(
        (e) => PlayerSkill(
          isChosen: _chosenSkills.contains(e),
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

  @override
  bool operator ==(Object other) {
    if (other is! Player) {
      return false;
    }

    bool isEqual = true;
    isEqual &= _strength == other._strength;
    isEqual &= _dexterity == other._dexterity;
    isEqual &= _constitution == other._constitution;
    isEqual &= _intelligence == other._intelligence;
    isEqual &= _wisdom == other._wisdom;
    isEqual &= _charisma == other._charisma;
    isEqual &= _classes.equals(other._classes);
    isEqual &= _chosenSkills.equals(other._chosenSkills);
    isEqual &= currentHits == other.currentHits;

    return isEqual;
  }

  @override
  int get hashCode => Object.hashAll([
        _strength,
        _dexterity,
        _constitution,
        _intelligence,
        _wisdom,
        _charisma,
        _classes,
        _chosenSkills,
        currentHits,
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
      );
}
