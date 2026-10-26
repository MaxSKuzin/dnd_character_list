import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/monk.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/presentation/level_up_flow/level_up_steps.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/widgets.dart';
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

    if (!context.mounted) return false;
    context.read<LevelUpCubit>().setSpecialization(
          Monk(
            level: level,
            isMain: monk?.isMain ?? false,
            features: [...?monk?.features, ...Monk.featuresAt(info, level, traditionId: traditionId)],
            traditionId: traditionId,
            traditionName: traditionName,
            improvements: improvements,
            martialArtsDice: Monk.martialArtsDiceAt(info, level),
            kiPoints: Monk.kiPointsAt(info, level),
            unarmoredMovement: Monk.unarmoredMovementAt(info, level),
          ),
        );
    return true;
  }
}
