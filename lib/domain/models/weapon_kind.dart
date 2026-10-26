enum WeaponKind {
  simpleMelee,
  martialMelee,
  simpleRanged,
  martialRanged;

  bool get isMelee => this == simpleMelee || this == martialMelee;

  bool get isRanged => !isMelee;

  bool get isSimple => this == simpleMelee || this == simpleRanged;
}
