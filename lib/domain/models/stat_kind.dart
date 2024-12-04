enum StatKind {
  strength,
  dexterity,
  constitution,
  intelligence,
  wisdom,
  charisma;

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
