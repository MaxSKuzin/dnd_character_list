import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';

class Tiefling extends Race {
  @override
  final Map<StatKind, int> statBonuses;

  final List<Peculiarity> specificPeculiarities;

  Tiefling({
    this.name = 'Тифлинг',
    this.statBonuses = const {
      StatKind.charisma: 2,
      StatKind.intelligence: 1,
    },
    this.specificPeculiarities = const [],
  });

  @override
  List<String> languages = ['Общий', 'Инфернальный'];

  @override
  String name;

  List<Peculiarity> basePeculiarities = [
    const Peculiarity(
      name: 'Адское сопротивление',
      description: 'Вы имеете сопротивление к урону от огня',
    ),
    const Peculiarity(
      name: 'Темное зрение',
      description: 'Вы видите в темноте на 60 футов',
    ),
    const Peculiarity(
      name: 'Дьявольское наследие',
      description:
          'Начиная с 3-го уровня, вы можете один раз наложить заклинание адское возмездие [hellish rebuke] как заклинание 2-го уровня с помощью этой особенности. Начиная с 5-го уровня, вы также можете накладывать заклинание тьма [darkness] с помощью этой особенности. После накладывания одного из этих заклинаний с помощью особенности вы должны закончить продолжительный отдых, прежде чем сможете вновь наложить это заклинание таким образом. Кроме того, вы знаете заговор чудотворство',
    ),
  ];

  @override
  int speed = 30;

  @override
  late List<Peculiarity> peculiarities = [
    ...basePeculiarities,
    ...specificPeculiarities,
  ];

  @override
  bool operator ==(Object other) {
    if (other is! Tiefling) {
      return false;
    }
    bool isEqual = true;
    isEqual &= name == other.name;
    isEqual &= speed == other.speed;
    isEqual &= peculiarities.equals(other.peculiarities);
    statBonuses.forEach((key, value) {
      if (other.statBonuses[key] != value) {
        isEqual = false;
      }
    });
    return isEqual;
  }

  @override
  int get hashCode => Object.hashAll([
        name,
        speed,
        statBonuses,
        ...peculiarities,
      ]);

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'name': name,
        'statBonuses': statBonuses.map((key, value) => MapEntry(key.toJson(), value)),
        'specificPeculiarities': specificPeculiarities.map((e) => e.toJson()).toList(),
      };

  factory Tiefling.fromJson(Map<String, dynamic> json) => Tiefling(
        name: json['name'],
        statBonuses: (json['statBonuses'] as Map).map((key, value) => MapEntry(StatKind.fromJson(key), value)),
        specificPeculiarities: (json['specificPeculiarities'] as List).map((e) => Peculiarity.fromJson(e)).toList(),
      );

  factory Tiefling.faerun() {
    return Tiefling(
      name: 'Тифлинг Фаэруна',
      statBonuses: {
        StatKind.dexterity: 2,
        StatKind.intelligence: 1,
      },
      specificPeculiarities: [
        const Peculiarity(
          name: 'Крылатый',
          description: 'У персонажа из лопаток вырастают перепончатые крылья. '
              'Персонаж получает скоростью полёта 30 футов, если не носит тяжёлый доспех.',
        ),
      ],
    );
  }
}
