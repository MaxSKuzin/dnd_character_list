import 'package:dnd_character_list/data/dnd_su/dnd_su_client.dart';
import 'package:dnd_character_list/data/dnd_su/dnd_su_html.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:injectable/injectable.dart';

/// Ссылка на страницу из списка раздела dnd.su (предыстории, черты).
class DndSuListItem {
  final String link;
  final String name;

  const DndSuListItem({required this.link, required this.name});
}

/// Разбирает раздел https://dnd.su/backgrounds/.
@lazySingleton
class DndSuBackgroundsParser {
  static const indexPath = '/backgrounds/';

  /// Идентификатор «Player's Handbook» в фильтре источников.
  static const playersHandbookSource = '102';

  /// Список ссылок на страницы раздела из указанного источника.
  static List<DndSuListItem> parseList(String body, {required String source}) {
    final items = html_parser
        .parse(body)
        .querySelectorAll('.list-item__spell[data-source="$source"]')
        .map((item) {
          final link = item.querySelector('a.list-item-wrapper');
          final title = item.querySelector('.list-item-title');
          if (link == null || title == null) return null;
          return DndSuListItem(link: link.attributes['href']!, name: DndSuHtml.cleanText(title.text));
        })
        .nonNulls
        .toList();
    if (items.isEmpty) {
      throw const DndSuMissingContentException('Не удалось найти список на странице');
    }
    return items;
  }

  List<DndSuListItem> parseIndex(String body) => parseList(body, source: playersHandbookSource);

  Background parseBackground(String link, String body) {
    final article = DndSuHtml.parseArticle(body);
    final description = article?.querySelector('[itemprop="description"]');
    final title = html_parser.parse(DndSuHtml.cutArticle(body)).querySelector('.card-title span[data-copy]')?.text;
    if (article == null || description == null || title == null) {
      throw const DndSuMissingContentException('Не удалось найти описание предыстории на странице');
    }
    final (name, nameEn) = DndSuHtml.splitTitle(title);

    final skills = DndSuHtml.labeledParagraph(description, 'Владение навыками');
    final tools = DndSuHtml.labeledParagraph(description, 'Владение инструментами');
    final languages = DndSuHtml.labeledParagraph(description, 'Языки');
    final equipment = DndSuHtml.labeledParagraph(description, 'Снаряжение');
    final (items, gold) = _parseEquipment(equipment == null ? '' : DndSuHtml.withoutLabel(equipment).text);
    final (featureName, featureHtml) = _parseFeature(description);

    return Background(
      id: int.parse(RegExp(r'/backgrounds/(\d+)').firstMatch(link)!.group(1)!),
      link: link,
      name: name,
      nameEn: nameEn,
      descriptionHtml: description.innerHtml.trim(),
      skills: skills == null ? [] : DndSuHtml.skillsIn(skills),
      tools: tools == null ? [] : DndSuHtml.toolOptions(DndSuHtml.withoutLabel(tools)),
      languagesCount: languages == null ? 0 : DndSuHtml.leadingNumber(DndSuHtml.withoutLabel(languages).text) ?? 0,
      equipment: items,
      gold: gold,
      featureName: featureName,
      featureHtml: featureHtml,
      tables: description.querySelectorAll('table').map(_parseTable).nonNulls.toList(),
    );
  }

  /// «Костюм, поясной кошель с 15 зм» → ([Костюм, Поясной кошель], 15).
  (List<String>, int) _parseEquipment(String text) {
    var gold = 0;
    final items = <String>[];
    for (var item in _mergeClauses(DndSuHtml.splitTopLevel(DndSuHtml.cleanText(text)))) {
      final money = RegExp(r'(?:\s+с)?\s*(\d+)\s*зм\.?$').firstMatch(item);
      if (money != null) {
        gold += int.parse(money.group(1)!);
        item = item.substring(0, money.start).trim();
      }
      if (item.isNotEmpty) items.add(item[0].toUpperCase() + item.substring(1));
    }
    return (items, gold);
  }

  /// Придаточные через запятую относятся к предыдущему предмету:
  /// «карта города, в котором вы выросли», «талисман, такой как кроличья лапка».
  List<String> _mergeClauses(List<String> parts) {
    final clause = RegExp(r'^((в|на|с|из|о|по)\s+)?котор|^так(ой|ая|ое|ие)\s+как|^битком');
    final merged = <String>[];
    for (final part in parts) {
      if (merged.isNotEmpty && clause.hasMatch(part.toLowerCase())) {
        merged.last = '${merged.last}, $part';
      } else {
        merged.add(part);
      }
    }
    return merged;
  }

  /// Раздел «УМЕНИЕ: ...»: заголовок и всё до следующего заголовка.
  (String?, String?) _parseFeature(Element description) {
    final header = description
        .querySelectorAll('h3')
        .where((e) => DndSuHtml.cleanText(e.text).toUpperCase().startsWith('УМЕНИЕ:'))
        .firstOrNull;
    if (header == null) return (null, null);
    final name = DndSuHtml.capitalize(DndSuHtml.cleanText(header.text).substring('УМЕНИЕ:'.length).trim());
    final content = <Element>[];
    for (var next = header.nextElementSibling; next != null; next = next.nextElementSibling) {
      if (next.localName == 'h3' || next.localName == 'table') break;
      if (next.localName != 'br') content.add(next);
    }
    return (name, DndSuHtml.outerHtml(content));
  }

  PersonalityTable? _parseTable(Element table) {
    final rows = table.querySelectorAll('tr');
    final header = rows.where((e) => e.classes.contains('table_header')).firstOrNull;
    if (header == null || header.children.length < 2) return null;
    final title = DndSuHtml.cleanText(header.children[1].text);
    final options = rows
        .where((e) => e != header && e.children.length >= 2)
        .map((e) => DndSuHtml.cleanText(e.children[1].text))
        .where((e) => e.isNotEmpty)
        .toList();
    return PersonalityTable(
      title: title,
      kind: switch (title) {
        'Черта характера' => PersonalityTableKind.trait,
        'Идеал' => PersonalityTableKind.ideal,
        'Привязанность' => PersonalityTableKind.bond,
        'Слабость' => PersonalityTableKind.flaw,
        _ => PersonalityTableKind.other,
      },
      options: options,
    );
  }
}
