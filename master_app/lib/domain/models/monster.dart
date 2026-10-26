import 'dart:math';

import 'package:dnd_session/dnd_session.dart';

/// Формула костей: «2к8 + 2». Кости пишутся кириллицей, как в приложении игрока.
class DiceFormula {
  final int count;
  final int sides;
  final int bonus;

  const DiceFormula(this.count, this.sides, [this.bonus = 0]);

  /// Среднее значение с округлением вниз — так в статблоках считаются хиты.
  int get average => count * (sides + 1) ~/ 2 + bonus;

  int roll(Random random) => List.generate(count, (_) => random.nextInt(sides) + 1).fold(bonus, (sum, e) => sum + e);

  @override
  String toString() => bonus == 0 ? '$countк$sides' : '$countк$sides ${bonus > 0 ? '+' : '−'} ${bonus.abs()}';
}

/// Особенность или действие из статблока: «Проворный побег», «Скимитар».
class MonsterFeature {
  final String name;
  final String text;

  const MonsterFeature(this.name, this.text);
}

/// Монстр из бестиария — шаблон, по которому в бой добавляются отдельные экземпляры.
class MonsterTemplate {
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
  final AbilityScores abilities;
  final int passivePerception;
  final List<MonsterFeature> traits;
  final List<MonsterFeature> actions;

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
    required this.abilities,
    required this.passivePerception,
    this.traits = const [],
    required this.actions,
  });

  int get averageHits => hitDice.average;

  /// Инициатива — проверка Ловкости.
  int get initiative => abilityModifier(abilities[Ability.dexterity]);
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
}
