import 'package:flutter/material.dart';

/// [ScaffoldMessenger], который показывает одно уведомление за раз: новое сразу убирает прежнее, без очереди.
/// Ставится над всем приложением (`MaterialApp.builder`), поэтому так работают все `ScaffoldMessenger.of(context)`.
/// Иначе при серии реакций или урона уведомления копятся и идут друг за другом очень долго.
class SingleSnackBarMessenger extends ScaffoldMessenger {
  const SingleSnackBarMessenger({super.key, required super.child});

  @override
  ScaffoldMessengerState createState() => _SingleSnackBarMessengerState();
}

class _SingleSnackBarMessengerState extends ScaffoldMessengerState {
  @override
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    SnackBar snackBar, {
    AnimationStyle? snackBarAnimationStyle,
  }) {
    // Все уведомления идут сюда, поэтому в очереди не больше одного: достаточно убрать текущее.
    removeCurrentSnackBar();
    return super.showSnackBar(snackBar, snackBarAnimationStyle: snackBarAnimationStyle);
  }
}
