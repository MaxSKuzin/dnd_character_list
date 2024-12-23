import 'dart:math';

class Balance {
  final int value;

  const Balance(this.value);

  factory Balance.fromGold(int gold) {
    return Balance(gold * 100);
  }

  factory Balance.fromSilver(int silver) {
    return Balance(silver * 10);
  }

  factory Balance.fromCopper(int copper) {
    return Balance(copper);
  }

  Balance operator +(Balance other) {
    return Balance(value + other.value);
  }

  Balance operator -(Balance other) {
    return Balance(max(0, value - other.value));
  }

  int get gold => value ~/ 100;

  int get silver => value % 100 ~/ 10;

  int get copper => value % 10;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Balance && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(json['value']);
  }
}
