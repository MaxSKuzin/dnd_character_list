enum ClassExtras {
  rage,
  inspiration,
  ci;

  String get name => switch (this) {
      ClassExtras.rage => 'Ярость',
      ClassExtras.inspiration => 'Вдоховение',
      ClassExtras.ci => 'Ци',
    };

  
}
