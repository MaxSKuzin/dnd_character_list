class Stat {
  final int value;

  Stat({required this.value});

  int get bonus {
    final oddValue = value.isEven ? value : value - 1;
    return (oddValue - 10) ~/ 2;
  }
}
