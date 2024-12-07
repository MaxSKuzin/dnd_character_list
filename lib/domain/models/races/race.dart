import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

abstract class Race {
  String get name;

  int get speed;

  Map<StatKind, int> get statBonuses;

  List<Peculiarity> get peculiarities;

  List<String> get languages;
}
