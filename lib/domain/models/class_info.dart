import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/starting_equipment.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart';

/// Описание класса с ttg.club (например, https://5e14.ttg.club/classes/bard).
class ClassInfo {
  /// Ссылка на класс, например `/classes/bard`.
  final String link;
  final String name;
  final String nameEn;

  /// Разделы «Хиты», «Владение» и «Снаряжение» в html, как на сайте.
  final String hitPointsHtml;
  final String proficienciesHtml;
  final String equipmentHtml;

  /// Стартовое снаряжение: в каждой строке выбирается один вариант.
  final List<StartingEquipmentChoice> startingEquipment;

  /// Рекомендации из раздела «Быстрое создание».
  final String? quickBuildHtml;

  final List<StatKind> savingThrows;

  /// Сколько навыков выбирается на 1 уровне.
  final int skillsCount;

  /// Навыки, из которых выбирают; пустой список — любые.
  final List<Skill> skillOptions;
  final List<ToolProficiencyOption> tools;

  final List<ClassLevel> levels;
  final List<ClassFeature> features;
  final List<Subclass> subclasses;

  /// Уровень, на котором выбирается подкласс: самый ранний уровень умений подклассов
  /// (у чародея — 1, у барда — 3). `null` — подклассов нет.
  final int? subclassLevel;

  /// Как называются подклассы: «Коллегии бардов», «Происхождение чародея».
  final String? subclassTitle;

  const ClassInfo({
    required this.link,
    required this.name,
    required this.nameEn,
    required this.hitPointsHtml,
    required this.proficienciesHtml,
    required this.equipmentHtml,
    required this.startingEquipment,
    required this.quickBuildHtml,
    required this.savingThrows,
    required this.skillsCount,
    required this.skillOptions,
    required this.tools,
    required this.levels,
    required this.features,
    required this.subclasses,
    required this.subclassLevel,
    this.subclassTitle,
  });

  ClassLevel level(int level) => levels.firstWhere((e) => e.level == level);

  ClassFeature? feature(String id) => features.firstWhereOrNull((e) => e.id == id);

  Subclass? subclass(String id) => subclasses.firstWhereOrNull((e) => e.id == id);

  /// Умения, которые класс даёт на указанном уровне. Опциональные умения TCE всегда включены.
  List<ClassFeature> featuresAt(int level) =>
      this.level(level).features.map((e) => feature(e.id)).nonNulls.where((e) => e.level == level).toList();

  /// Значение из названия умения в таблице на этом уровне, например «к8» в «Вдохновение барда (к8)».
  String? featureValueAt(String featureId, int level) {
    for (final row in levels.where((e) => e.level <= level).toList().reversed) {
      final title = row.features.firstWhereOrNull((e) => e.id == featureId)?.title;
      final value = title == null ? null : RegExp(r'\(([^)]+)\)').firstMatch(title)?.group(1);
      if (value != null) return value;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'link': link,
        'name': name,
        'nameEn': nameEn,
        'hitPointsHtml': hitPointsHtml,
        'proficienciesHtml': proficienciesHtml,
        'equipmentHtml': equipmentHtml,
        'startingEquipment': startingEquipment.map((e) => e.toJson()).toList(),
        'quickBuildHtml': quickBuildHtml,
        'savingThrows': savingThrows.map((e) => e.name).toList(),
        'skillsCount': skillsCount,
        'skillOptions': skillOptions.map((e) => e.name).toList(),
        'tools': tools.map((e) => e.toJson()).toList(),
        'levels': levels.map((e) => e.toJson()).toList(),
        'features': features.map((e) => e.toJson()).toList(),
        'subclasses': subclasses.map((e) => e.toJson()).toList(),
        'subclassLevel': subclassLevel,
        'subclassTitle': subclassTitle,
      };

  factory ClassInfo.fromJson(Map<String, dynamic> json) => ClassInfo(
        link: json['link'],
        name: json['name'],
        nameEn: json['nameEn'],
        hitPointsHtml: json['hitPointsHtml'],
        proficienciesHtml: json['proficienciesHtml'],
        equipmentHtml: json['equipmentHtml'],
        startingEquipment: (json['startingEquipment'] as List).map((e) => StartingEquipmentChoice.fromJson(e)).toList(),
        quickBuildHtml: json['quickBuildHtml'],
        savingThrows: (json['savingThrows'] as List).map((e) => StatKind.values.byName(e)).toList(),
        skillsCount: json['skillsCount'],
        skillOptions: (json['skillOptions'] as List).map((e) => Skill.values.byName(e)).toList(),
        tools: (json['tools'] as List).map((e) => ToolProficiencyOption.fromJson(e)).toList(),
        levels: (json['levels'] as List).map((e) => ClassLevel.fromJson(e)).toList(),
        features: (json['features'] as List).map((e) => ClassFeature.fromJson(e)).toList(),
        subclasses: (json['subclasses'] as List).map((e) => Subclass.fromJson(e)).toList(),
        subclassLevel: json['subclassLevel'],
        subclassTitle: json['subclassTitle'],
      );
}

/// Строка таблицы класса.
class ClassLevel {
  final int level;
  final int proficiencyBonus;
  final List<ClassLevelFeature> features;
  final int? cantripsKnown;
  final int? spellsKnown;

  /// Ячейки заклинаний 1–9 уровней.
  final List<int> spellSlots;

  /// Все столбцы таблицы класса по названиям, например «Единицы чародейства» → «2».
  final Map<String, String> columns;

  const ClassLevel({
    required this.level,
    required this.proficiencyBonus,
    required this.features,
    required this.cantripsKnown,
    required this.spellsKnown,
    required this.spellSlots,
    this.columns = const {},
  });

  /// Число из столбца таблицы; `null`, если столбца нет или в нём прочерк.
  int? number(String column) => int.tryParse(columns[column] ?? '');

  bool hasFeature(String id) => features.any((e) => e.id == id);

  /// Наибольший уровень заклинаний, для которого есть ячейки.
  int get maxSpellLevel => spellSlots.lastIndexWhere((e) => e > 0) + 1;

  Map<String, dynamic> toJson() => {
        'level': level,
        'proficiencyBonus': proficiencyBonus,
        'features': features.map((e) => e.toJson()).toList(),
        'cantripsKnown': cantripsKnown,
        'spellsKnown': spellsKnown,
        'spellSlots': spellSlots,
        'columns': columns,
      };

  factory ClassLevel.fromJson(Map<String, dynamic> json) => ClassLevel(
        level: json['level'],
        proficiencyBonus: json['proficiencyBonus'],
        features: (json['features'] as List).map((e) => ClassLevelFeature.fromJson(e)).toList(),
        cantripsKnown: json['cantripsKnown'],
        spellsKnown: json['spellsKnown'],
        spellSlots: (json['spellSlots'] as List).cast<int>(),
        columns: (json['columns'] as Map).cast<String, String>(),
      );
}

/// Умение в таблице класса: ссылка на описание и подпись, например «Вдохновение барда (к8)».
class ClassLevelFeature {
  /// Идентификатор умения на ttg.club, например `c1` для «Вдохновения барда».
  final String id;
  final String title;

  const ClassLevelFeature({required this.id, required this.title});

  Map<String, dynamic> toJson() => {'id': id, 'title': title};

  factory ClassLevelFeature.fromJson(Map<String, dynamic> json) => ClassLevelFeature(
        id: json['id'],
        title: json['title'],
      );
}

class ClassFeature {
  final String id;
  final String name;
  final int level;

  /// Опциональное умение из Tasha's Cauldron of Everything.
  final bool isOptional;
  final String descriptionHtml;

  const ClassFeature({
    required this.id,
    required this.name,
    required this.level,
    required this.isOptional,
    required this.descriptionHtml,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level,
        'isOptional': isOptional,
        'descriptionHtml': descriptionHtml,
      };

  factory ClassFeature.fromJson(Map<String, dynamic> json) => ClassFeature(
        id: json['id'],
        name: json['name'],
        level: json['level'],
        isOptional: json['isOptional'],
        descriptionHtml: json['descriptionHtml'],
      );
}

/// Подкласс (например, коллегия бардов).
class Subclass {
  /// Последняя часть ссылки на подкласс, например `lore` для `/classes/bard/lore`.
  final String id;
  final String name;
  final String? source;
  final String descriptionHtml;
  final List<SubclassFeature> features;

  /// Заклинания подкласса по уровням класса, например у «Аберрантного разума»: ссылки на заклинания,
  /// которые всегда известны и не учитываются в числе известных заклинаний.
  final Map<int, List<String>> spells;

  const Subclass({
    required this.id,
    required this.name,
    required this.source,
    required this.descriptionHtml,
    required this.features,
    this.spells = const {},
  });

  List<SubclassFeature> featuresAt(int level) => features.where((e) => e.level == level).toList();

  /// Заклинания подкласса, полученные к [level] уровню класса.
  List<String> spellsUpTo(int level) => spells.entries.where((e) => e.key <= level).expand((e) => e.value).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'source': source,
        'descriptionHtml': descriptionHtml,
        'features': features.map((e) => e.toJson()).toList(),
        'spells': spells.map((key, value) => MapEntry('$key', value)),
      };

  factory Subclass.fromJson(Map<String, dynamic> json) => Subclass(
        id: json['id'],
        name: json['name'],
        source: json['source'],
        descriptionHtml: json['descriptionHtml'],
        features: (json['features'] as List).map((e) => SubclassFeature.fromJson(e)).toList(),
        spells: (json['spells'] as Map).map((key, value) => MapEntry(int.parse(key), (value as List).cast<String>())),
      );
}

class SubclassFeature {
  final String name;
  final int level;
  final String descriptionHtml;

  const SubclassFeature({
    required this.name,
    required this.level,
    required this.descriptionHtml,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'level': level,
        'descriptionHtml': descriptionHtml,
      };

  factory SubclassFeature.fromJson(Map<String, dynamic> json) => SubclassFeature(
        name: json['name'],
        level: json['level'],
        descriptionHtml: json['descriptionHtml'],
      );
}
