import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart';
import 'package:html/parser.dart' as html_parser;

/// Общие приёмы разбора ответов ttg.club: в JSON часть полей — html или текст как в книге.
abstract final class TtgText {
  static String cleanText(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Текст html-фрагмента без английских названий в квадратных скобках:
  /// «рапира [rapier]» → «рапира».
  static String plainText(String html) =>
      cleanText((html_parser.parseFragment(html).text ?? '').replaceAll(RegExp(r'\s*\[[^\]]*\]'), ''));

  /// Html описания с сайта без сносок на эррату: «видимое<sup><a href="/rules/Errata_(PHB)">1</a></sup>».
  static String html(Object? html) =>
      '${html ?? ''}'.replaceAll(RegExp(r'<sup>\s*<a[^>]*href="/rules/Errata[^"]*"[^>]*>[^<]*</a>\s*</sup>'), '');

  static String capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  /// `{"rus": "Бард", "eng": "Bard"}` → («Бард», «Bard»).
  static (String, String) names(Object? json) {
    final map = json as Map<String, dynamic>;
    return (cleanText(map['rus'] as String), cleanText((map['eng'] as String?) ?? ''));
  }

  /// Ссылки на сайте пишутся в разном регистре и с типографскими апострофами:
  /// `/items/Thieves’_Tools` и `/items/thieves'_tools` — один предмет.
  static String normalizeLink(String link) => link.toLowerCase().replaceAll('’', "'").replaceAll(RegExp(r'/$'), '');

  /// Последняя часть ссылки: `/classes/bard/lore` → `lore`.
  static String slug(String link) => normalizeLink(link).split('/').last;

  /// Источник из официальных книг (группа «Официальные источники»), а не UA, homebrew или сторонний.
  static bool isOfficial(Object? source) => ((source as Map)['group'] as Map?)?['shortName'] == 'Basic';

  static String? bookOf(Object? source) => (source as Map)['shortName'] as String?;

  /// Делит по запятым верхнего уровня: запятые внутри скобок и кавычек не считаются.
  static List<String> splitTopLevel(String text, {String separator = ','}) {
    final parts = <String>[];
    var depth = 0;
    var start = 0;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '(' || char == '«' || char == '<') depth++;
      if (char == ')' || char == '»' || char == '>') depth--;
      if (char == separator && depth == 0) {
        parts.add(text.substring(start, i));
        start = i + 1;
      }
    }
    parts.add(text.substring(start));
    return parts.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  static const _numbers = {
    'один': 1,
    'одна': 1,
    'одно': 1,
    'два': 2,
    'две': 2,
    'три': 3,
    'четыре': 4,
    'пять': 5,
    'десять': 10,
    'двадцать': 20,
  };

  /// Число в начале текста: «Три музыкальных инструмента», «Два на ваш выбор», «20 болтов».
  static int? leadingNumber(String text) {
    final word = RegExp(r'^[^\s,.]+').firstMatch(text.trim().toLowerCase())?.group(0);
    return word == null ? int.tryParse(text.trim()) : _numbers[word] ?? int.tryParse(word);
  }

  /// «2 см.», «1500 зм.», «2.0 зм» → стоимость; «—» → `null`.
  static Balance? parseCost(String? text) {
    final match = RegExp(r'([\d\s]+(?:[.,]\d+)?)\s*(зм|см|мм|эм|пм)').firstMatch(text ?? '');
    if (match == null) return null;
    final value = double.parse(match.group(1)!.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.'));
    final copper = switch (match.group(2)) {
      'зм' => 100,
      'см' => 10,
      'мм' => 1,
      'эм' => 50,
      _ => 1000,
    };
    return Balance((value * copper).round());
  }

  /// Код характеристики из api: `CHARISMA` → [StatKind.charisma].
  static StatKind? stat(Object? code) => StatKind.values.firstWhereOrNull((e) => e.name == '$code'.toLowerCase());

  static const statNames = {
    StatKind.strength: ('Сила', 'Силы'),
    StatKind.dexterity: ('Ловкость', 'Ловкости'),
    StatKind.constitution: ('Телосложение', 'Телосложения'),
    StatKind.intelligence: ('Интеллект', 'Интеллекта'),
    StatKind.wisdom: ('Мудрость', 'Мудрости'),
    StatKind.charisma: ('Харизма', 'Харизмы'),
  };

  /// Характеристики, упомянутые в тексте в именительном («Ловкость, Харизма») или
  /// родительном падеже («Силы или Ловкости»).
  static List<StatKind> statsIn(String text) => statNames.entries
      .where((e) => RegExp('(^|[^А-Яа-яЁё])(${e.value.$1}|${e.value.$2})([^А-Яа-яЁё]|\$)').hasMatch(text))
      .map((e) => e.key)
      .toList();

  /// Код навыка из api: `SLEIGHT_OF_HAND` → [Skill.sleightOfHand].
  static Skill? skill(Object? code) {
    final parts = '$code'.toLowerCase().split('_');
    final name = parts.first + parts.skip(1).map(capitalize).join();
    return Skill.values.firstWhereOrNull((e) => e.name == name);
  }

  static const _skillNames = {
    'Атлетика': Skill.athletics,
    'Акробатика': Skill.acrobatics,
    'Ловкость рук': Skill.sleightOfHand,
    'Скрытность': Skill.stealth,
    'История': Skill.history,
    'Магия': Skill.arcana,
    'Природа': Skill.nature,
    'Расследование': Skill.investigation,
    'Анализ': Skill.investigation,
    'Религия': Skill.religion,
    'Восприятие': Skill.perception,
    'Внимательность': Skill.perception,
    'Выживание': Skill.survival,
    'Медицина': Skill.medicine,
    'Проницательность': Skill.insight,
    'Уход за животными': Skill.animalHandling,
    'Выступление': Skill.performance,
    'Запугивание': Skill.intimidation,
    'Обман': Skill.deception,
    'Убеждение': Skill.persuasion,
  };

  /// Навык по русскому названию, как в списках навыков предысторий.
  static Skill? skillByName(String name) => _skillNames[cleanText(name)];

  static const _toolKeywords = {
    'музык': ToolCategory.musicalInstrument,
    'грим': ToolCategory.makeupKit,
    'фальсиф': ToolCategory.falsificationKit,
    'игров': ToolCategory.playSet,
    'травник': ToolCategory.foldOfLawn,
    'навигат': ToolCategory.navigatorTool,
    'воровск': ToolCategory.thievesTool,
    'отравит': ToolCategory.poisonerTool,
    'ремесл': ToolCategory.craftsmenTool,
    'транспорт': ToolCategory.vehicle,
  };

  /// Категория инструмента по названию: «Воровские инструменты», «один игровой набор».
  static ToolCategory? toolCategoryIn(String text) {
    final lower = text.toLowerCase();
    return _toolKeywords.entries.where((e) => lower.contains(e.key)).map((e) => e.value).firstOrNull;
  }

  /// Все категории инструментов в тексте по порядку: «инструмента ремесленников либо музыкального инструмента».
  static List<ToolCategory> toolCategoriesIn(String text) {
    final lower = text.toLowerCase();
    final found = _toolKeywords.entries.where((e) => lower.contains(e.key)).toList()
      ..sort((a, b) => lower.indexOf(a.key).compareTo(lower.indexOf(b.key)));
    return found.map((e) => e.value).toSet().toList();
  }

  /// Разбирает строку вида «Воровские инструменты, один игровой набор.» или «Выберите один вид инструмента
  /// ремесленников либо музыкального инструмента».
  static List<ToolProficiencyOption> toolOptions(String? html) {
    final options = <ToolProficiencyOption>[];
    for (final part in splitTopLevel(html ?? '')) {
      final text = plainText(part).replaceAll(RegExp(r'[.;]$'), '');
      if (text.isEmpty || text.toLowerCase() == 'нет') continue;
      final categories = toolCategoriesIn(text);
      final alternatives = RegExp(r'\s(либо|или)\s').hasMatch(text) ? categories.skip(1).toList() : <ToolCategory>[];
      options.add(
        ToolProficiencyOption(
          title: capitalize(text),
          category: alternatives.isEmpty ? toolCategoryIn(text) : categories.first,
          choose: leadingNumber(text.replaceFirst(RegExp(r'^выберите\s+', caseSensitive: false), '')) ?? 0,
          alternatives: alternatives,
        ),
      );
    }
    return options;
  }
}
