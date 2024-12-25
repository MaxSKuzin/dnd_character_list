import 'package:dnd_character_list/domain/models/bard_collegiums/swords_collegium.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';

abstract class BardCollegium {
  String get description;
  String get name;
  List<Peculiarity> getAbilities(int level);

  Map<String, dynamic> toJson() => {
        'type': runtimeType.toString(),
      };

  static BardCollegium fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'SwordsCollegium':
        return SwordsCollegium.fromJson(json);
      default:
        throw ArgumentError('Unknown collegium type: ${json['type']}');
    }
  }
}
