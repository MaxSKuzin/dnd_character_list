enum DamageType {
  pricking,
  crushing,
  chopping;

  String get name => switch (this) {
        DamageType.pricking => 'Колющий',
        DamageType.crushing => 'Дробящий',
        DamageType.chopping => 'Рубящий',
      };
}
