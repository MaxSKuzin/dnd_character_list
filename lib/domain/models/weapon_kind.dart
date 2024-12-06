enum WeaponKind {
  simpleMelee,
  martialMelee,
  simpleRanged,
  martialRanged;

  bool get isMelee => switch (this) {
        simpleMelee => true,
        martialMelee => true,
        simpleRanged => false,
        martialRanged => false,
      };

  bool get isRanged => !isMelee;

  String get name => switch (this) {
        WeaponKind.simpleMelee => 'Простое рукопашное',
        WeaponKind.martialMelee => 'Воинское рукопашное',
        WeaponKind.simpleRanged => 'Просто дальнобойное',
        WeaponKind.martialRanged => 'Воинское дальнобойное',
      };
}
