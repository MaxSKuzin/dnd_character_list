import 'dart:math';

import 'package:collection/collection.dart';
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
  final List<Skill> _skills;
  final List<SaveThrow> _saveThrows;

  late int _currentHits = maxHits;

  Player({
    required int strength,
    required int dexterity,
    required int constitution,
    required int intelligence,
    required int wisdom,
    required int charisma,
    required List<Specialization> classes,
    required List<Skill> skills,
  })  : assert(classes.isNotEmpty),
        _classes = classes,
        _strength = Stat(value: strength, kind: StatKind.strength),
        _dexterity = Stat(value: dexterity, kind: StatKind.dexterity),
        _constitution = Stat(value: constitution, kind: StatKind.constitution),
        _intelligence = Stat(value: intelligence, kind: StatKind.intelligence),
        _wisdom = Stat(value: wisdom, kind: StatKind.wisdom),
        _charisma = Stat(value: charisma, kind: StatKind.charisma),
        _saveThrows = getSaveThrows(classes),
        _skills = skills;

  Stat get strength => _strength;
  Stat get dexterity => _dexterity;
  Stat get constitution => _constitution;
  Stat get intelligence => _intelligence;
  Stat get wisdom => _wisdom;
  Stat get charisma => _charisma;

  List<Specialization> get classes => _classes;

  List<Skill> get skills => _skills.sorted(
        (a, b) => a.name.compareTo(b.name),
      );

  List<SaveThrow> get saveThrows => _saveThrows;

  int get maxHits => _classes.fold(0, (previous, spec) => previous + spec.hitPoints(this));

  int get currentHits => _currentHits;

  void takeDamage(int value) => _currentHits = max(0, _currentHits - value);

  void restoreHealthPart() => _currentHits = min(maxHits, _currentHits + _getHitsToRestore());

  void restoreHealthFull() => _currentHits = maxHits;

  String get hitDices => _classes.map((e) => '${e.level}${e.hitDice.name}').join(', ');

  int _getHitsToRestore() => _classes.fold(0, (previous, spec) => previous + spec.hitsToRestore);

  int get level => _classes.fold(0, (previous, spec) => previous + spec.level);

  void levelUp<T extends Specialization>() {
    for (var element in _classes.whereType<T>()) {
      element.levelUp();
    }
  }

  void addClass<T extends Specialization>(T spec) {
    if (_classes.whereType<T>().isNotEmpty) {
      throw "Can't duplicate existing class";
    }
    _classes.add(spec);
  }

  int get proficiencyBonus => (level - 1) ~/ 4 + 2;

  static List<SaveThrow> getSaveThrows(List<Specialization> classes) {
    final mainClass = classes.firstWhere((e) => e.isMain);
    final throws = StatKind.values.map(
      (e) => SaveThrow(
        origin: e,
        isChosen: mainClass.chosenSaveThrows.contains(e),
      ),
    );
    return throws.toList();
  }
}
