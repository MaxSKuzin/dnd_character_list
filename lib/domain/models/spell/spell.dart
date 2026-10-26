import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/spell/spell_time.dart';

/// Заклинание с dnd.su.
///
/// Краткие поля приходят из общего списка заклинаний, а [details] —
/// со страницы конкретного заклинания и подгружаются отдельно.
class Spell {
  /// Идентификатор на dnd.su (число в начале ссылки `/spells/204-fire-bolt/`).
  final int id;

  /// Относительная ссылка на страницу заклинания, например `/spells/204-fire-bolt/`.
  final String link;
  final String name;
  final String nameEn;
  final SpellSlot slot;
  final String school;
  final bool isConcentration;
  final bool isRitual;
  final List<SpellComponent> components;
  final SpellTime? castTimeType;

  /// Классы, у которых заклинание есть в основном списке.
  final List<ClassKind> allowedSpecializations;

  /// Классы, получающие заклинание по расширенным спискам из Tasha's Cauldron of Everything.
  final List<ClassKind> tceSpecializations;

  final SpellDetails? details;

  const Spell({
    required this.id,
    required this.link,
    required this.name,
    required this.nameEn,
    required this.slot,
    required this.school,
    required this.isConcentration,
    required this.isRitual,
    required this.components,
    required this.castTimeType,
    required this.allowedSpecializations,
    required this.tceSpecializations,
    this.details,
  });

  static int idFromLink(String link) => int.parse(RegExp(r'/spells/(\d+)').firstMatch(link)!.group(1)!);

  bool isAvailableFor(ClassKind classKind, {bool includeTce = false}) =>
      allowedSpecializations.contains(classKind) || (includeTce && tceSpecializations.contains(classKind));

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase().replaceAll('ё', 'е');
    if (normalized.isEmpty) return true;
    return name.toLowerCase().replaceAll('ё', 'е').contains(normalized) || nameEn.toLowerCase().contains(normalized);
  }

  Spell copyWith({SpellDetails? details}) => Spell(
        id: id,
        link: link,
        name: name,
        nameEn: nameEn,
        slot: slot,
        school: school,
        isConcentration: isConcentration,
        isRitual: isRitual,
        components: components,
        castTimeType: castTimeType,
        allowedSpecializations: allowedSpecializations,
        tceSpecializations: tceSpecializations,
        details: details ?? this.details,
      );

  @override
  bool operator ==(Object other) => other is Spell && other.id == id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'link': link,
        'name': name,
        'nameEn': nameEn,
        'slot': slot.name,
        'school': school,
        'isConcentration': isConcentration,
        'isRitual': isRitual,
        'components': components.map((e) => e.name).toList(),
        'castTimeType': castTimeType?.name,
        'allowedSpecializations': allowedSpecializations.map((e) => e.name).toList(),
        'tceSpecializations': tceSpecializations.map((e) => e.name).toList(),
        'details': details?.toJson(),
      };

  factory Spell.fromJson(Map<String, dynamic> json) => Spell(
        id: json['id'],
        link: json['link'],
        name: json['name'],
        nameEn: json['nameEn'],
        slot: SpellSlot.values.byName(json['slot']),
        school: json['school'],
        isConcentration: json['isConcentration'],
        isRitual: json['isRitual'],
        components: (json['components'] as List).map((e) => SpellComponent.values.byName(e)).toList(),
        castTimeType: json['castTimeType'] == null ? null : SpellTime.values.byName(json['castTimeType']),
        allowedSpecializations:
            (json['allowedSpecializations'] as List).map((e) => ClassKind.values.byName(e)).toList(),
        tceSpecializations: (json['tceSpecializations'] as List).map((e) => ClassKind.values.byName(e)).toList(),
        details: json['details'] == null ? null : SpellDetails.fromJson(json['details']),
      );
}

/// Данные со страницы заклинания в том виде, в котором они указаны на сайте.
class SpellDetails {
  /// Например «1 уровень, вызов (ритуал)».
  final String levelAndSchool;
  final String castTime;
  final String distance;
  final String components;
  final String duration;
  final String? classes;
  final String? subclasses;
  final String? source;

  /// HTML описания (как на сайте: абзацы, списки, таблицы, ссылки).
  final String descriptionHtml;

  const SpellDetails({
    required this.levelAndSchool,
    required this.castTime,
    required this.distance,
    required this.components,
    required this.duration,
    required this.classes,
    required this.subclasses,
    required this.source,
    required this.descriptionHtml,
  });

  Map<String, dynamic> toJson() => {
        'levelAndSchool': levelAndSchool,
        'castTime': castTime,
        'distance': distance,
        'components': components,
        'duration': duration,
        'classes': classes,
        'subclasses': subclasses,
        'source': source,
        'descriptionHtml': descriptionHtml,
      };

  factory SpellDetails.fromJson(Map<String, dynamic> json) => SpellDetails(
        levelAndSchool: json['levelAndSchool'],
        castTime: json['castTime'],
        distance: json['distance'],
        components: json['components'],
        duration: json['duration'],
        classes: json['classes'],
        subclasses: json['subclasses'],
        source: json['source'],
        descriptionHtml: json['descriptionHtml'],
      );
}
