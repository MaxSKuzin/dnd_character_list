import 'package:dnd_character_list/data/ttg/ttg_client.dart';
import 'package:dnd_character_list/data/ttg/ttg_text.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_component.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:injectable/injectable.dart';

/// Переводит ответы раздела `/spells` в [Spell] и [SpellDetails].
@lazySingleton
class TtgSpellsMapper {
  /// Классы из официальных книг; остальные (шаман, магус) на сайте — homebrew.
  static const _officialClasses = {
    'artificer',
    'barbarian',
    'bard',
    'cleric',
    'druid',
    'fighter',
    'monk',
    'paladin',
    'ranger',
    'rogue',
    'sorcerer',
    'warlock',
    'wizard',
  };

  /// Запрос заклинаний класса: фильтр требует перечислить уровни и книги, иначе api отвечает ошибкой.
  static Map<String, Object?> classSpellsRequest(ClassKind classKind, List<String> books) => {
        ...TtgClient.allItems,
        'filter': {
          'class': ['${classKind.ttgSpellsFilterId}'],
          'level': [for (var i = 0; i <= 9; i++) '$i'],
          'book': books,
        },
      };

  /// Краткие данные из списка; классы, у которых оно есть, приходят отдельными запросами.
  Spell mapListItem(Map<String, dynamic> json, List<ClassKind> classes) {
    final (name, nameEn) = TtgText.names(json['name']);
    final components = json['components'] as Map<String, dynamic>? ?? const {};
    return Spell(
      link: TtgText.normalizeLink(json['url']),
      name: name,
      nameEn: nameEn,
      slot: SpellSlot.fromLevel(json['level']),
      school: json['school'] ?? '',
      isConcentration: json['concentration'] == true,
      isRitual: json['ritual'] == true,
      components: [
        if (_has(components['v'])) SpellComponent.verbal,
        if (_has(components['s'])) SpellComponent.somatic,
        if (_has(components['m'])) SpellComponent.material,
      ],
      allowedSpecializations: classes,
    );
  }

  SpellDetails mapDetails(Map<String, dynamic> json) {
    final level = json['level'] as int;
    final school = json['school'] as String? ?? '';
    final components = json['components'] as Map<String, dynamic>? ?? const {};
    final material = components['m'];
    final classes = (json['classes'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .where((e) => _officialClasses.contains(TtgText.slug(e['url'])))
        .map((e) => e['name'] as String)
        .toList();
    final subclasses = (json['subclasses'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .where((e) => _officialClasses.contains(TtgText.slug((e['url'] as String).split('/').take(3).join('/'))))
        .map((e) => '${e['name']} (${e['class']})')
        .toList();
    return SpellDetails(
      levelAndSchool: [
        level == 0 ? 'Заговор, $school' : '$level уровень, $school',
        if (json['ritual'] == true) ' (ритуал)',
      ].join(),
      castTime: json['time'] ?? '',
      distance: json['range'] ?? '',
      components: [
        if (_has(components['v'])) 'В',
        if (_has(components['s'])) 'С',
        if (_has(material)) material is String ? 'М ($material)' : 'М',
      ].join(', '),
      duration: json['duration'] ?? '',
      classes: classes.isEmpty ? null : classes.join(', '),
      subclasses: subclasses.isEmpty ? null : subclasses.join(', '),
      source: (json['source'] as Map?)?['name'],
      descriptionHtml: [
        TtgText.html(json['description']),
        if (json['upper'] != null) '<p><strong><em>На больших уровнях. </em></strong>${json['upper']}</p>',
      ].join('\n'),
    );
  }

  static bool _has(Object? component) => component != null && component != false;
}
