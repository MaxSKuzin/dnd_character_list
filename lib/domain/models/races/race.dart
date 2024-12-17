import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/races/tiefling.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

abstract class Race {
  Race();

  String get name;

  int get speed;

  Map<StatKind, int> get statBonuses;

  List<Peculiarity> get peculiarities;

  List<String> get languages;

  Map<String, dynamic> toJson() => {
        'type': runtimeType.toString(),
      };

  factory Race.fromJson(Map<String, dynamic> json) => switch (json['type']) {
        'Tiefling' => Tiefling.fromJson(json),
        _ => throw 'No such race',
      };
}
