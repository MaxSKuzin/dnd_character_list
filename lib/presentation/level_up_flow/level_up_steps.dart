import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_option_screen/select_option_screen.dart';
import 'package:dnd_character_list/router.gr.dart';
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

  /// Языки на выбор, кроме уже известных [known]. `null` — пользователь вернулся назад.
  Future<List<Language>?> askLanguages(int count, List<Language> known, String description) => ask<List<Language>>(
        (done) => ProficienciesRoute(
          title: 'Языки',
          description: description,
          tools: const [],
          languagesCount: count,
          knownLanguages: known,
          onSelected: (_, languages) => done(languages),
        ),
      );

  /// Варианты умений архетипа, полученных на [level] уровне («Добыча охотника» → «Убийца колоссов»).
  /// Возвращает название умения в верхнем регистре → вариант; `null` — пользователь вернулся назад.
  Future<Map<String, String>?> askFeatureOptions(Subclass? subclass, int level) async {
    final choices = <String, String>{};
    for (final feature in subclass?.featuresAt(level) ?? const <SubclassFeature>[]) {
      if (feature.options.isEmpty) continue;
      final index = await ask<int>(
        (done) => SelectOptionRoute(
          title: feature.name,
          description: 'Выберите один вариант умения. Подробности — по кнопке «i».',
          options: [for (final e in feature.options) SelectOption(title: e.name, detailsHtml: e.descriptionHtml)],
          onSelected: done,
        ),
      );
      if (index == null) return null;
      choices[feature.name.toUpperCase()] = feature.options[index].name;
    }
    return choices;
  }
}

/// Результат необязательного шага: `value == null` — шаг пропущен.
class Skippable<T> {
  final T? value;

  const Skippable(this.value);
}

typedef OptionalReplacement = Skippable<SpellReplacement>;
