import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/ttg/ttg_text.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/equipment_catalog.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/starting_equipment.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:injectable/injectable.dart';

/// Переводит ответы `POST /classes/<класс>` и `POST /classes/<класс>/<подкласс>` в [ClassInfo].
@lazySingleton
class TtgClassMapper {
  /// Ссылки на официальные подклассы из ответа класса, например `/classes/bard/lore`.
  List<String> subclassLinks(Map<String, dynamic> json) => (json['archetypes'] as List)
      .cast<Map<String, dynamic>>()
      .where((e) => TtgText.isOfficial(e['source']))
      .map((e) => e['url'] as String)
      .toList();

  ClassInfo map(Map<String, dynamic> json, {List<Map<String, dynamic>> subclasses = const []}) {
    final (name, nameEn) = TtgText.names(json['name']);
    final traits = json['traits'] as Map<String, dynamic>;
    final skills = (json['availableSkillsRaw'] as List).map(TtgText.skill).nonNulls.toList();
    final mappedSubclasses = subclasses.map(mapSubclass).where((e) => e.features.isNotEmpty).toList();
    return ClassInfo(
      link: json['url'],
      name: name,
      nameEn: nameEn,
      hitPointsHtml: _hitPointsHtml(traits['diceHp'] as int, json['accusativeName'] as String? ?? name.toLowerCase()),
      proficienciesHtml: _proficienciesHtml(traits),
      equipmentHtml: traits['equipment'] ?? '',
      startingEquipment: _startingEquipment(traits['equipment'] ?? ''),
      quickBuildHtml: _quickBuild(json['description'] ?? ''),
      savingThrows: TtgText.statsIn(traits['savingThrows'] ?? ''),
      skillsCount: traits['skillAvailableCount'] ?? 0,
      // Пустой список — любые навыки, как у барда.
      skillOptions: skills.toSet().length == Skill.values.length ? [] : skills,
      tools: TtgText.toolOptions(traits['tools']),
      levels: _levels(traits),
      features: (traits['features'] as List)
          .cast<Map<String, dynamic>>()
          .where((e) => e['archetypeFeature'] != true)
          .map(
            (e) => ClassFeature(
              id: e['id'],
              name: e['name'],
              level: e['level'],
              isOptional: e['optional'] ?? false,
              descriptionHtml: TtgText.html(e['description']),
            ),
          )
          .toList(),
      subclasses: mappedSubclasses,
      subclassLevel: mappedSubclasses.map((e) => e.features.map((e) => e.level).min).minOrNull,
      subclassTitle: json['archetypeName'],
    );
  }

  /// Подкласс: описание — корневое умение архетипа, умения — остальные умения архетипа.
  Subclass mapSubclass(Map<String, dynamic> json) {
    final traits = json['traits'] as Map<String, dynamic>;
    final root = traits['archetype'] as Map<String, dynamic>?;
    final features = (traits['features'] as List).cast<Map<String, dynamic>>();
    final archetype = (json['archetypes'] as List?)
        ?.cast<Map<String, dynamic>>()
        .firstWhereOrNull((e) => TtgText.normalizeLink(e['url']) == TtgText.normalizeLink(_link(json)));
    return Subclass(
      id: TtgText.slug(_link(json)),
      name: root?['name'] ?? TtgText.names(archetype?['name'] ?? json['name']).$1,
      source: (root?['source'] as Map?)?['name'] ?? (archetype?['source'] as Map?)?['name'],
      descriptionHtml: TtgText.html(root?['description']),
      features: features
          .where((e) => e['archetypeFeature'] == true && e['archetypeRoot'] != true)
          .map((e) =>
              SubclassFeature(name: e['name'], level: e['level'], descriptionHtml: TtgText.html(e['description'])))
          .toList(),
      spells: {
        for (final row in ((json['archetypeSpellTable'] as Map?)?['levels'] as List? ?? const []).cast<Map>())
          row['level'] as int: (row['spells'] as List).map((e) => TtgText.normalizeLink((e as Map)['url'])).toList(),
      },
    );
  }

  /// В ответе подкласса `url` указывает на класс, поэтому ссылка восстанавливается из вкладок
  /// (`/classes/sorcerer/architypes/draconic`) или английского названия.
  String _link(Map<String, dynamic> json) {
    final tab = (json['tabs'] as List?)
        ?.cast<Map<String, dynamic>>()
        .map((e) => e['url'] as String)
        .firstWhereOrNull((e) => e.contains('/architypes/'));
    if (tab != null) return tab.replaceFirst('/architypes/', '/');
    return json['url'];
  }

  String _hitPointsHtml(int dice, String className) => [
        '<p><strong>Кость хитов:</strong> 1к$dice за каждый уровень $className</p>',
        '<p><strong>Хиты на 1 уровне:</strong> $dice + модификатор Телосложения</p>',
        '<p><strong>Хиты на следующих уровнях:</strong> 1к$dice (или ${dice ~/ 2 + 1}) + модификатор Телосложения '
            'за каждый уровень $className после первого</p>',
      ].join('\n');

  String _proficienciesHtml(Map<String, dynamic> traits) {
    final skills = (traits['availableSkills'] as List?)?.join(', ') ?? '';
    return [
      ('Доспехи', traits['armor']),
      ('Оружие', traits['weapon']),
      ('Инструменты', traits['tools']),
      ('Спасброски', traits['savingThrows']),
      ('Навыки', 'Выберите ${traits['skillAvailableCount']} из следующих: $skills'),
    ].where((e) => e.$2 != null).map((e) => '<p><strong>${e.$1}:</strong> ${e.$2}</p>').join('\n');
  }

  List<ClassLevel> _levels(Map<String, dynamic> traits) {
    final columns = (traits['classFeatureLevels'] as List).map((e) => (e as Map)['name'] as String).toList();
    final cantripsColumn = columns.indexWhere((e) => e.toLowerCase().contains('заговор'));
    final spellsColumn = columns.indexWhere((e) => e.toLowerCase().contains('заклинани'));
    int? number(List values, int column) => column == -1 ? null : int.tryParse('${values[column]}');

    return (traits['levels'] as List).cast<Map<String, dynamic>>().map((row) {
      final values = row['classFeatureValues'] as List;
      return ClassLevel(
        level: row['level'],
        proficiencyBonus: row['proficiencyBonus'],
        features: (row['traits'] as List)
            .cast<Map<String, dynamic>>()
            .where((e) => e['archetypeFeature'] != true)
            .map(
              (e) => ClassLevelFeature(
                id: (e['anchor'] as String).replaceFirst('#', ''),
                title: TtgText.capitalize(e['name']),
              ),
            )
            .toList(),
        cantripsKnown: number(values, cantripsColumn),
        spellsKnown: number(values, spellsColumn),
        spellSlots: (row['spellSlots'] as List? ?? const []).map((e) => int.tryParse('$e') ?? 0).toList(),
        columns: {for (final (index, name) in columns.indexed) TtgText.cleanText(name): '${values[index]}'},
      );
    }).toList();
  }

  /// «а) рапира, б) длинный меч или в) любое простое оружие» → три варианта.
  List<StartingEquipmentChoice> _startingEquipment(String html) =>
      html_parser.parseFragment(html).querySelectorAll('ul > li').map(_parseEquipmentChoice).toList();

  StartingEquipmentChoice _parseEquipmentChoice(Element item) {
    final parts = item.innerHtml.split(RegExp(r'(?:^|\s)[абвгд]\)\s*')).map((e) => e.trim()).where((e) => e.isNotEmpty);
    return StartingEquipmentChoice(
      options: parts.map((part) {
        final html = part.replaceFirst(RegExp(r'(,|\s+или)\s*$'), '');
        return StartingEquipmentOption(
          text: TtgText.capitalize(TtgText.plainText(html)),
          items: TtgText.splitTopLevel(html.replaceAll(RegExp(r'\s+и\s+'), ', ')).map(_parseEquipmentRef).toList(),
        );
      }).toList(),
    );
  }

  /// «Два <a href="/weapons/dagger">кинжала</a>» → 2 × `/weapons/dagger`.
  EquipmentRef _parseEquipmentRef(String html) {
    final fragment = html_parser.parseFragment(html);
    final text = TtgText.plainText(html);
    final href = fragment.querySelector('a[href]')?.attributes['href'];
    final lower = text.toLowerCase();
    // Ссылки на разделы правил (`/screens/musical_instruments`) и предметы без ссылки
    // вроде «магической фокусировки» означают выбор из категории.
    final isCategory = (href != null && href.startsWith('/screens/')) ||
        (href == null && EquipmentCatalog.focusGroups.keys.any(lower.contains));
    return EquipmentRef(
      id: href == null || isCategory ? null : TtgText.normalizeLink(href),
      text: text,
      quantity: TtgText.leadingNumber(text) ?? 1,
      isChoice: isCategory || lower.startsWith('люб'),
    );
  }

  /// Абзацы раздела «Быстрое создание» в описании класса: абзац с этим заголовком и следующие
  /// абзацы до таблицы, заголовка или абзаца с новым выделенным заголовком.
  String? _quickBuild(String descriptionHtml) {
    final nodes = html_parser.parseFragment(descriptionHtml).children;
    final start = nodes.indexWhere((e) => TtgText.cleanText(e.text).startsWith('Быстрое создание'));
    if (start == -1) return null;
    bool isTitled(Element paragraph) =>
        paragraph.nodes.firstOrNull is Element && (paragraph.nodes.first as Element).localName == 'strong';
    // Заголовок раздела показывают экраны, поэтому из первого абзаца он убирается.
    final first = nodes[start].clone(true);
    if (isTitled(first)) first.nodes.first.remove();
    final content = [
      first,
      ...nodes.skip(start + 1).takeWhile((e) => e.localName == 'p' && !isTitled(e)),
    ];
    return content.map((e) => e.outerHtml).join('\n');
  }
}
