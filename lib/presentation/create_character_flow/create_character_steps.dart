import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Шаги создания персонажа в порядке «Книги игрока»: раса, класс, характеристики,
/// предыстория, затем выборы, которые от них зависят.
enum CreateCharacterStep {
  race,
  classKind,
  stats,
  raceStats,
  background,
  backgroundProficiencies,
  classSkills,
  raceSkills,
  expertise,
  classTools,
  equipment,
  spells,
  personality,
}

/// Порядок шагов создания персонажа. Экраны сохраняют выбор в [CreateCharacterCubit]
/// и вызывают [next]; какие шаги нужны конкретному персонажу, решается здесь.
abstract final class CreateCharacterSteps {
  /// Переходит к следующему шагу после [current], пропуская шаги, в которых нечего выбирать.
  static void next(BuildContext context, CreateCharacterStep current) {
    final cubit = context.read<CreateCharacterCubit>();
    for (final step in CreateCharacterStep.values.skip(current.index + 1)) {
      final route = _route(context, cubit, step);
      if (route != null) {
        context.pushRoute(route);
        return;
      }
    }
  }

  /// Маршрут шага или `null`, если выбирать нечего (тогда значения по умолчанию сохраняются сразу).
  static PageRouteInfo? _route(BuildContext context, CreateCharacterCubit cubit, CreateCharacterStep step) {
    final race = cubit.race!;
    final classKind = cubit.classKind!;
    final classInfo = cubit.classInfo;
    void next() => CreateCharacterSteps.next(context, step);

    switch (step) {
      case CreateCharacterStep.race:
      case CreateCharacterStep.classKind:
        return null;
      case CreateCharacterStep.stats:
        return FillStatsRoute(
          quickBuildHtml: classInfo?.quickBuildHtml,
          onStatsFilled: (stats) {
            cubit.setStats(stats);
            next();
          },
        );
      case CreateCharacterStep.raceStats:
        if (race.additionalStatsCount == 0) return null;
        return FillStatsRoute(
          maxPoints: race.additionalStatsCount,
          forbiddenStats: race.forbiddenStats,
          initialStats: cubit.stats!,
          isInitial: false,
          canSpendOnOneStat: false,
          title: 'Внесите дополнительные очки от расы',
          onStatsFilled: (bonuses) {
            cubit.setStats(cubit.stats!.map((key, value) => MapEntry(key, value + (bonuses[key] ?? 0))));
            next();
          },
        );
      case CreateCharacterStep.background:
        return SelectBackgroundRoute(onContinue: next);
      case CreateCharacterStep.backgroundProficiencies:
        final background = cubit.background!;
        final languages = race.additionalLanguagesCount + background.languagesCount;
        if (!background.tools.any((e) => e.isChoice) && languages == 0) {
          cubit.setBackgroundProficiencies(tools: _fixedTools(background.tools), languages: []);
          return null;
        }
        return ProficienciesRoute(
          title: 'Владение инструментами и языки',
          description: 'Предыстория «${background.name}»',
          tools: background.tools,
          languagesCount: languages,
          knownLanguages: race.knownLanguages,
          onSelected: (tools, languages) {
            cubit.setBackgroundProficiencies(tools: tools, languages: languages);
            next();
          },
        );
      case CreateCharacterStep.classSkills:
        final count = classInfo?.skillsCount ?? classKind.startSkillCount;
        final options = classInfo == null
            ? classKind.availableSkills
            : (classInfo.skillOptions.isEmpty ? Skill.values : classInfo.skillOptions);
        final className = classInfo?.name ?? classKind.localizedName;
        final backgroundSkills = cubit.background!.skills.map((e) => e.localizedName).join(', ');
        return _skillsRoute(
          cubit,
          'Владение навыками',
          [
            'Класс «$className»: выберите ${_skills(count)}'
                '${options.length == Skill.values.length ? ' на ваш выбор' : ' из списка класса'}.',
            if (backgroundSkills.isNotEmpty) 'Предыстория «${cubit.background!.name}» уже даёт: $backgroundSkills.',
          ].join('\n'),
          count,
          _notKnown(cubit, options, count),
          next,
        );
      case CreateCharacterStep.raceSkills:
        if (race.startSkillCount == 0) return null;
        final count = race.startSkillCount;
        return _skillsRoute(
          cubit,
          'Владение навыками',
          'Раса «${race.name}»: выберите ${_skills(count)} на ваш выбор.',
          count,
          _notKnown(cubit, race.availableSkills, count),
          next,
        );
      case CreateCharacterStep.expertise:
        final count = classKind.getDoubledSkillPoints(1);
        if (count == 0) return null;
        return _skillsRoute(
          cubit,
          'Компетентность',
          'Выберите ${_skills(count)} из тех, которыми владеете: бонус мастерства для них удваивается.',
          count,
          cubit.knownSkills,
          next,
        );
      case CreateCharacterStep.classTools:
        final tools = classInfo?.tools ?? const <ToolProficiencyOption>[];
        if (!tools.any((e) => e.isChoice)) {
          cubit.setClassTools(_fixedTools(tools));
          return null;
        }
        return ProficienciesRoute(
          title: 'Владение инструментами',
          description: 'Класс «${classInfo!.name}»: ${tools.map((e) => e.title.toLowerCase()).join(', ')}',
          tools: tools,
          knownTools: cubit.backgroundTools,
          onSelected: (tools, _) {
            cubit.setClassTools(tools);
            next();
          },
        );
      case CreateCharacterStep.equipment:
        return StartingEquipmentRoute(
          title: 'Снаряжение класса «${classInfo!.name}»',
          choices: classInfo.startingEquipment,
          onSelected: (items) {
            cubit.setInventoryItems(items);
            next();
          },
        );
      case CreateCharacterStep.spells:
        final firstLevel = classInfo?.level(1);
        final cantrips = firstLevel?.cantripsKnown ?? classKind.knownConspiracies(1);
        final spells = firstLevel?.spellsKnown ??
            classKind.knownSpellsCount(1, (stat) => Stat(value: cubit.stats![stat]!, kind: stat).bonus);
        if (cantrips == 0 && spells == 0) {
          cubit.setSpells([]);
          return null;
        }
        return SelectSpellsRoute(
          classKind: classKind,
          maxConspiracies: cantrips,
          maxSpells: spells,
          availableSlots: [
            if (cantrips > 0) SpellSlot.conspiracy,
            if (spells > 0) SpellSlot.level1,
          ],
          onSpellsSelected: (spells) {
            cubit.setSpells(spells);
            next();
          },
        );
      case CreateCharacterStep.personality:
        return SetPersonalityRoute(tables: cubit.background!.tables);
    }
  }

  static PageRouteInfo _skillsRoute(
    CreateCharacterCubit cubit,
    String title,
    String description,
    int count,
    List<Skill> options,
    VoidCallback next,
  ) =>
      SelectSkillsRoute(
        title: title,
        description: description,
        maxSkills: count,
        availableSkills: options,
        onSkillsSelected: (skills) {
          cubit.addSkills(skills);
          next();
        },
      );

  /// Навыки из [options], которыми персонаж ещё не владеет. Если таких меньше, чем нужно
  /// выбрать, по правилам можно взять любой другой навык.
  static List<Skill> _notKnown(CreateCharacterCubit cubit, List<Skill> options, int count) {
    final known = cubit.knownSkills;
    final available = options.where((e) => !known.contains(e)).toList();
    return available.length >= count ? available : Skill.values.where((e) => !known.contains(e)).toList();
  }

  /// «1 навык», «3 навыка», «5 навыков».
  static String _skills(int count) => switch (count % 10) {
        1 when count % 100 != 11 => '$count навык',
        2 || 3 || 4 when count % 100 < 12 || count % 100 > 14 => '$count навыка',
        _ => '$count навыков',
      };

  static List<String> _fixedTools(List<ToolProficiencyOption> tools) =>
      tools.where((e) => !e.isChoice).map((e) => e.title).toList();
}
