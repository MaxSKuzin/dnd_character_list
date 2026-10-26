import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_client.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_html.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/starting_equipment.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:injectable/injectable.dart';

/// Разбирает страницу класса, например https://dnd.su/class/88-bard/.
@lazySingleton
class DndSuClassParser {
  /// Подклассы из «Unearthed Arcana» и homebrew размещены после этого якоря.
  static const _unofficialAnchor = 'unofficial';

  ClassInfo parseClass(String link, String body) {
    final document = html_parser.parse(DndSuHtml.cutArticle(body));
    final article = document.querySelector('[itemprop="articleBody"]');
    final table = article?.querySelector('table.class_table');
    if (article == null || table == null) {
      throw const DndSuMissingContentException('Не удалось найти описание класса на странице');
    }
    final (name, nameEn) = DndSuHtml.splitTitle(document.querySelector('.card-title')?.text ?? '');
    final sections = _basicSections(article);
    final proficiencies = sections['ВЛАДЕНИЕ'] ?? [];
    final skills = proficiencies.firstWhereOrNull((e) => _label(e) == 'Навыки');
    final tools = proficiencies.firstWhereOrNull((e) => _label(e) == 'Инструменты');
    final savingThrows = proficiencies.firstWhereOrNull((e) => _label(e) == 'Спасброски');
    final skillsText = skills == null ? '' : DndSuHtml.cleanText(DndSuHtml.withoutLabel(skills).text);

    return ClassInfo(
      link: link,
      name: name,
      nameEn: nameEn,
      hitPointsHtml: DndSuHtml.outerHtml(sections['ХИТЫ'] ?? []),
      proficienciesHtml: DndSuHtml.outerHtml(proficiencies),
      equipmentHtml: DndSuHtml.outerHtml(sections['СНАРЯЖЕНИЕ'] ?? []),
      startingEquipment: (sections['СНАРЯЖЕНИЕ'] ?? [])
          .where((e) => e.localName == 'ul')
          .expand((e) => e.querySelectorAll('li'))
          .map(_parseEquipmentChoice)
          .toList(),
      quickBuildHtml: _quickBuild(article),
      savingThrows: savingThrows == null ? [] : DndSuHtml.statsIn(DndSuHtml.withoutLabel(savingThrows).text),
      skillsCount: DndSuHtml.leadingNumber(skillsText.replaceFirst(RegExp(r'^Выберите\s+'), '')) ?? 0,
      skillOptions: skills == null || skillsText.contains('любы') ? [] : DndSuHtml.skillsIn(skills),
      tools: tools == null ? [] : DndSuHtml.toolOptions(DndSuHtml.withoutLabel(tools)),
      levels: _parseTable(table),
      features: _parseFeatures(article),
      subclasses: _parseSubclasses(article, classSource: _source(article)),
    );
  }

  String? _label(Element paragraph) =>
      DndSuHtml.cleanText(paragraph.querySelector('strong')?.text ?? '').replaceAll(':', '').trim();

  /// Подразделы «Хиты», «Владение», «Снаряжение» блока классовых умений.
  Map<String, List<Element>> _basicSections(Element article) {
    final sections = <String, List<Element>>{};
    final firstHeader =
        article.querySelectorAll('h4').firstWhereOrNull((e) => DndSuHtml.cleanText(e.text).toUpperCase() == 'ХИТЫ');
    if (firstHeader == null) return sections;
    List<Element>? current;
    for (final element in firstHeader.parent!.children.skipWhile((e) => e != firstHeader)) {
      if (element.localName == 'h4') {
        current = sections[DndSuHtml.cleanText(element.text).toUpperCase()] = [];
      } else if (element.localName != 'br') {
        current?.add(element);
      }
    }
    return sections;
  }

  /// Категории, из которых предмет выбирает игрок: «любое простое оружие», «два воинских оружия».
  static const _categoryIds = {'weapon.simple', 'weapon.martial', 'tools.music', 'tools.gaming'};

  /// «а) рапира, б) длинный меч или в) любое простое оружие» → три варианта.
  StartingEquipmentChoice _parseEquipmentChoice(Element item) {
    final parts = item.innerHtml.split(RegExp(r'(?:^|\s)[абвгд]\)\s*')).map((e) => e.trim()).where((e) => e.isNotEmpty);
    return StartingEquipmentChoice(
      options: parts.map((part) {
        final html = part.replaceFirst(RegExp(r'(,|\s+или)\s*$'), '');
        return StartingEquipmentOption(
          text: DndSuHtml.cleanText(html_parser.parseFragment(html).text ?? ''),
          items: DndSuHtml.splitTopLevel(html.replaceAll(RegExp(r'\s+и\s+'), ', ')).map(_parseEquipmentRef).toList(),
        );
      }).toList(),
    );
  }

  /// «два ручных топора» → 2 × weapon.axe-hand; «колчан с 20 стрелами» → equipment.arrow.
  EquipmentRef _parseEquipmentRef(String html) {
    final fragment = html_parser.parseFragment(html);
    final text = DndSuHtml.cleanText(fragment.text ?? '');
    final link = fragment.querySelector('a[href*="#"], [tooltip-for]');
    final id = link?.attributes['tooltip-for'] ?? link?.attributes['href']?.split('#').last;
    final lower = text.toLowerCase();
    return EquipmentRef(
      id: id,
      text: text,
      quantity: DndSuHtml.leadingNumber(text) ?? 1,
      isChoice: _categoryIds.contains(id) || lower.startsWith('люб'),
    );
  }

  String? _quickBuild(Element article) {
    final header = article
        .querySelectorAll('h3')
        .firstWhereOrNull((e) => DndSuHtml.cleanText(e.text).toUpperCase() == 'БЫСТРОЕ СОЗДАНИЕ');
    final content = _contentAfter(header);
    return content.isEmpty ? null : DndSuHtml.outerHtml(content);
  }

  List<ClassLevel> _parseTable(Element table) {
    final rows = table.querySelectorAll('tr');
    final header = rows.first;

    // Номера столбцов по заголовкам первой строки с учётом colspan.
    // Заголовки вида «Известные<br>заговоры» сравниваются без пробелов.
    final columns = <String, int>{};
    var index = 0;
    for (final cell in header.children) {
      final title = (cell.querySelector('.long') ?? cell).text.replaceAll(RegExp(r'\s+'), '').toLowerCase();
      columns[title] = index;
      index += int.tryParse(cell.attributes['colspan'] ?? '') ?? 1;
    }
    int? column(bool Function(String title) test) => columns.entries.firstWhereOrNull((e) => test(e.key))?.value;
    final featuresColumn = column((e) => e.startsWith('умения'));
    final cantripsColumn = column((e) => e.startsWith('известные') && e.contains('заговор'));
    final spellsColumn = column((e) => e.startsWith('известные') && e.contains('заклинани'));
    final slotsColumn = column((e) => e.startsWith('ячейки'));

    int? number(List<Element> cells, int? column) =>
        column == null || column >= cells.length ? null : int.tryParse(DndSuHtml.cleanText(cells[column].text));

    return rows.where((e) => !e.classes.contains('table_header')).map((row) {
      final cells = row.children;
      final featureLinks = featuresColumn == null
          ? <Element>[]
          : cells[featuresColumn]
              .querySelectorAll('a[href^="#feature."]')
              .where((e) => !_isTceReplaced(e, cells[featuresColumn]));
      return ClassLevel(
        level: number(cells, 0)!,
        proficiencyBonus: int.parse(DndSuHtml.cleanText(cells[1].text).replaceAll('+', '')),
        features: featureLinks
            .map((e) => ClassLevelFeature(
                  id: e.attributes['href']!.substring(1),
                  title: DndSuHtml.cleanText(e.text),
                ))
            .toList(),
        cantripsKnown: number(cells, cantripsColumn),
        spellsKnown: number(cells, spellsColumn),
        spellSlots: slotsColumn == null ? const [] : List.generate(9, (i) => number(cells, slotsColumn + i) ?? 0),
      );
    }).toList();
  }

  /// Умения, которые заменяются при включённых правилах TCE.
  bool _isTceReplaced(Element element, Element root) {
    for (Element? parent = element.parent; parent != null && parent != root; parent = parent.parent) {
      if (parent.classes.contains('TCE-feature-off')) return true;
    }
    return false;
  }

  List<ClassFeature> _parseFeatures(Element article) => article
      .querySelectorAll('h3 > span[id^="feature."]')
      .where((anchor) => !_isUnofficial(article, anchor))
      .map((anchor) {
        final header = anchor.parent!;
        final (level, content) = _levelAndContent(header);
        if (level == null) return null;
        return ClassFeature(
          id: anchor.id,
          name: DndSuHtml.capitalize(DndSuHtml.cleanText(anchor.text)),
          level: level,
          isOptional: header.parent?.classes.contains('TCE-feature-on') ?? false,
          descriptionHtml: DndSuHtml.outerHtml(content),
        );
      })
      .nonNulls
      .toList();

  /// Источник класса из строки «Источник: «Player's Handbook»».
  String? _source(Element article) {
    final params = article.querySelector('ul.params');
    return params == null ? null : RegExp(r'Источник:\s*«(.+?)»').firstMatch(DndSuHtml.cleanText(params.text))?.group(1);
  }

  /// Подклассы без указанного источника описаны в той же книге, что и класс.
  List<Subclass> _parseSubclasses(Element article, {required String? classSource}) {
    final subclasses = <Subclass>[];
    for (final header in article.querySelectorAll('h2.hide-next')) {
      final id = header.querySelector('span[id]')?.id;
      if (id == null) continue;
      if (_isUnofficial(article, header)) break;
      final wrapper = header.nextElementSibling;
      if (wrapper == null || !wrapper.classes.contains('hide-wrapper')) continue;

      final children = wrapper.children.where((e) => e.localName != 'br').toList();
      final firstFeature = children.indexWhere((e) => e.localName == 'h3');
      final intro = firstFeature == -1 ? children : children.sublist(0, firstFeature);
      final source =
          intro.map((e) => RegExp(r'Источник:\s*«(.+?)»').firstMatch(e.text)?.group(1)).nonNulls.firstOrNull ??
              classSource;

      final subclass = Subclass(
        id: id,
        name: DndSuHtml.cleanText(header.text),
        source: source,
        descriptionHtml: DndSuHtml.outerHtml(intro.where((e) => !e.text.contains('Источник:'))),
        features: wrapper
            .querySelectorAll('h3')
            .map((featureHeader) {
              final name = DndSuHtml.cleanText(featureHeader.text);
              final (level, content) = _levelAndContent(featureHeader);
              if (name.isEmpty || level == null) return null;
              return SubclassFeature(
                name: DndSuHtml.capitalize(name),
                level: level,
                descriptionHtml: DndSuHtml.outerHtml(content),
              );
            })
            .nonNulls
            .toList(),
      );
      // Разделы вроде «Углублённая предыстория барда» оформлены так же, но умений не дают.
      if (subclass.features.isNotEmpty) subclasses.add(subclass);
    }
    return subclasses;
  }

  /// Всё после якоря «Unearthed Arcana & Unofficial» не относится к официальным правилам.
  bool _isUnofficial(Element article, Element element) {
    final unofficial = article.querySelector('#$_unofficialAnchor');
    if (unofficial == null) return false;
    final order = _documentOrder[article] ??= {
      for (final (index, element) in article.querySelectorAll('*').indexed) element: index,
    };
    return order[element]! > order[unofficial]!;
  }

  final _documentOrder = Expando<Map<Element, int>>();

  /// Уровень из строки вида «<em>3-й уровень, умение барда</em>» и описание после неё.
  (int?, List<Element>) _levelAndContent(Element header) {
    final content = _contentAfter(header);
    final levelParagraph = content.firstOrNull;
    final level = levelParagraph == null
        ? null
        : int.tryParse(
            RegExp(r'^(\d+)-й уровень').firstMatch(DndSuHtml.cleanText(levelParagraph.text))?.group(1) ?? '');
    return (level, level == null ? content : content.skip(1).toList());
  }

  /// Элементы после заголовка до следующего заголовка того же или более высокого уровня.
  List<Element> _contentAfter(Element? header) {
    if (header == null) return [];
    final content = <Element>[];
    for (var next = header.nextElementSibling; next != null; next = next.nextElementSibling) {
      if (next.localName == 'h2' || next.localName == 'h3' || next.querySelector('h2, h3') != null) break;
      if (next.localName != 'br') content.add(next);
    }
    return content;
  }
}
