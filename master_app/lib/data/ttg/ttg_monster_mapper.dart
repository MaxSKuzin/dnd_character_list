import 'package:dnd_master/domain/models/monster.dart';
import 'package:html/parser.dart' as html_parser;

/// Строка списка бестиария ttg.club: по ней ищут, а статблок загружается при выборе.
class MonsterSummary {
  /// Ссылка на сайте: `/bestiary/goblin`.
  final String url;
  final String name;
  final String englishName;

  /// «гуманоид».
  final String type;
  final String challenge;

  /// Книга: «MM».
  final String book;

  /// Официальные книги, а не UA, homebrew или сторонние источники.
  final bool isOfficial;

  const MonsterSummary({
    required this.url,
    required this.name,
    required this.englishName,
    required this.type,
    required this.challenge,
    required this.book,
    required this.isOfficial,
  });

  /// Совпадение по русскому или английскому названию без учёта регистра и «ё».
  bool matches(String query) {
    final normalized = TtgMonsterMapper.normalize(query);
    return TtgMonsterMapper.normalize(name).contains(normalized) ||
        TtgMonsterMapper.normalize(englishName).contains(normalized);
  }
}

/// Разбор ответов `/bestiary` ttg.club в модели мастера.
abstract final class TtgMonsterMapper {
  static String normalize(String text) => text.toLowerCase().replaceAll('ё', 'е').trim();

  static List<MonsterSummary> summaries(Object? json) => [
    for (final e in (json as List).cast<Map<String, dynamic>>())
      MonsterSummary(
        url: e['url'],
        name: (e['name']['rus'] as String).trim(),
        englishName: ((e['name']['eng'] as String?) ?? '').trim(),
        type: e['type'] ?? '',
        challenge: e['challengeRating'] ?? '—',
        book: e['source']?['shortName'] ?? '',
        isOfficial: e['source']?['group']?['shortName'] == 'Basic',
      ),
  ];

  static MonsterTemplate monster(Map<String, dynamic> json) {
    final type = json['type'] as Map<String, dynamic>;
    final tags = (type['tags'] as List?)?.cast<String>() ?? const [];
    final speeds = (json['speed'] as List).cast<Map<String, dynamic>>();
    final walk = speeds.where((e) => e['name'] == null).firstOrNull;
    final otherSpeeds = speeds.where((e) => e != walk).map(_speed).join(', ');
    final ability = json['ability'] as Map<String, dynamic>;
    final armors = (json['armors'] as List?)?.map((e) => e['name'] as String).join(', ');
    final legendary = json['legendary'] as Map<String, dynamic>?;

    return MonsterTemplate(
      id: json['url'],
      name: (json['name']['rus'] as String).trim(),
      kind: [
        '${json['size']['rus']} ${type['name']}${tags.isEmpty ? '' : ' (${tags.join(', ')})'}',
        if (json['alignment'] case final String alignment when alignment.isNotEmpty) alignment,
      ].join(', '),
      challenge: json['challengeRating'] ?? '—',
      experience: json['experience'] ?? 0,
      armorClass: json['armorClass'],
      armorNote: armors == null || armors.isEmpty ? null : armors,
      hitDice: _hitDice(json['hits']),
      speed: walk?['value'] ?? 0,
      speedNote: otherSpeeds.isEmpty ? null : otherSpeeds,
      abilities: AbilityScores(
        ability['str'],
        ability['dex'],
        ability['con'],
        ability['int'],
        ability['wiz'],
        ability['cha'],
      ),
      passivePerception: int.tryParse('${json['senses']?['passivePerception']}') ?? 10,
      properties: _properties(json),
      traits: _features(json['feats']),
      actions: _features(json['actions']),
      bonusActions: _features(json['bonusActions']),
      reactions: _features(json['reactions']),
      legendaryActions: [
        if (legendary?['description'] case final String description when plainText(description).isNotEmpty)
          MonsterFeature('Легендарные действия', plainText(description)),
        ..._features(legendary?['list']),
      ],
    );
  }

  /// `{"average": 135, "formula": "18к8", "bonus": 54}`; без формулы — только среднее.
  static DiceFormula _hitDice(Map<String, dynamic> json) {
    final match = RegExp(r'^(\d+)\s*к\s*(\d+)$').firstMatch('${json['formula'] ?? ''}'.trim());
    if (match == null) return DiceFormula.fixed(json['average']);
    return DiceFormula(int.parse(match[1]!), int.parse(match[2]!), json['bonus'] ?? 0);
  }

  /// `{"name": "летая", "value": 20, "additional": "парит"}` → «летая 20 фт. (парит)».
  static String _speed(Map<String, dynamic> json) => [
    json['name'],
    '${json['value']} фт.',
    if (json['additional'] case final String additional) '($additional)',
  ].whereType<String>().join(' ');

  static String _signed(int value) => value >= 0 ? '+$value' : '−${value.abs()}';

  static List<MonsterFeature> _properties(Map<String, dynamic> json) {
    List<String> strings(String key) => (json[key] as List?)?.cast<String>() ?? const [];
    List<Map<String, dynamic>> maps(String key) => (json[key] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final entries = <(String, String)>[
      ('Спасброски', maps('savingThrows').map((e) => '${e['shortName']} ${_signed(e['value'])}').join(', ')),
      ('Навыки', maps('skills').map((e) => '${e['name']} ${_signed(e['value'])}').join(', ')),
      ('Уязвимость к урону', strings('damageVulnerabilities').join(', ')),
      ('Сопротивление урону', strings('damageResistances').join(', ')),
      ('Иммунитет к урону', strings('damageImmunities').join(', ')),
      ('Иммунитет к состояниям', strings('conditionImmunities').join(', ')),
      (
        'Чувства',
        ((json['senses']?['senses'] as List?) ?? const [])
            .cast<Map<String, dynamic>>()
            .map((e) => '${e['name']} ${e['value']} фт.')
            .join(', '),
      ),
      ('Языки', strings('languages').join(', ')),
    ];
    return [
      for (final (name, text) in entries)
        if (text.isNotEmpty) MonsterFeature(name, text),
    ];
  }

  static List<MonsterFeature> _features(Object? json) => [
    for (final e in (json as List? ?? const []).cast<Map<String, dynamic>>())
      MonsterFeature((e['name'] as String).trim(), plainText(e['value'] ?? '')),
  ];

  /// Текст описания с сайта: абзацы — с новой строки, кубики `<dice-roller formula="1к6 + 2"/>` — формулой,
  /// без английских названий в квадратных скобках: «луч холода [ray of frost]» → «луч холода».
  static String plainText(String html) {
    final prepared = html
        .replaceAllMapped(RegExp(r'<dice-roller[^>]*formula="([^"]*)"[^>]*/>'), (m) => m[1]!)
        .replaceAll(RegExp(r'</(p|li|h\d)>\s*<'), '\n<');
    final text = html_parser.parseFragment(prepared).text ?? '';
    return text
        .split('\n')
        .map((e) => e.replaceAll(RegExp(r'\s*\[[^\]]*\]'), '').replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((e) => e.isNotEmpty)
        .join('\n');
  }
}
