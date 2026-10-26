import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/class_option.dart';
import 'package:dnd_character_list/domain/models/classes/fighter.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_option_screen/select_option_screen.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/level_up_flow/level_up_steps.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Повышение уровня воина по таблице класса с ttg.club: боевой стиль на 1 уровне, архетип на уровне подкласса,
/// «Увеличение характеристик» и «Военная разносторонность» (TCE), второй стиль чемпиона, инструмент мастера
/// боевых искусств и приёмы. Использования «Всплеска действий» и «Упорного» — из подписей умений в таблице.
class FighterLevelUp {
  final BuildContext context;
  final Player player;
  final ClassInfo info;

  /// Текущий воин персонажа или `null`, если воин берётся мультиклассом.
  final Fighter? fighter;

  FighterLevelUp({
    required this.context,
    required this.player,
    required this.info,
    required this.fighter,
  });

  Future<FightingStyle?> _askStyle(List<FightingStyle> known) => context.ask<FightingStyle>(
        (done) => SelectFightingStyleRoute(
          styles: FightingStyle.fighterStyles.where((e) => !known.contains(e)).toList(),
          onStyleSelected: done,
        ),
      );

  Future<List<Maneuver>?> _askManeuvers(int count, List<Maneuver> known, {String? title, String? description}) =>
      context.ask<List<Maneuver>>(
        (done) => SelectClassOptionsRoute(
          kind: ClassOptionKind.maneuver,
          title: title,
          description: description,
          count: count,
          known: known,
          onSelected: done,
        ),
      );

  /// Замена одного известного приёма другим; `false` — пользователь вернулся назад.
  Future<bool> _replaceManeuver(List<Maneuver> maneuvers, int index) async {
    final replacement = await _askManeuvers(
      1,
      maneuvers,
      title: 'Новый приём',
      description: 'Вместо приёма «${maneuvers[index].name}».',
    );
    if (replacement == null) return false;
    maneuvers[index] = replacement.single;
    return true;
  }

  /// Проводит пользователя по выборам и передаёт результат в [LevelUpCubit].
  /// Возвращает `false`, если пользователь вернулся назад.
  Future<bool> run() async {
    final level = (fighter?.level ?? 0) + 1;
    final row = info.level(level);

    // «Боевой стиль» — умение 1 уровня, его получает и воин мультиклассом.
    var styles = [...?fighter?.fightingStyles];
    if (level == 1) {
      final style = await _askStyle(styles);
      if (style == null) return false;
      styles.add(style);
    }

    var archetypeId = fighter?.archetypeId;
    var archetypeName = fighter?.archetypeName;
    final tools = <String>[];
    if (level == info.subclassLevel && archetypeId == null) {
      final archetype = await context.ask<Subclass>(
        (done) => SelectSubclassRoute(
          title: info.subclassTitle ?? 'Воинский архетип',
          subclasses: info.subclasses,
          onSelected: done,
        ),
      );
      if (archetype == null) return false;
      archetypeId = archetype.id;
      archetypeName = archetype.name;

      // «Ученик войны» мастера боевых искусств: один вид инструментов ремесленников.
      if (archetypeId == Fighter.battleMaster) {
        final selected = await context.ask<List<String>>(
          (done) => ProficienciesRoute(
            title: 'Ученик войны',
            description: 'Мастер боевых искусств осваивает один вид инструментов ремесленников.',
            knownTools: player.toolProficiencies,
            tools: const [
              ToolProficiencyOption(
                title: 'Один вид инструментов ремесленников',
                category: ToolCategory.craftsmenTool,
                choose: 1,
              ),
            ],
            onSelected: (tools, _) => done(tools),
          ),
        );
        if (selected == null) return false;
        tools.addAll(selected);
      }
    }

    // Навык или язык кавалериста и самурая, «Посланник короны» рыцаря Пурпурного Дракона.
    final archetypeSkills = [...?fighter?.archetypeSkills];
    final archetypeLanguages = [...?fighter?.archetypeLanguages];
    if (Fighter.bonusProficiencyLevels[archetypeId] == level) {
      final known = player.chosenSkills;
      final skills = Fighter.bonusSkills[archetypeId]!.where((e) => !known.contains(e)).toList();
      if (archetypeId == Fighter.purpleDragon && !known.contains(Skill.persuasion)) {
        archetypeSkills.add(Skill.persuasion);
      } else {
        final canLearnLanguage = archetypeId != Fighter.purpleDragon;
        final index = await context.ask<int>(
          (done) => SelectOptionRoute(
            title: archetypeId == Fighter.purpleDragon ? 'Посланник короны' : 'Дополнительные навыки',
            description: archetypeId == Fighter.purpleDragon
                ? 'Убеждением вы уже владеете: выберите другой навык.'
                : 'Владение одним из навыков или один язык на выбор.',
            options: [
              for (final skill in skills) SelectOption(title: skill.localizedName),
              if (canLearnLanguage) const SelectOption(title: 'Язык на выбор'),
            ],
            onSelected: done,
          ),
        );
        if (index == null) return false;
        if (index < skills.length) {
          archetypeSkills.add(skills[index]);
        } else {
          if (!context.mounted) return false;
          final language = await context.askLanguages(1, player.knownLanguages, 'Один язык на выбор.');
          if (language == null) return false;
          archetypeLanguages.addAll(language);
        }
      }
    }

    // «Дополнительный боевой стиль» чемпиона.
    if (archetypeId == Fighter.champion && level == Fighter.additionalFightingStyleLevel) {
      final style = await _askStyle(styles);
      if (style == null) return false;
      styles.add(style);
    }

    final improvements = [...?fighter?.improvements];
    final maneuvers = [...?fighter?.maneuvers];
    if (row.hasFeature(Fighter.abilityScoreImprovement)) {
      final improvement = await context.ask<AbilityScoreImprovement>(
        (done) => AbilityScoreImprovementRoute(player: player, level: level, onSelected: done),
      );
      if (improvement == null) return false;
      improvements.add(improvement);

      // «Военная разносторонность»: замена одного боевого стиля или одного приёма.
      if (info.feature(Fighter.martialVersatility) != null && (styles.isNotEmpty || maneuvers.isNotEmpty)) {
        final options = [
          for (final style in styles) SelectOption(title: 'Заменить стиль «${style.title}»'),
          for (final maneuver in maneuvers) SelectOption(title: 'Заменить приём «${maneuver.name}»'),
          const SelectOption(title: 'Ничего не менять'),
        ];
        final index = await context.ask<int>(
          (done) => SelectOptionRoute(
            title: 'Военная разносторонность',
            description: 'Можно заменить выбранный ранее боевой стиль или известный приём другим.',
            options: options,
            onSelected: done,
          ),
        );
        if (index == null) return false;
        if (index < styles.length) {
          final style = await _askStyle(styles);
          if (style == null) return false;
          styles = [...styles]..[index] = style;
        } else if (index < styles.length + maneuvers.length) {
          if (!await _replaceManeuver(maneuvers, index - styles.length)) return false;
        }
      }
    }

    // Приёмы: мастер боевых искусств узнаёт новые на 3, 7, 10 и 15 уровнях и может заменить один из известных;
    // «Превосходная техника» даёт ещё один. Если стиль заменён, его приём забывается.
    final expected = Fighter.maneuversCount(level: level, archetypeId: archetypeId, styles: styles);
    final learnsNew = expected > maneuvers.length;
    if (learnsNew && archetypeId == Fighter.battleMaster && maneuvers.isNotEmpty) {
      final index = await context.ask<int>(
        (done) => SelectOptionRoute(
          title: 'Замена приёма',
          description: 'Изучая новые приёмы, можно заменить один из известных.',
          options: [
            for (final maneuver in maneuvers) SelectOption(title: 'Заменить «${maneuver.name}»'),
            const SelectOption(title: 'Ничего не менять'),
          ],
          onSelected: done,
        ),
      );
      if (index == null) return false;
      if (index < maneuvers.length && !await _replaceManeuver(maneuvers, index)) return false;
    }
    if (learnsNew) {
      final count = expected - maneuvers.length;
      final learned = await _askManeuvers(
        count,
        maneuvers,
        description: 'Воин $level уровня изучает новые приёмы. Во время одной атаки можно использовать только один '
            'приём; каждый тратит кость превосходства.',
      );
      if (learned == null) return false;
      maneuvers.addAll(learned);
    }
    while (maneuvers.length > expected) {
      final index = await context.ask<int>(
        (done) => SelectOptionRoute(
          title: 'Забыть приём',
          description: 'Стиль «Превосходная техника» заменён: выберите приём, который забудете.',
          options: [for (final maneuver in maneuvers) SelectOption(title: maneuver.name)],
          onSelected: done,
        ),
      );
      if (index == null) return false;
      maneuvers.removeAt(index);
    }

    if (!context.mounted) return false;
    final cubit = context.read<LevelUpCubit>();
    if (tools.isNotEmpty) cubit.setTools(tools);
    cubit.setSpecialization(
      Fighter(
        level: level,
        isMain: fighter?.isMain ?? false,
        features: [...?fighter?.features, ...Fighter.featuresAt(info, level, archetypeId: archetypeId)],
        fightingStyles: styles,
        archetypeId: archetypeId,
        archetypeName: archetypeName,
        improvements: improvements,
        maneuvers: maneuvers,
        archetypeTools: [...?fighter?.archetypeTools, ...tools],
        archetypeSkills: archetypeSkills,
        archetypeLanguages: archetypeLanguages,
        actionSurgeUses: Fighter.usesAt(info, Fighter.actionSurgeFeature, level),
        indomitableUses: Fighter.usesAt(info, Fighter.indomitableFeature, level),
      ),
    );
    return true;
  }
}
