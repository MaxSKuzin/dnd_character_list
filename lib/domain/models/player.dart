import 'dart:math';

import 'package:dnd_character_list/domain/models/specialization.dart';
import 'package:dnd_character_list/domain/models/stat.dart';

class Player {
  final Stat _constitution;
  final List<Specialization> _classes;

  late int _currentHits = maxHits;

  Player({
    required Stat constitution,
    required List<Specialization> classes,
  })  : _classes = classes,
        _constitution = constitution;

  Stat get constitution => _constitution;

  List<Specialization> get classes => _classes;

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
      throw "Can't duplocate existing class";
    }
    _classes.add(spec);
  }
}
