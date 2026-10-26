import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart';

/// Предыстория с ttg.club (например, https://5e14.ttg.club/backgrounds/entertainer).
class Background {
  final int id;
  final String link;
  final String name;
  final String nameEn;

  /// Полное описание в html, как на сайте.
  final String descriptionHtml;

  final List<Skill> skills;
  final List<ToolProficiencyOption> tools;
  final int languagesCount;

  /// Снаряжение без денег, по одному предмету на строку.
  final List<String> equipment;
  final int gold;

  final String? featureName;
  final String? featureHtml;

  /// Таблицы персонализации: черты характера, идеалы, привязанности, слабости и прочие.
  final List<PersonalityTable> tables;

  const Background({
    required this.id,
    required this.link,
    required this.name,
    required this.nameEn,
    required this.descriptionHtml,
    required this.skills,
    required this.tools,
    required this.languagesCount,
    required this.equipment,
    required this.gold,
    required this.featureName,
    required this.featureHtml,
    required this.tables,
  });

  @override
  bool operator ==(Object other) => other is Background && other.id == id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'link': link,
        'name': name,
        'nameEn': nameEn,
        'descriptionHtml': descriptionHtml,
        'skills': skills.map((e) => e.name).toList(),
        'tools': tools.map((e) => e.toJson()).toList(),
        'languagesCount': languagesCount,
        'equipment': equipment,
        'gold': gold,
        'featureName': featureName,
        'featureHtml': featureHtml,
        'tables': tables.map((e) => e.toJson()).toList(),
      };

  factory Background.fromJson(Map<String, dynamic> json) => Background(
        id: json['id'],
        link: json['link'],
        name: json['name'],
        nameEn: json['nameEn'],
        descriptionHtml: json['descriptionHtml'],
        skills: (json['skills'] as List).map((e) => Skill.values.byName(e)).toList(),
        tools: (json['tools'] as List).map((e) => ToolProficiencyOption.fromJson(e)).toList(),
        languagesCount: json['languagesCount'],
        equipment: (json['equipment'] as List).cast<String>(),
        gold: json['gold'],
        featureName: json['featureName'],
        featureHtml: json['featureHtml'],
        tables: (json['tables'] as List).map((e) => PersonalityTable.fromJson(e)).toList(),
      );
}

enum PersonalityTableKind {
  trait,
  ideal,
  bond,
  flaw,

  /// Дополнительные таблицы предыстории: амплуа, специализация и т.п.
  other;
}

class PersonalityTable {
  /// Заголовок столбца, например «Черта характера» или «Амплуа».
  final String title;
  final PersonalityTableKind kind;
  final List<String> options;

  const PersonalityTable({
    required this.title,
    required this.kind,
    required this.options,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'kind': kind.name,
        'options': options,
      };

  factory PersonalityTable.fromJson(Map<String, dynamic> json) => PersonalityTable(
        title: json['title'],
        kind: PersonalityTableKind.values.byName(json['kind']),
        options: (json['options'] as List).cast<String>(),
      );
}
