import 'dart:convert';

/// Характеристика. Имена совпадают с `StatKind` приложения игрока.
enum Ability { strength, dexterity, constitution, intelligence, wisdom, charisma }

/// Класс персонажа в бою: «Бард (Коллегия знаний)», 3 уровень. [kind] — `ClassKind.name` приложения игрока,
/// например для иконки класса.
class CombatClass {
  final String kind;
  final String name;
  final int level;

  const CombatClass({required this.kind, required this.name, required this.level});

  Map<String, dynamic> toJson() => {'kind': kind, 'name': name, 'level': level};

  factory CombatClass.fromJson(Map<String, dynamic> json) =>
      CombatClass(kind: json['kind'], name: json['name'], level: json['level']);
}

/// Боевые данные персонажа, которые меняются редко: при повышении уровня, смене экипировки.
///
/// Только то, что нужно мастеру в бою. Описания умений, предыстория, внешность и инвентарь не передаются.
class CombatantProfile {
  final String name;
  final List<CombatClass> classes;

  /// Значения характеристик (не модификаторы).
  final Map<Ability, int> abilities;

  /// Бонусы спасбросков с учётом владения.
  final Map<Ability, int> savingThrows;
  final int armorClass;
  final int maxHits;
  final int initiative;
  final int speed;
  final int passivePerception;

  const CombatantProfile({
    required this.name,
    required this.classes,
    required this.abilities,
    required this.savingThrows,
    required this.armorClass,
    required this.maxHits,
    required this.initiative,
    required this.speed,
    required this.passivePerception,
  });

  int get level => classes.fold(0, (sum, e) => sum + e.level);

  Map<String, dynamic> toJson() => {
    'name': name,
    'classes': classes.map((e) => e.toJson()).toList(),
    'abilities': _abilitiesToJson(abilities),
    'savingThrows': _abilitiesToJson(savingThrows),
    'armorClass': armorClass,
    'maxHits': maxHits,
    'initiative': initiative,
    'speed': speed,
    'passivePerception': passivePerception,
  };

  factory CombatantProfile.fromJson(Map<String, dynamic> json) => CombatantProfile(
    name: json['name'],
    classes: (json['classes'] as List).map((e) => CombatClass.fromJson(e)).toList(),
    abilities: _abilitiesFromJson(json['abilities']),
    savingThrows: _abilitiesFromJson(json['savingThrows']),
    armorClass: json['armorClass'],
    maxHits: json['maxHits'],
    initiative: json['initiative'],
    speed: json['speed'],
    passivePerception: json['passivePerception'],
  );

  @override
  bool operator ==(Object other) => other is CombatantProfile && jsonEncode(this) == jsonEncode(other);

  @override
  int get hashCode => jsonEncode(this).hashCode;
}

/// Счётчик с максимумом: ячейки заклинаний уровня, ресурс класса («Вдохновение», «Единицы чародейства»).
class CombatCounter {
  final int current;
  final int max;

  const CombatCounter({required this.current, required this.max});

  /// Компактно, потому что состояние уходит в сеть при каждом изменении: `[текущее, максимум]`.
  List<int> toJson() => [current, max];

  factory CombatCounter.fromJson(List json) => CombatCounter(current: json[0], max: json[1]);
}

/// То, что меняется в бою: хиты, спасброски от смерти, ячейки, ресурсы классов.
class CombatantState {
  final int currentHits;
  final int deathSuccesses;
  final int deathFailures;
  final bool isDead;

  /// Нокаут после трёх успешных спасбросков от смерти: 1 хит, без сознания, пока не приведут в чувство.
  final bool isKnockedOut;

  /// Ячейки заклинаний по уровню (1–9). Текущее значение может превышать максимум (ячейки из единиц чародейства).
  final Map<int, CombatCounter> spellSlots;

  /// Ресурсы классов по названию: «Вдохновение» → 2/3.
  final Map<String, CombatCounter> counters;

  const CombatantState({
    required this.currentHits,
    this.deathSuccesses = 0,
    this.deathFailures = 0,
    this.isDead = false,
    this.isKnockedOut = false,
    this.spellSlots = const {},
    this.counters = const {},
  });

  Map<String, dynamic> toJson() => {
    'hits': currentHits,
    if (deathSuccesses > 0) 'deathOk': deathSuccesses,
    if (deathFailures > 0) 'deathFail': deathFailures,
    if (isDead) 'dead': true,
    if (isKnockedOut) 'ko': true,
    if (spellSlots.isNotEmpty) 'slots': spellSlots.map((key, value) => MapEntry('$key', value.toJson())),
    if (counters.isNotEmpty) 'counters': counters.map((key, value) => MapEntry(key, value.toJson())),
  };

  factory CombatantState.fromJson(Map<String, dynamic> json) => CombatantState(
    currentHits: json['hits'],
    deathSuccesses: json['deathOk'] ?? 0,
    deathFailures: json['deathFail'] ?? 0,
    isDead: json['dead'] ?? false,
    isKnockedOut: json['ko'] ?? false,
    spellSlots: {
      for (final e in ((json['slots'] ?? {}) as Map).entries) int.parse(e.key): CombatCounter.fromJson(e.value),
    },
    counters: {
      for (final e in ((json['counters'] ?? {}) as Map).entries) e.key as String: CombatCounter.fromJson(e.value),
    },
  );

  @override
  bool operator ==(Object other) => other is CombatantState && jsonEncode(this) == jsonEncode(other);

  @override
  int get hashCode => jsonEncode(this).hashCode;
}

Map<String, int> _abilitiesToJson(Map<Ability, int> values) => values.map((key, value) => MapEntry(key.name, value));

Map<Ability, int> _abilitiesFromJson(Map json) =>
    json.map((key, value) => MapEntry(Ability.values.byName(key), value as int));
