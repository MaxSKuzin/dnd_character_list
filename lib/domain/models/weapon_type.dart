enum WeaponType {
  oneHanded,
  twoHanded,
  universal;

  String get name => switch (this) {
        WeaponType.oneHanded => 'Одноручное',
        WeaponType.twoHanded => 'Друручное',
        WeaponType.universal => 'Универсальное',
      };
}
