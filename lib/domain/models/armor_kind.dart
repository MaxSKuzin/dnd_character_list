enum ArmorKind {
  light,
  medium,
  heavy;

  String get name {
    switch (this) {
      case ArmorKind.light:
        return 'Лёгкая';
      case ArmorKind.medium:
        return 'Средняя';
      case ArmorKind.heavy:
        return 'Тяжёлая';
    }
  }
}
