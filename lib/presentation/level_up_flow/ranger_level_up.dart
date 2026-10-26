import 'dart:math';

import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/ranger.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_option_screen/select_option_screen.dart';
import 'package:dnd_character_list/presentation/level_up_flow/level_up_steps.dart';
import 'package:dnd_character_list/presentation/level_up_flow/ranger_steps.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Повышение уровня следопыта по таблице класса с ttg.club: выборы умений (варианты «Котла Таши», избранные
/// враги и местности), боевой стиль, архетип, «Увеличение характеристик» и «Универсальность воина», заклинания
/// по приросту столбца «Известные заклинания» и замена одного заклинания на каждом уровне.
class RangerLevelUp {
  final BuildContext context;
  final Player player;
  final ClassInfo info;

  /// Текущий следопыт персонажа или `null`, если следопыт берётся мультиклассом.
  final Ranger? ranger;

  RangerLevelUp({
    required this.context,
    required this.player,
    required this.info,
    required this.ranger,
  });

  Future<FightingStyle?> _askStyle({FightingStyle? except}) => context.ask<FightingStyle>(
        (done) => SelectFightingStyleRoute(
          styles: FightingStyle.rangerStyles.where((e) => e != except).toList(),
          onStyleSelected: done,
        ),
      );

  Future<List<Spell>?> _askDruidCantrips(List<Spell> known) => context.ask<List<Spell>>(
        (done) => SelectSpellsRoute(
          classKind: ClassKind.driud,
          title: 'Воин-друид',
          description: 'Два заговора из списка друида. Они считаются заклинаниями следопыта.',
          maxConspiracies: 2,
          maxSpells: 0,
          availableSlots: const [SpellSlot.conspiracy],
          knownSpells: known,
          onSpellsSelected: done,
        ),
      );

  /// Проводит пользователя по выборам и передаёт результат в [LevelUpCubit].
  /// Возвращает `false`, если пользователь вернулся назад.
  Future<bool> run() async {
    final level = (ranger?.level ?? 0) + 1;
    final row = info.level(level);
    final previous = level > 1 ? info.level(level - 1) : null;

    var tce = {...?ranger?.tceFeatures};
    final enemies = [...?ranger?.favoredEnemies];
    final terrains = [...?ranger?.favoredTerrains];
    final languages = [...?ranger?.languages];
    final expertise = [...?ranger?.expertise];
    final skills = <Skill>[];

    // Мультиклассирование в следопыта: один навык из списка класса.
    if (ranger == null) {
      final options = info.skillOptions.where((e) => !player.chosenSkills.contains(e)).toList();
      final skill = await context.ask<List<Skill>>(
        (done) => SelectSkillsRoute(
          title: 'Владение навыками',
          description: 'Мультиклассирование в следопыта: один навык из списка класса.',
          maxSkills: 1,
          availableSkills: options.isEmpty ? Skill.values : options,
          onSkillsSelected: done,
        ),
      );
      if (skill == null) return false;
      skills.addAll(skill);
    }

    if (level == 1) {
      if (!context.mounted) return false;
      final choices = await context.askRangerFirstLevel(
        info,
        skills: {...player.chosenSkills, ...skills}.toList(),
        languages: player.knownLanguages,
      );
      if (choices == null) return false;
      tce = {...tce, ...choices.tceFeatures};
      enemies.addAll(choices.favoredEnemies);
      terrains.addAll(choices.favoredTerrains);
      languages.addAll(choices.languages);
      expertise.addAll(choices.expertise);
    } else {
      // «Улучшение избранного врага» (6, 14) и «Улучшение исследователя природы» (6, 10) вариантов «Книги игрока».
      if (row.hasFeature(Ranger.favoredEnemy) && !tce.contains(Ranger.favoredFoe)) {
        final enemy = await context.askFavoredEnemy(enemies);
        if (enemy == null) return false;
        enemies.add(enemy);
        if (!context.mounted) return false;
        final language = await context.askLanguages(
          1,
          [...player.knownLanguages, ...languages],
          'Избранный враг «$enemy»: один из языков, на которых он говорит.',
        );
        if (language == null) return false;
        languages.addAll(language);
      }
      if (row.hasFeature(Ranger.naturalExplorer) && !tce.contains(Ranger.deftExplorer)) {
        if (!context.mounted) return false;
        final terrain = await context.askTerrain(terrains);
        if (terrain == null) return false;
        terrains.add(terrain);
      }
    }

    // Варианты умений 3 и 10 уровней.
    for (final phbId in [Ranger.primevalAwareness, Ranger.hideInPlainSight]) {
      if (!row.hasFeature(phbId)) continue;
      if (!context.mounted) return false;
      final useTce = await context.askTceVariant(info, phbId);
      if (useTce == null) return false;
      if (useTce) tce = {...tce, Ranger.replacements[phbId]!};
    }

    var style = ranger?.fightingStyle;
    var druidicCantrips = [...?ranger?.druidicCantrips];
    final knownSpells = [...player.spells.values.expand((e) => e), ...player.raceSpells.values];
    Future<bool> changeStyle(FightingStyle? except) async {
      final newStyle = await _askStyle(except: except);
      if (newStyle == null) return false;
      style = newStyle;
      druidicCantrips = [];
      if (newStyle == FightingStyle.druidicWarrior) {
        final cantrips = await _askDruidCantrips(knownSpells);
        if (cantrips == null) return false;
        druidicCantrips = cantrips;
      }
      return true;
    }

    if (row.hasFeature(Ranger.fightingStyleFeature) && style == null && !await changeStyle(null)) return false;

    var archetypeId = ranger?.archetypeId;
    var archetypeName = ranger?.archetypeName;
    if (level == info.subclassLevel && archetypeId == null) {
      final archetype = await context.ask<Subclass>(
        (done) => SelectSubclassRoute(
          title: info.subclassTitle ?? 'Архетип следопыта',
          subclasses: info.subclasses,
          onSelected: done,
        ),
      );
      if (archetype == null) return false;
      archetypeId = archetype.id;
      archetypeName = archetype.name;
    }

    // Варианты умений архетипа («Добыча охотника» и другие умения охотника).
    final optionChoices = {...?ranger?.optionChoices};
    final picked = await context.askFeatureOptions(info.subclass(archetypeId ?? ''), level);
    if (picked == null) return false;
    optionChoices.addAll(picked);

    // «Железный разум»: спасбросок Мудрости, а если он уже есть — Интеллекта или Харизмы.
    var ironMindSave = ranger?.ironMindSave;
    if (archetypeId == Ranger.gloomStalker && level == Ranger.ironMindLevel) {
      ironMindSave = StatKind.wisdom;
      if (player.savingThrowProficiencies.contains(StatKind.wisdom)) {
        const options = [StatKind.intelligence, StatKind.charisma];
        final index = await context.ask<int>(
          (done) => SelectOptionRoute(
            title: 'Железный разум',
            description: 'Спасброском Мудрости вы уже владеете: выберите другой спасбросок.',
            options: const [SelectOption(title: 'Интеллект'), SelectOption(title: 'Харизма')],
            onSelected: done,
          ),
        );
        if (index == null) return false;
        ironMindSave = options[index];
      }
    }

    final improvements = [...?ranger?.improvements];
    if (row.hasFeature(Ranger.abilityScoreImprovement)) {
      final improvement = await context.ask<AbilityScoreImprovement>(
        (done) => AbilityScoreImprovementRoute(player: player, level: level, onSelected: done),
      );
      if (improvement == null) return false;
      improvements.add(improvement);

      // «Универсальность воина» (TCE): замена боевого стиля.
      if (info.feature(Ranger.martialVersatility) != null && style != null) {
        final index = await context.ask<int>(
          (done) => SelectOptionRoute(
            title: 'Универсальность воина',
            description: 'Можно заменить боевой стиль другим стилем следопыта.',
            options: [
              SelectOption(title: 'Заменить стиль «${style!.title}»'),
              const SelectOption(title: 'Ничего не менять')
            ],
            onSelected: done,
          ),
        );
        if (index == null) return false;
        if (index == 0 && !await changeStyle(style)) return false;
      }
    }

    // Заклинания архетипа и «Изначального чутья», полученные на этом уровне.
    final grantedSpells = [...?ranger?.grantedSpells];
    final newLinks = Ranger.grantedSpellLinks(
      info,
      level,
      archetypeId: archetypeId,
      primal: tce.contains(Ranger.primalAwareness),
    ).where((link) => !grantedSpells.any((e) => e.link == link)).toList();
    if (newLinks.isNotEmpty) {
      try {
        grantedSpells.addAll(await getIt<SpellsRepository>().resolveLinks(newLinks));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось загрузить заклинания с ttg.club: $e')),
          );
        }
        return false;
      }
    }

    // Новые заклинания — по приросту столбца «Известные заклинания».
    final spellLevels = SpellSlot.values.sublist(1, row.maxSpellLevel + 1);
    final newSpells = max(0, (row.spellsKnown ?? 0) - (previous?.spellsKnown ?? 0));
    final known = [...knownSpells, ...grantedSpells, ...druidicCantrips];
    final learned = <Spell>[];
    if (newSpells > 0 && spellLevels.isNotEmpty) {
      final spells = await context.ask<List<Spell>>(
        (done) => SelectSpellsRoute(
          classKind: ClassKind.ranger,
          description: 'Следопыт $level уровня узнаёт новые заклинания из списка следопыта — '
              'не выше ${spellLevels.last.index} уровня.',
          maxConspiracies: 0,
          maxSpells: newSpells,
          availableSlots: spellLevels,
          knownSpells: known,
          onSpellsSelected: done,
        ),
      );
      if (spells == null) return false;
      learned.addAll(spells);
      known.addAll(spells);
    }

    // Замена одного известного заклинания на каждом уровне; заклинания архетипа и чутья не заменяются.
    var chosenSpells = [...?ranger?.chosenSpells];
    if (chosenSpells.isNotEmpty && spellLevels.isNotEmpty) {
      final result = await context.ask<OptionalReplacement>(
        (done) => ReplaceSpellRoute(
          title: 'Замена заклинания',
          description: 'Получая уровень следопыта, можно заменить одно известное заклинание другим из списка '
              'следопыта. Уровень нового — не выше ${spellLevels.last.index}.',
          replaceableSpells: chosenSpells,
          classKind: ClassKind.ranger,
          newSpellSlots: spellLevels,
          knownSpells: known,
          onSelected: (replacement) => done(OptionalReplacement(replacement)),
        ),
      );
      if (result == null) return false;
      if (result.value case final replacement?) {
        chosenSpells = replacement.applyTo(chosenSpells);
        known.add(replacement.learned);
      }
    }

    // «Воин-друид»: получая уровень, можно заменить один заговор друида.
    if (druidicCantrips.isNotEmpty && ranger?.druidicCantrips.isNotEmpty == true && style == ranger?.fightingStyle) {
      final result = await context.ask<OptionalReplacement>(
        (done) => ReplaceSpellRoute(
          title: 'Замена заговора',
          description: '«Воин-друид»: можно заменить один заговор другим заговором друида.',
          replaceableSpells: druidicCantrips,
          classKind: ClassKind.driud,
          newSpellSlots: const [SpellSlot.conspiracy],
          knownSpells: known,
          onSelected: (replacement) => done(OptionalReplacement(replacement)),
        ),
      );
      if (result == null) return false;
      if (result.value case final replacement?) druidicCantrips = replacement.applyTo(druidicCantrips);
    }

    if (!context.mounted) return false;
    final cubit = context.read<LevelUpCubit>();
    if (skills.isNotEmpty) cubit.setSkills([...skills, ...player.rawChosenSkills]);
    cubit.setSpecialization(
      Ranger(
        level: level,
        isMain: ranger?.isMain ?? false,
        features: [
          ...?ranger?.features,
          ...Ranger.featuresAt(info, level, archetypeId: archetypeId, tceFeatures: tce),
        ],
        archetypeId: archetypeId,
        archetypeName: archetypeName,
        tceFeatures: tce,
        favoredEnemies: enemies,
        favoredTerrains: terrains,
        languages: languages,
        expertise: expertise,
        fightingStyle: style,
        chosenSpells: [...chosenSpells, ...learned],
        druidicCantrips: druidicCantrips,
        grantedSpells: grantedSpells,
        improvements: improvements,
        optionChoices: optionChoices,
        ironMindSave: ironMindSave,
      ),
    );
    return true;
  }
}
