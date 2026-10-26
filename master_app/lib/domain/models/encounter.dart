import 'package:dnd_master/domain/bestiary.dart';
import 'package:dnd_master/domain/models/monster.dart';

/// Монстры одного вида в боевой ситуации: «Гоблин × 4».
class EncounterMonster {
  final String monsterId;
  final int count;

  const EncounterMonster({required this.monsterId, required this.count});

  MonsterTemplate? get template => Bestiary.byId(monsterId);

  Map<String, dynamic> toJson() => {'monsterId': monsterId, 'count': count};

  factory EncounterMonster.fromJson(Map<String, dynamic> json) =>
      EncounterMonster(monsterId: json['monsterId'], count: json['count']);
}

/// Заранее подготовленная боевая ситуация: «Засада на тракте» — 4 гоблина и багбир.
class Encounter {
  final String id;
  final String name;

  /// Заметки мастера: местность, тактика, награда.
  final String notes;
  final List<EncounterMonster> monsters;

  const Encounter({required this.id, required this.name, this.notes = '', this.monsters = const []});

  /// Опыт за всех монстров ситуации.
  int get experience => monsters.fold(0, (sum, e) => sum + (e.template?.experience ?? 0) * e.count);

  int get monsterCount => monsters.fold(0, (sum, e) => sum + e.count);

  Encounter copyWith({String? name, String? notes, List<EncounterMonster>? monsters}) =>
      Encounter(id: id, name: name ?? this.name, notes: notes ?? this.notes, monsters: monsters ?? this.monsters);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'notes': notes,
    'monsters': monsters.map((e) => e.toJson()).toList(),
  };

  /// Монстры, которых больше нет в бестиарии, отбрасываются.
  factory Encounter.fromJson(Map<String, dynamic> json) => Encounter(
    id: json['id'],
    name: json['name'],
    notes: json['notes'] ?? '',
    monsters: (json['monsters'] as List)
        .map((e) => EncounterMonster.fromJson(e))
        .where((e) => e.template != null)
        .toList(),
  );
}
