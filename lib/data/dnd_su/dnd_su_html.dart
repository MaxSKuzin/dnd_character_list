import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

/// Общие приёмы разбора страниц dnd.su.
abstract final class DndSuHtml {
  /// Основной контент страницы без меню и комментариев, которые занимают большую часть объёма.
  /// Карточка начинается с заголовка с названием, за ним идёт `articleBody`.
  static String cutArticle(String body) {
    final article = body.indexOf('itemprop="articleBody"');
    if (article == -1) return body;
    final header = body.lastIndexOf('<div class="card__header"', article);
    final start = header == -1 ? body.lastIndexOf('<', article) : header;
    final end = body.indexOf('<section class="comments-block', article);
    return body.substring(start, end == -1 ? body.length : end);
  }

  static Element? parseArticle(String body) =>
      html_parser.parse(cutArticle(body)).querySelector('[itemprop="articleBody"]');

  static String cleanText(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// «Артист [Entertainer]» → («Артист», «Entertainer»).
  static (String, String) splitTitle(String title) {
    final match = RegExp(r'^(.*?)\s*\[(.*)\]\s*$').firstMatch(cleanText(title));
    if (match == null) return (cleanText(title), '');
    return (match.group(1)!, match.group(2)!);
  }

  static String capitalize(String text) {
    final lower = text.toLowerCase();
    return lower.isEmpty ? lower : lower[0].toUpperCase() + lower.substring(1);
  }

  /// Html нескольких соседних элементов одной строкой.
  static String outerHtml(Iterable<Element> elements) => elements.map((e) => e.outerHtml).join('\n').trim();

  /// Делит по запятым верхнего уровня: запятые внутри скобок не считаются.
  static List<String> splitTopLevel(String text, {String separator = ','}) {
    final parts = <String>[];
    var depth = 0;
    var start = 0;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '(' || char == '«') depth++;
      if (char == ')' || char == '»') depth--;
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
  };

  /// Число в начале текста: «Три музыкальных инструмента», «Два на ваш выбор».
  static int? leadingNumber(String text) {
    final word = RegExp(r'^[^\s,.]+').firstMatch(text.trim().toLowerCase())?.group(0);
    return word == null ? int.tryParse(text.trim()) : _numbers[word] ?? int.tryParse(word);
  }

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
    'Выживание': Skill.survival,
    'Медицина': Skill.medicine,
    'Проницательность': Skill.insight,
    'Уход за животными': Skill.animalHandling,
    'Выступление': Skill.performance,
    'Запугивание': Skill.intimidation,
    'Обман': Skill.deception,
    'Убеждение': Skill.persuasion,
  };

  /// Навыки по кодам `tooltip-for="skill.*"`, а при их отсутствии — по названиям.
  static List<Skill> skillsIn(Element element) {
    final byCode = element
        .querySelectorAll('[tooltip-for^="skill."]')
        .map((e) => Skill.fromDndSu(e.attributes['tooltip-for']!))
        .nonNulls
        .toSet();
    if (byCode.isNotEmpty) return byCode.toList();
    final text = cleanText(element.text);
    return _skillNames.entries.where((e) => text.contains(e.key)).map((e) => e.value).toSet().toList();
  }

  static const _toolCodes = {
    'tools.music': ToolCategory.musicalInstrument,
    'tools.disguise': ToolCategory.makeupKit,
    'tools.forgery': ToolCategory.falsificationKit,
    'tools.gaming': ToolCategory.playSet,
    'tools.herbalist': ToolCategory.foldOfLawn,
    'tools.navigator': ToolCategory.navigatorTool,
    'tools.thief': ToolCategory.thievesTool,
    'tools.poisoner': ToolCategory.poisonerTool,
    'tools.vehicles': ToolCategory.vehicle,
  };

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

  /// Разбирает строку вида «Набор для грима, один вид музыкального инструмента».
  static List<ToolProficiencyOption> toolOptions(Element element) {
    final options = <ToolProficiencyOption>[];
    for (final part in splitTopLevel(element.innerHtml)) {
      final fragment = html_parser.parseFragment(part);
      final text = cleanText(fragment.text ?? '').replaceAll(RegExp(r'[.;]$'), '');
      if (text.isEmpty) continue;
      final code = fragment.querySelector('[tooltip-for^="tools."]')?.attributes['tooltip-for'];
      final lower = text.toLowerCase();
      final category = _toolCodes[code] ??
          _toolKeywords.entries.where((e) => lower.contains(e.key)).map((e) => e.value).firstOrNull;
      final count = leadingNumber(text);
      options.add(
        ToolProficiencyOption(
          title: text[0].toUpperCase() + text.substring(1),
          category: category,
          choose: count ?? 0,
        ),
      );
    }
    return options;
  }

  /// Абзац вида `<p><strong>Метка:</strong> значение</p>` по началу метки.
  static Element? labeledParagraph(Element root, String label) => root
      .querySelectorAll('p')
      .where((p) => cleanText(p.querySelector('strong')?.text ?? '').startsWith(label))
      .firstOrNull;

  /// Содержимое абзаца без метки.
  static Element withoutLabel(Element paragraph) {
    final copy = paragraph.clone(true);
    copy.querySelector('strong')?.remove();
    return copy;
  }
}
