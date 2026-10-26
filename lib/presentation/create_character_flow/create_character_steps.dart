import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/sorcerer.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_option_screen/select_option_screen.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat.dart';
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Шаги создания персонажа в порядке «Книги игрока»: раса, класс (с подклассом, если его выбирают
/// на 1 уровне), характеристики, предыстория, затем выборы, которые от них зависят.
enum CreateCharacterStep {
  race,
  classKind,
  subclass,
  subclassOptions,
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
      case CreateCharacterStep.subclass:
        if (classInfo == null || classInfo.subclassLevel != 1 || classInfo.subclasses.isEmpty) return null;
        return SelectSubclassRoute(
          title: classInfo.subclassTitle ?? 'Подкласс',
          description: 'Класс «${classInfo.name}» выбирает его на 1 уровне: умения появляются сразу '
              'и на следующих уровнях. Подробности — по кнопке «i».',
          subclasses: classInfo.subclasses,
          onSelected: (subclass) async {
            await cubit.setSubclass(subclass);
            next();
          },
        );
      case CreateCharacterStep.subclassOptions:
        return _subclassOptionsRoute(cubit, next);
      case CreateCharacterStep.stats:
        return FillStatsRoute(
          title: 'Характеристики',
          description: 'Распределите очки: значения от 8 до 15, повышение до 14 и 15 стоит 2 очка.',
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
          title: 'Бонус расы',
          description: [
            'Раса «${race.name}»: +1 к ${race.additionalStatsCount} разным характеристикам на ваш выбор.',
            if (race.statBonuses.isNotEmpty)
              '${race.statBonuses.entries.map((e) => '${e.key.localizedName} +${e.value}').join(', ')} '
                  'добавится автоматически.',
          ].join('\n'),
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
          knownLanguages: cubit.knownLanguages,
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
        final granted = cubit.subclassSpells;
        return SelectSpellsRoute(
          classKind: classKind,
          additionalClassKinds:
              classKind == ClassKind.sorcerer ? Sorcerer.spellListsFor(cubit.subclass?.id).skip(1).toList() : null,
          description: [
            'Класс «${classInfo?.name ?? classKind.localizedName}»: '
                '${[if (cantrips > 0) _count(cantrips, 'заговор', 'заговора', 'заговоров'), if (spells > 0) '${_count(spells, 'заклинание', 'заклинания', 'заклинаний')} 1 уровня'].join(' и ')}.',
            if (classKind == ClassKind.sorcerer && cubit.subclass?.id == Sorcerer.divineSoul)
              '«Божественная магия»: можно выбирать и из списка жреца.',
            if (granted.isNotEmpty)
              '${cubit.subclass!.name} уже даёт: ${granted.map((e) => e.name).join(', ')} — они не входят в лимит.',
          ].join('\n'),
          knownSpells: granted,
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

  /// Выбор внутри подкласса: драконий предок, склонность «Божественной души».
  static PageRouteInfo? _subclassOptionsRoute(CreateCharacterCubit cubit, VoidCallback next) {
    switch (cubit.subclass?.id) {
      case Sorcerer.draconicBloodline:
        const ancestors = DragonAncestor.values;
        return SelectOptionRoute(
          title: 'Драконий предок',
          description: 'Вид урона предка используется в умениях происхождения. '
              'Вы также говорите, читаете и пишете на Драконьем.',
          options: [
            for (final e in ancestors) SelectOption(title: e.localizedName, subtitle: e.damageType.localizedName),
          ],
          onSelected: (index) {
            cubit.setDragonAncestor(ancestors[index]);
            next();
          },
        );
      case Sorcerer.divineSoul:
        const affinities = DivineAffinity.values;
        return SelectOptionRoute(
          title: 'Склонность',
          description: '«Божественная магия»: склонность к источнику божественной силы даёт дополнительное '
              'заклинание, которое не учитывается в числе известных.',
          options: [for (final e in affinities) SelectOption(title: e.localizedName, subtitle: e.spellName)],
          onSelected: (index) async {
            await cubit.setDivineAffinity(affinities[index]);
            next();
          },
        );
      default:
        return null;
    }
  }

  /// «1 заговор», «2 заговора», «5 заговоров».
  static String _count(int count, String one, String few, String many) => switch (count % 10) {
        1 when count % 100 != 11 => '$count $one',
        2 || 3 || 4 when count % 100 < 12 || count % 100 > 14 => '$count $few',
        _ => '$count $many',
      };

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
  static String _skills(int count) => _count(count, 'навык', 'навыка', 'навыков');

  static List<String> _fixedTools(List<ToolProficiencyOption> tools) =>
      tools.where((e) => !e.isChoice).map((e) => e.title).toList();
}
