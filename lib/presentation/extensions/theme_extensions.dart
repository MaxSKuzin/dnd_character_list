import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  final Color cardColor;

  CustomColors({required this.cardColor});

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? cardColor,
  }) {
    return CustomColors(cardColor: cardColor ?? this.cardColor);
  }

  @override
  ThemeExtension<CustomColors> lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }

    return CustomColors(
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
    );
  }
}


