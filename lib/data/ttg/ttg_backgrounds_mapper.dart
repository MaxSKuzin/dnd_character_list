import 'package:dnd_character_list/data/ttg/ttg_text.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:injectable/injectable.dart';

/// Переводит ответ `POST /backgrounds/<slug>` в [Background].
@lazySingleton
class TtgBackgroundsMapper {
  /// [link] — ссылка из списка (`/backgrounds/acolyte`): в ответе по предыстории `url` служебный.
  Background map(String link, Map<String, dynamic> json) {
    final (name, nameEn) = TtgText.names(json['name']);
    final featureName = json['skillName'] as String?;
    final featureHtml = json['skillDescription'] as String?;
    return Background(
      id: json['id'],
      link: TtgText.normalizeLink(link),
      name: name,
      nameEn: nameEn,
      descriptionHtml: [
        TtgText.html(json['description']),
        if (featureName != null) '<h3>Умение: $featureName</h3>${TtgText.html(featureHtml)}',
        if (json['personalization'] != null) '<h3>Персонализация</h3>${json['personalization']}',
      ].join('\n'),
      skills: (json['skills'] as List? ?? const []).map((e) => TtgText.skillByName('$e')).nonNulls.toList(),
      tools: TtgText.toolOptions(json['toolOwnership']),
      languagesCount: TtgText.leadingNumber(json['language'] ?? '') ?? 0,
      equipment: _equipment((json['equipments'] as List? ?? const []).map((e) => TtgText.plainText('$e')).toList()),
      gold: json['startGold'] ?? 0,
      featureName: featureName,
      featureHtml: featureHtml == null ? null : TtgText.html(featureHtml),
      tables: _tables(json),
    );
  }

  /// Таблицы персонализации; дополнительные таблицы вроде «Амплуа» артиста есть только в описании.
  List<PersonalityTable> _tables(Map<String, dynamic> json) {
    final tables = (json['personalizationTables'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(_table)
        .where((e) => e.options.isNotEmpty)
        .toList();
    final titles = tables.map((e) => e.title).toSet();
    final extra = html_parser
        .parseFragment(json['description'] ?? '')
        .querySelectorAll('table')
        .map(_descriptionTable)
        .nonNulls
        .where((e) => !titles.contains(e.title));
    return [...extra, ...tables];
  }

  /// Таблица «к10 | Амплуа» из описания предыстории.
  PersonalityTable? _descriptionTable(Element table) {
    final rows = table.querySelectorAll('tr');
    if (rows.isEmpty || rows.first.children.length != 2) return null;
    final header = rows.first.children.map((e) => TtgText.cleanText(e.text)).toList();
    if (!RegExp(r'^к\d+$').hasMatch(header.first)) return null;
    return PersonalityTable(
      title: header.last,
      kind: PersonalityTableKind.other,
      options: rows
          .skip(1)
          .where((e) => e.children.length == 2)
          .map((e) => TtgText.cleanText(e.children.last.text))
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }

  /// Снаряжение на сайте разделено по всем запятым, даже внутри скобок и придаточных:
  /// «карта города», «в котором вы выросли». Части склеиваются обратно, деньги
  /// («поясной кошель с 15 зм.») убираются — они приходят отдельно в `startGold`.
  List<String> _equipment(List<String> parts) {
    final clause = RegExp(r'^((в|на|с|из|о|по)\s+)?котор|^так(ой|ая|ое|ие)\s+как|^битком');
    final merged = <String>[];
    var depth = 0;
    for (final part in parts.where((e) => e.isNotEmpty)) {
      if (merged.isNotEmpty && (depth > 0 || clause.hasMatch(part.toLowerCase()))) {
        merged.last = '${merged.last}, $part';
      } else {
        merged.add(part);
      }
      depth += '('.allMatches(part).length - ')'.allMatches(part).length;
    }
    return merged
        .map((e) => e.replaceFirst(RegExp(r'(?:\s+с)?\s*\d+\s*зм\.?$'), '').trim())
        .where((e) => e.isNotEmpty)
        .map(TtgText.capitalize)
        .toList();
  }

  PersonalityTable _table(Map<String, dynamic> json) => PersonalityTable(
        title: json['name'],
        kind: switch (json['type']) {
          'TRAIT' => PersonalityTableKind.trait,
          'IDEAL' => PersonalityTableKind.ideal,
          'AFFECTION' => PersonalityTableKind.bond,
          'WEAKNESS' => PersonalityTableKind.flaw,
          _ => PersonalityTableKind.other,
        },
        // Строки таблицы: номер на кости и текст.
        options: (json['tbody'] as List)
            .map((row) => TtgText.plainText('${(row as List).last}'))
            .where((e) => e.isNotEmpty)
            .toList(),
      );
}
