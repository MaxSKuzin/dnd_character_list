enum SpellTime {
  action,
  bonusAction,
  reaction,
  minute;

  String get name {
    switch (this) {
      case SpellTime.action:
        return 'Действие';
      case SpellTime.bonusAction:
        return 'Бонусное Действие';
      case SpellTime.reaction:
        return 'Реакция';
      case SpellTime.minute:
        return 'Минут';
    }
  }
}
