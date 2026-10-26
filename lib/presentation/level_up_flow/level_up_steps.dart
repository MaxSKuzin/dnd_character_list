import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/spell/spell_replacement.dart';
import 'package:flutter/widgets.dart';

/// Шаги повышения уровня классов, которые собираются по таблице класса с ttg.club.
extension LevelUpSteps on BuildContext {
  /// Открывает экран выбора и ждёт результат; `null` — пользователь вернулся назад.
  /// Чтобы отличить возврат назад от пропуска шага, необязательный выбор оборачивается в [Skippable].
  Future<T?> ask<T>(PageRouteInfo Function(void Function(T value) done) route) {
    if (!mounted) return Future.value();
    return pushRoute<T>(route((value) => maybePop(value)));
  }
}

/// Результат необязательного шага: `value == null` — шаг пропущен.
class Skippable<T> {
  final T? value;

  const Skippable(this.value);
}

typedef OptionalReplacement = Skippable<SpellReplacement>;
