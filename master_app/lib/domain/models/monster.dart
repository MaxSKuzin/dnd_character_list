import 'dart:math';

import 'package:dnd_session/dnd_session.dart';

/// Формула костей: «2к8 + 2». Кости пишутся кириллицей, как в приложении игрока.
class DiceFormula {
  final int count;
  final int sides;
  final int bonus;

  const DiceFormula(this.count, this.sides, [this.bonus = 0]);

  /// Постоянное значение без костей — у некоторых существ хиты указаны без формулы.
  const DiceFormula.fixed(int value) : this(0, 0, value);

  /// Среднее значение с округлением вниз — так в статблоках считаются хиты.
  int get average => count * (sides + 1) ~/ 2 + bonus;

  int roll(Random random) => List.generate(count, (_) => random.nextInt(sides) + 1).fold(bonus, (sum, e) => sum + e);

  @override
  String toString() => count == 0
      ? '$bonus'
      : bonus == 0
      ? '$countк$sides'
      : '$countк$sides ${bonus > 0 ? '+' : '−'} ${bonus.abs()}';

  List<int> toJson() => [count, sides, bonus];

  factory DiceFormula.fromJson(Object? json) {
    final [count, sides, bonus] = (json as List).cast<int>();
    return DiceFormula(count, sides, bonus);
  }
}

/// Особенность или действие из статблока: «Проворный побег», «Скимитар».
class MonsterFeature {
  final String name;
  final String text;

  const MonsterFeature(this.name, this.text);

  List<String> toJson() => [name, text];

  factory MonsterFeature.fromJson(Object? json) {
    final [name, text] = (json as List).cast<String>();
    return MonsterFeature(name, text);
  }
}

/// Монстр из бестиария — шаблон, по которому в бой добавляются отдельные экземпляры.
class MonsterTemplate {
  /// Встроенные монстры — `goblin`, загруженные с ttg.club — ссылка `/bestiary/goblin`.
  final String id;
  final String name;

  /// «Маленький гуманоид (гоблиноид), нейтрально-злой».
  final String kind;

  /// Показатель опасности: «1/4».
  final String challenge;
  final int experience;
  final int armorClass;

  /// Чем дан КД: «кожаный доспех, щит».
  final String? armorNote;
  final DiceFormula hitDice;

  /// Скорость ходьбы в футах.
  final int speed;

  /// Другие скорости: «летая 80 фт., лазая 40 фт.».
  final String? speedNote;
  final AbilityScores abilities;
  final int passivePerception;

  /// Строки статблока между характеристиками и особенностями: «Спасброски», «Иммунитет к урону», «Языки».
  final List<MonsterFeature> properties;
  final List<MonsterFeature> traits;
  final List<MonsterFeature> actions;
  final List<MonsterFeature> bonusActions;
  final List<MonsterFeature> reactions;
  final List<MonsterFeature> legendaryActions;

  const MonsterTemplate({
    required this.id,
    required this.name,
    required this.kind,
    required this.challenge,
    required this.experience,
    required this.armorClass,
    this.armorNote,
    required this.hitDice,
    required this.speed,
    this.speedNote,
    required this.abilities,
    required this.passivePerception,
    this.properties = const [],
    this.traits = const [],
    required this.actions,
    this.bonusActions = const [],
    this.reactions = const [],
    this.legendaryActions = const [],
  });

  int get averageHits => hitDice.average;

  /// Инициатива — проверка Ловкости.
  int get initiative => abilityModifier(abilities[Ability.dexterity]);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kind': kind,
    'challenge': challenge,
    'experience': experience,
    'armorClass': armorClass,
    'armorNote': ?armorNote,
    'hitDice': hitDice.toJson(),
    'speed': speed,
    'speedNote': ?speedNote,
    'abilities': abilities.toJson(),
    'passivePerception': passivePerception,
    'properties': _featuresToJson(properties),
    'traits': _featuresToJson(traits),
    'actions': _featuresToJson(actions),
    'bonusActions': _featuresToJson(bonusActions),
    'reactions': _featuresToJson(reactions),
    'legendaryActions': _featuresToJson(legendaryActions),
  };

  factory MonsterTemplate.fromJson(Map<String, dynamic> json) => MonsterTemplate(
    id: json['id'],
    name: json['name'],
    kind: json['kind'],
    challenge: json['challenge'],
    experience: json['experience'],
    armorClass: json['armorClass'],
    armorNote: json['armorNote'],
    hitDice: DiceFormula.fromJson(json['hitDice']),
    speed: json['speed'],
    speedNote: json['speedNote'],
    abilities: AbilityScores.fromJson(json['abilities']),
    passivePerception: json['passivePerception'],
    properties: _featuresFromJson(json['properties']),
    traits: _featuresFromJson(json['traits']),
    actions: _featuresFromJson(json['actions']),
    bonusActions: _featuresFromJson(json['bonusActions']),
    reactions: _featuresFromJson(json['reactions']),
    legendaryActions: _featuresFromJson(json['legendaryActions']),
  );

  static List<Object?> _featuresToJson(List<MonsterFeature> features) => features.map((e) => e.toJson()).toList();

  static List<MonsterFeature> _featuresFromJson(Object? json) =>
      (json as List? ?? const []).map(MonsterFeature.fromJson).toList();
}

int abilityModifier(int value) => value ~/ 2 - 5;

/// Характеристики статблока в привычном порядке: Сил, Лов, Тел, Инт, Мдр, Хар.
class AbilityScores {
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  const AbilityScores(this.strength, this.dexterity, this.constitution, this.intelligence, this.wisdom, this.charisma);

  int operator [](Ability ability) => switch (ability) {
    Ability.strength => strength,
    Ability.dexterity => dexterity,
    Ability.constitution => constitution,
    Ability.intelligence => intelligence,
    Ability.wisdom => wisdom,
    Ability.charisma => charisma,
  };

  List<int> toJson() => [strength, dexterity, constitution, intelligence, wisdom, charisma];

  factory AbilityScores.fromJson(Object? json) {
    final [str, dex, con, intel, wis, cha] = (json as List).cast<int>();
    return AbilityScores(str, dex, con, intel, wis, cha);
  }
}
