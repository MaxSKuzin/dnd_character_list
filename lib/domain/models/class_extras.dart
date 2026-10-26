enum ClassExtras {
  rage,
  inspiration,
  godFeeling,
  layingOfHands,
  ci,
  sorceryPoints;

  String get name => switch (this) {
        ClassExtras.rage => 'Ярость',
        ClassExtras.inspiration => 'Вдоховение',
        ClassExtras.ci => 'Очки ци',
        ClassExtras.godFeeling => 'Божественное чувство',
        ClassExtras.layingOfHands => 'Наложение рук',
        ClassExtras.sorceryPoints => 'Единицы чародейства',
      };
}
