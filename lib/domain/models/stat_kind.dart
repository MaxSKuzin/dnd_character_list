enum StatKind {
  strength,
  dexterity,
  constitution,
  intelligence,
  wisdom,
  charisma;

  String toJson() => switch (this) {
        StatKind.strength => 'strength',
        StatKind.dexterity => 'dexterity',
        StatKind.constitution => 'constitution',
        StatKind.intelligence => 'intelligence',
        StatKind.wisdom => 'wisdom',
        StatKind.charisma => 'charisma',
      };

  factory StatKind.fromJson(String name) => switch (name) {
        'strength' => StatKind.strength,
        'dexterity' => StatKind.dexterity,
        'constitution' => StatKind.constitution,
        'intelligence' => StatKind.intelligence,
        'wisdom' => StatKind.wisdom,
        'charisma' => StatKind.charisma,
        _ => throw 'No such value',
      };

  String get name {
    switch (this) {
      case StatKind.strength:
        return 'Сила';
      case StatKind.dexterity:
        return 'Ловкость';
      case StatKind.constitution:
        return 'Телосложение';
      case StatKind.intelligence:
        return 'Интеллект';
      case StatKind.wisdom:
        return 'Мудрость';
      case StatKind.charisma:
        return 'Харизма';
    }
  }
}
