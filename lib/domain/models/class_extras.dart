enum ClassExtras {
  rage,
  inspiration,
  godFeeling,
  layingOfHands,
  ci,
  sorceryPoints,
  secondWind,
  actionSurge,
  indomitable,
  superiorityDice;

  String get name => switch (this) {
        ClassExtras.rage => 'Ярость',
        ClassExtras.inspiration => 'Вдоховение',
        ClassExtras.ci => 'Очки ци',
        ClassExtras.godFeeling => 'Божественное чувство',
        ClassExtras.layingOfHands => 'Наложение рук',
        ClassExtras.sorceryPoints => 'Единицы чародейства',
        ClassExtras.secondWind => 'Второе дыхание',
        ClassExtras.actionSurge => 'Всплеск действий',
        ClassExtras.indomitable => 'Упорный',
        ClassExtras.superiorityDice => 'Кости превосходства',
      };
}
