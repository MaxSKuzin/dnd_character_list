import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_replacement.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Повышение уровня барда по таблице класса с ttg.club: какие выборы нужны, определяется
/// умениями из строки таблицы для нового уровня.
class BardLevelUp {
  final BuildContext context;
  final Player player;
  final ClassInfo info;

  /// Текущий бард персонажа или `null`, если бард берётся мультиклассом.
  final Bard? bard;

  BardLevelUp({
    required this.context,
    required this.player,
    required this.info,
    required this.bard,
  });

  /// Проводит пользователя по выборам и передаёт результат в [LevelUpCubit].
  /// Возвращает `false`, если пользователь вернулся назад.
  Future<bool> run() async {
    final level = (bard?.level ?? 0) + 1;
    final row = info.level(level);
    final previous = level > 1 ? info.level(level - 1) : null;
    final knownSpells = [
      ...player.spells.values.expand((e) => e),
      ...player.raceSpells.values,
    ];

    // Мультиклассирование: один навык, один музыкальный инструмент.
    final multiclassSkills = <Skill>[];
    final multiclassTools = <String>[];
    if (bard == null) {
      final skills = await _ask<List<Skill>>(
        (done) => SelectSkillsRoute(
          title: 'Владение навыками',
          description: 'Мультиклассирование в барда: выберите 1 навык на ваш выбор.',
          maxSkills: 1,
          availableSkills: Skill.values.where((e) => !player.chosenSkills.contains(e)).toList(),
          onSkillsSelected: done,
        ),
      );
      if (skills == null) return false;
      multiclassSkills.addAll(skills);
      final tools = await _ask<List<String>>(
        (done) => ProficienciesRoute(
          title: 'Владение инструментами',
          description: 'Мультиклассирование в барда: один музыкальный инструмент на ваш выбор.',
          knownTools: player.toolProficiencies,
          tools: const [
            ToolProficiencyOption(
              title: 'Один музыкальный инструмент',
              category: ToolCategory.musicalInstrument,
              choose: 1,
            ),
          ],
          onSelected: (tools, _) => done(tools),
        ),
      );
      if (tools == null) return false;
      multiclassTools.addAll(tools);
    }
    final proficientSkills = {...player.chosenSkills, ...multiclassSkills};

    var collegeId = bard?.collegeId;
    var collegeName = bard?.collegeName;
    var fightingStyle = bard?.fightingStyle;
    var collegeSkills = bard?.collegeSkills ?? const <Skill>[];
    if (level == info.subclassLevel && collegeId == null) {
      final college = await _ask<Subclass>(
        (done) => SelectSubclassRoute(title: 'Коллегия бардов', subclasses: info.subclasses, onSelected: done),
      );
      if (college == null) return false;
      collegeId = college.id;
      collegeName = college.name;

      if (collegeId == Bard.swordsCollege) {
        fightingStyle = await _ask<FightingStyle>(
          (done) => SelectFightingStyleRoute(
            styles: const [FightingStyle.dueling, FightingStyle.twoWeaponFighting],
            onStyleSelected: done,
          ),
        );
        if (fightingStyle == null) return false;
      }
      if (collegeId == Bard.loreCollege) {
        final skills = await _ask<List<Skill>>(
          (done) => SelectSkillsRoute(
            title: 'Владение навыками',
            description: 'Коллегия знаний, «Дополнительные навыки»: выберите ${Bard.loreSkillsCount} навыка на ваш выбор.',
            maxSkills: Bard.loreSkillsCount,
            availableSkills: Skill.values.where((e) => !proficientSkills.contains(e)).toList(),
            onSkillsSelected: done,
          ),
        );
        if (skills == null) return false;
        collegeSkills = skills;
        proficientSkills.addAll(skills);
      }
    }

    final expertise = [...?bard?.expertise];
    if (row.hasFeature(Bard.expertiseFeature)) {
      final skills = await _ask<List<Skill>>(
        (done) => SelectSkillsRoute(
          title: 'Компетентность',
          description: 'Выберите ${Bard.expertiseCount} навыка из тех, которыми владеете: '
              'бонус мастерства для них удваивается.',
          maxSkills: Bard.expertiseCount,
          availableSkills: proficientSkills.where((e) => !expertise.contains(e)).toList(),
          onSkillsSelected: done,
        ),
      );
      if (skills == null) return false;
      expertise.addAll(skills);
    }

    final improvements = [...?bard?.improvements];
    if (row.hasFeature(Bard.abilityScoreImprovement)) {
      final improvement = await _ask<AbilityScoreImprovement>(
        (done) => AbilityScoreImprovementRoute(player: player, level: level, onSelected: done),
      );
      if (improvement == null) return false;
      improvements.add(improvement);
    }

    // Новые заклинания — по приросту столбцов таблицы. «Тайны магии» входят в число известных
    // заклинаний, а дополнительные тайны коллегии знаний — нет.
    final spellLevels = SpellSlot.values.sublist(1, row.maxSpellLevel + 1);
    final secrets = row.hasFeature(Bard.magicalSecrets) ? Bard.magicalSecretsCount : 0;
    final loreSecrets =
        collegeId == Bard.loreCollege && level == Bard.loreAdditionalSecretsLevel ? Bard.magicalSecretsCount : 0;
    final newCantrips = (row.cantripsKnown ?? 0) - (previous?.cantripsKnown ?? 0);
    final newSpells = max(0, (row.spellsKnown ?? 0) - (previous?.spellsKnown ?? 0) - secrets);

    final learned = <Spell>[];
    if (newCantrips > 0 || newSpells > 0) {
      final spells = await _ask<List<Spell>>(
        (done) => SelectSpellsRoute(
          classKind: ClassKind.bard,
          description: 'Бард $level уровня узнаёт новые заклинания из списка барда'
              '${newSpells > 0 ? ' — не выше ${spellLevels.last.index} уровня' : ''}.',
          maxConspiracies: newCantrips,
          maxSpells: newSpells,
          availableSlots: [if (newCantrips > 0) SpellSlot.conspiracy, if (newSpells > 0) ...spellLevels],
          knownSpells: knownSpells,
          onSpellsSelected: done,
        ),
      );
      if (spells == null) return false;
      learned.addAll(spells);
    }
    if (secrets + loreSecrets > 0) {
      final spells = await _ask<List<Spell>>(
        (done) => SelectSpellsRoute(
          title: 'Тайны магии',
          classKind: null,
          maxConspiracies: 0,
          maxSpells: secrets + loreSecrets,
          cantripsCountAsSpells: true,
          availableSlots: [SpellSlot.conspiracy, ...spellLevels],
          knownSpells: [...knownSpells, ...learned],
          onSpellsSelected: done,
        ),
      );
      if (spells == null) return false;
      learned.addAll(spells);
    }

    // Замена известных заклинаний: одного заклинания 1 уровня и выше — на каждом уровне, а заговора —
    // по «Бардовской разносторонности» на уровнях «Увеличения характеристик». Заменить можно только то,
    // что бард знал до этого уровня; новыми не могут быть уже известные заклинания.
    var bardSpells = [...?bard?.knownSpells];
    final known = [...knownSpells, ...learned];
    final replacements = [
      (
        title: 'Замена заклинания',
        description: 'Получая уровень барда, можно заменить одно известное заклинание другим из списка барда. '
            'Уровень нового — не выше ${spellLevels.last.index}.',
        replaceable: bardSpells.where((e) => e.slot != SpellSlot.conspiracy).toList(),
        slots: spellLevels,
      ),
      if (row.hasFeature(Bard.abilityScoreImprovement) && info.feature(Bard.bardicVersatility) != null)
        (
          title: 'Бардовская разносторонность',
          description: 'Можно заменить один известный заговор другим заговором из списка барда.',
          replaceable: bardSpells.where((e) => e.slot == SpellSlot.conspiracy).toList(),
          slots: const [SpellSlot.conspiracy],
        ),
    ];
    for (final step in replacements.where((e) => e.replaceable.isNotEmpty)) {
      final result = await _ask<_Replacement>(
        (done) => ReplaceSpellRoute(
          title: step.title,
          description: step.description,
          replaceableSpells: step.replaceable,
          classKind: ClassKind.bard,
          newSpellSlots: step.slots,
          knownSpells: known,
          onSelected: (replacement) => done(_Replacement(replacement)),
        ),
      );
      if (result == null) return false;
      final replacement = result.value;
      if (replacement != null) {
        bardSpells = replacement.applyTo(bardSpells);
        known.add(replacement.learned);
      }
    }

    if (!context.mounted) return false;
    final cubit = context.read<LevelUpCubit>();
    cubit.setSpecialization(
      Bard(
        level: level,
        isMain: bard?.isMain ?? false,
        knownSpells: [...bardSpells, ...learned],
        features: [...?bard?.features, ...Bard.featuresAt(info, level, collegeId: collegeId)],
        inspirationDice: Bard.inspirationDiceAt(info, level),
        collegeId: collegeId,
        collegeName: collegeName,
        fightingStyle: fightingStyle,
        expertise: expertise,
        collegeSkills: collegeSkills,
        improvements: improvements,
      ),
    );
    if (multiclassSkills.isNotEmpty) cubit.setSkills([...player.rawChosenSkills, ...multiclassSkills]);
    if (multiclassTools.isNotEmpty) cubit.setTools(multiclassTools);
    return true;
  }

  /// Открывает экран выбора и ждёт результат; `null` — пользователь вернулся назад.
  /// Чтобы отличить возврат назад от пропуска шага, необязательный выбор оборачивается в [_Replacement].
  Future<T?> _ask<T>(PageRouteInfo Function(void Function(T value) done) route) {
    if (!context.mounted) return Future.value();
    return context.pushRoute<T>(route((value) => context.maybePop(value)));
  }
}

/// Результат необязательного шага замены: `value == null` — шаг пропущен.
class _Replacement {
  final SpellReplacement? value;

  const _Replacement(this.value);
}
