import 'dart:math';

class Dice {
  static final _random = Random();

  final int value;

  const Dice._(this.value);

  static Dice get k4 => const Dice._(4);

  static Dice get k6 => const Dice._(6);

  static Dice get k8 => const Dice._(8);

  static Dice get k10 => const Dice._(10);

  static Dice get k12 => const Dice._(12);

  static Dice get k20 => const Dice._(20);

  String get name => 'k$value';

  int roll() => _random.nextInt(value) + 1;

  @override
  bool operator ==(Object other) => other is Dice && other.value == value;

  @override
  int get hashCode => Object.hashAll([value]);
}
