enum ClassExtras {
  rage,
  inspiration,
  godFeeling,
  layingOfHands,
  ci;

  String get name => switch (this) {
        ClassExtras.rage => 'Ярость',
        ClassExtras.inspiration => 'Вдоховение',
        ClassExtras.ci => 'Ци',
        ClassExtras.godFeeling => 'Божественное чувство',
        ClassExtras.layingOfHands => 'Наложение рук',
      };
}
