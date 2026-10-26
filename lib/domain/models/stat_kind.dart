enum StatKind {
  strength,
  dexterity,
  constitution,
  intelligence,
  wisdom,
  charisma;

  String toJson() => name;

  factory StatKind.fromJson(String name) => StatKind.values.byName(name);
}
