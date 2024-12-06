enum WeaponWeight {
  light,
  regular,
  heavy;

  String get name => switch (this) {
        WeaponWeight.light => 'Легкое',
        WeaponWeight.regular => 'Обычное',
        WeaponWeight.heavy => 'Тяжелое',
      };
}
