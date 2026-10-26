import 'package:collection/collection.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/class_option.dart';
import 'package:dnd_character_list/domain/models/classes/monk.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_option_screen/select_option_screen.dart';
import 'package:dnd_character_list/presentation/level_up_flow/level_up_steps.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Повышение уровня монаха по таблице класса с ttg.club: монастырская традиция на уровне подкласса
/// и «Увеличение характеристик»; кость боевых искусств, очки ци и скорость — из столбцов таблицы.
class MonkLevelUp {
  final BuildContext context;
  final Player player;
  final ClassInfo info;

  /// Текущий монах персонажа или `null`, если монах берётся мультиклассом.
  final Monk? monk;

  MonkLevelUp({
    required this.context,
    required this.player,
    required this.info,
    required this.monk,
  });

  /// Проводит пользователя по выборам и передаёт результат в [LevelUpCubit].
  /// Возвращает `false`, если пользователь вернулся назад.
  Future<bool> run() async {
    final level = (monk?.level ?? 0) + 1;
    final row = info.level(level);

    // Мультиклассирование в монаха даёт только владение простым оружием и короткими мечами.
    var traditionId = monk?.traditionId;
    var traditionName = monk?.traditionName;
    if (level == info.subclassLevel && traditionId == null) {
      final tradition = await context.ask<Subclass>(
        (done) => SelectSubclassRoute(
          title: info.subclassTitle ?? 'Монастырская традиция',
          subclasses: info.subclasses,
          onSelected: done,
        ),
      );
      if (tradition == null) return false;
      traditionId = tradition.id;
      traditionName = tradition.name;
    }

    final improvements = [...?monk?.improvements];
    if (row.hasFeature(Monk.abilityScoreImprovement)) {
      final improvement = await context.ask<AbilityScoreImprovement>(
        (done) => AbilityScoreImprovementRoute(player: player, level: level, onSelected: done),
      );
      if (improvement == null) return false;
      improvements.add(improvement);
    }

    // «Адепт стихий» Пути Четырёх Стихий: «Родство со стихией» и практики на выбор.
    final disciplines = [...?monk?.disciplines];
    if (traditionId == Monk.fourElements) {
      final List<ElementalDiscipline> all;
      try {
        all = await getIt<RulesRepository>().getOptions(ClassOptionKind.elementalDiscipline);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось загрузить стихийные практики с ttg.club: $e')),
          );
        }
        return false;
      }
      final attunement = all.firstWhereOrNull((e) => e.link == Monk.elementalAttunement);
      if (attunement != null && !disciplines.contains(attunement)) disciplines.insert(0, attunement);

      final chosen = disciplines.where((e) => e.link != Monk.elementalAttunement).length;
      final newCount = Monk.disciplinesCountAt(level) - chosen;
      if (newCount > 0 && context.mounted) {
        // Изучая новую практику, можно заменить одну из ранее изученных.
        final replaceable = disciplines.where((e) => e.link != Monk.elementalAttunement).toList();
        if (replaceable.isNotEmpty) {
          final index = await context.ask<int>(
            (done) => SelectOptionRoute(
              title: 'Замена практики',
              description: 'Изучая новую практику, можно заменить одну из ранее изученных.',
              options: [
                for (final e in replaceable) SelectOption(title: 'Заменить «${e.name}»'),
                const SelectOption(title: 'Ничего не менять'),
              ],
              onSelected: done,
            ),
          );
          if (index == null) return false;
          if (index < replaceable.length) {
            final replacement = await context.ask<List<ElementalDiscipline>>(
              (done) => SelectClassOptionsRoute(
                kind: ClassOptionKind.elementalDiscipline,
                title: 'Новая практика',
                description: 'Вместо практики «${replaceable[index].name}».',
                count: 1,
                known: disciplines,
                maxLevel: level,
                onSelected: done,
              ),
            );
            if (replacement == null) return false;
            disciplines[disciplines.indexOf(replaceable[index])] = replacement.single;
          }
        }
        if (!context.mounted) return false;
        final learned = await context.ask<List<ElementalDiscipline>>(
          (done) => SelectClassOptionsRoute(
            kind: ClassOptionKind.elementalDiscipline,
            description: 'Монах $level уровня изучает новую стихийную практику. Практики тратят очки ци.',
            count: newCount,
            known: disciplines,
            maxLevel: level,
            onSelected: done,
          ),
        );
        if (learned == null) return false;
        disciplines.addAll(learned);
      }
    }

    if (!context.mounted) return false;
    context.read<LevelUpCubit>().setSpecialization(
          Monk(
            level: level,
            isMain: monk?.isMain ?? false,
            features: [...?monk?.features, ...Monk.featuresAt(info, level, traditionId: traditionId)],
            traditionId: traditionId,
            traditionName: traditionName,
            improvements: improvements,
            disciplines: disciplines,
            martialArtsDice: Monk.martialArtsDiceAt(info, level),
            kiPoints: Monk.kiPointsAt(info, level),
            unarmoredMovement: Monk.unarmoredMovementAt(info, level),
          ),
        );
    return true;
  }
}
