import 'dart:math';

import 'package:dnd_character_list/data/spells_repository.dart';
import 'package:dnd_character_list/domain/bloc/level_up_cubit.dart';
import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/classes/sorcerer.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/metamagic.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_option_screen/select_option_screen.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/level_up_flow/level_up_steps.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Повышение уровня чародея по таблице класса с ttg.club: какие выборы нужны, определяется
/// умениями из строки таблицы для нового уровня.
class SorcererLevelUp {
  final BuildContext context;
  final Player player;
  final ClassInfo info;

  /// Текущий чародей персонажа или `null`, если чародей берётся мультиклассом.
  final Sorcerer? sorcerer;

  SorcererLevelUp({
    required this.context,
    required this.player,
    required this.info,
    required this.sorcerer,
  });

  /// Проводит пользователя по выборам и передаёт результат в [LevelUpCubit].
  /// Возвращает `false`, если пользователь вернулся назад.
  Future<bool> run() async {
    final level = (sorcerer?.level ?? 0) + 1;
    final row = info.level(level);
    final previous = level > 1 ? info.level(level - 1) : null;

    // Мультиклассирование в чародея не даёт владений, а происхождение выбирается на 1 уровне.
    var originId = sorcerer?.originId;
    var originName = sorcerer?.originName;
    var dragonAncestor = sorcerer?.dragonAncestor;
    var divineAffinity = sorcerer?.divineAffinity;
    if (level == info.subclassLevel && originId == null) {
      final origin = await context.ask<Subclass>(
        (done) => SelectSubclassRoute(
          title: info.subclassTitle ?? 'Происхождение чародея',
          subclasses: info.subclasses,
          onSelected: done,
        ),
      );
      if (origin == null) return false;
      originId = origin.id;
      originName = origin.name;

      if (originId == Sorcerer.draconicBloodline) {
        const ancestors = DragonAncestor.values;
        final index = await context.ask<int>(
          (done) => SelectOptionRoute(
            title: 'Драконий предок',
            description: 'Вид урона предка используется в умениях происхождения. '
                'Вы также говорите, читаете и пишете на Драконьем.',
            options: [
              for (final e in ancestors) SelectOption(title: e.localizedName, subtitle: e.damageType.localizedName),
            ],
            onSelected: done,
          ),
        );
        if (index == null) return false;
        dragonAncestor = ancestors[index];
      }
      if (originId == Sorcerer.divineSoul) {
        const affinities = DivineAffinity.values;
        final index = await context.ask<int>(
          (done) => SelectOptionRoute(
            title: 'Склонность',
            description: '«Божественная магия»: склонность к источнику божественной силы даёт дополнительное '
                'заклинание, которое не учитывается в числе известных.',
            options: [for (final e in affinities) SelectOption(title: e.localizedName, subtitle: e.spellName)],
            onSelected: done,
          ),
        );
        if (index == null) return false;
        divineAffinity = affinities[index];
      }
    }

    // Заклинания происхождения, полученные на этом уровне (аберрантный разум, заводная душа, лунная
    // и теневая магия), известны всегда и не входят в лимит.
    final originSpells = [...?sorcerer?.originSpells];
    final newOriginLinks = Sorcerer.originSpellLinks(info, level, originId: originId, divineAffinity: divineAffinity)
        .where((link) => !originSpells.any((e) => e.link == link))
        .toList();
    if (newOriginLinks.isNotEmpty) {
      try {
        originSpells.addAll(await getIt<SpellsRepository>().resolveLinks(newOriginLinks));
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось загрузить заклинания происхождения с ttg.club: $e')),
          );
        }
        return false;
      }
    }

    final improvements = [...?sorcerer?.improvements];
    if (row.hasFeature(Sorcerer.abilityScoreImprovement)) {
      final improvement = await context.ask<AbilityScoreImprovement>(
        (done) => AbilityScoreImprovementRoute(player: player, level: level, onSelected: done),
      );
      if (improvement == null) return false;
      improvements.add(improvement);
    }

    // Число вариантов метамагии — из названия умения в таблице: «Метамагия(3)».
    var metamagic = [...?sorcerer?.metamagic];
    final newMetamagic = Sorcerer.metamagicCountAt(info, level) - metamagic.length;
    if (newMetamagic > 0) {
      final options = await context.ask<List<Metamagic>>(
        (done) => SelectMetamagicRoute(
          description: 'Чародей $level уровня выбирает новые варианты метамагии. '
              'При сотворении заклинания можно использовать только один вариант, если не указано обратное.',
          count: newMetamagic,
          known: metamagic,
          onSelected: done,
        ),
      );
      if (options == null) return false;
      metamagic.addAll(options);
    }

    // Новые заклинания — по приросту столбцов таблицы. «Божественная магия» добавляет список жреца.
    final spellLists = Sorcerer.spellListsFor(originId);
    final knownSpells = [
      ...player.spells.values.expand((e) => e),
      ...player.raceSpells.values,
      ...originSpells,
    ];
    final spellLevels = SpellSlot.values.sublist(1, row.maxSpellLevel + 1);
    final newCantrips = max(0, (row.cantripsKnown ?? 0) - (previous?.cantripsKnown ?? 0));
    final newSpells = max(0, (row.spellsKnown ?? 0) - (previous?.spellsKnown ?? 0));
    final learned = <Spell>[];
    if (newCantrips > 0 || newSpells > 0) {
      final spells = await context.ask<List<Spell>>(
        (done) => SelectSpellsRoute(
          classKind: ClassKind.sorcerer,
          additionalClassKinds: spellLists.skip(1).toList(),
          description: [
            'Чародей $level уровня узнаёт новые заклинания из списка чародея'
                '${newSpells > 0 ? ' — не выше ${spellLevels.last.index} уровня' : ''}.',
            if (originId == Sorcerer.divineSoul) '«Божественная магия»: можно выбирать и из списка жреца.',
          ].join('\n'),
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

    // Замена известных заклинаний: одного заклинания 1 уровня и выше — на каждом уровне. Заменить можно
    // только то, что чародей знал до этого уровня; заклинания происхождения не заменяются.
    var chosenSpells = [...?sorcerer?.chosenSpells];
    final known = [...knownSpells, ...learned];
    Future<bool> replaceSpell({
      required String title,
      required String description,
      required List<Spell> replaceable,
      required List<SpellSlot> slots,
    }) async {
      if (replaceable.isEmpty) return true;
      final result = await context.ask<OptionalReplacement>(
        (done) => ReplaceSpellRoute(
          title: title,
          description: description,
          replaceableSpells: replaceable,
          classKind: ClassKind.sorcerer,
          additionalClassKinds: spellLists.skip(1).toList(),
          newSpellSlots: slots,
          knownSpells: known,
          onSelected: (replacement) => done(OptionalReplacement(replacement)),
        ),
      );
      if (result == null) return false;
      final replacement = result.value;
      if (replacement != null) {
        chosenSpells = replacement.applyTo(chosenSpells);
        known.add(replacement.learned);
      }
      return true;
    }

    final replaced = await replaceSpell(
      title: 'Замена заклинания',
      description: 'Получая уровень чародея, можно заменить одно известное заклинание другим из списка чародея. '
          'Уровень нового — не выше ${spellLevels.last.index}.',
      replaceable: chosenSpells.where((e) => e.slot != SpellSlot.conspiracy).toList(),
      slots: spellLevels,
    );
    if (!replaced) return false;

    // «Чародейская разносторонность»: на уровнях «Увеличения характеристик» — замена варианта метамагии
    // или заговора.
    if (row.hasFeature(Sorcerer.abilityScoreImprovement) && info.feature(Sorcerer.sorcerousVersatility) != null) {
      final cantrips = chosenSpells.where((e) => e.slot == SpellSlot.conspiracy).toList();
      final choices = [
        if (metamagic.isNotEmpty) _Versatility.metamagic,
        if (cantrips.isNotEmpty) _Versatility.cantrip,
        _Versatility.none,
      ];
      final index = await context.ask<int>(
        (done) => SelectOptionRoute(
          title: 'Чародейская разносторонность',
          description: 'Можно заменить один вариант метамагии или один заговор чародея.',
          options: [for (final e in choices) SelectOption(title: e.title)],
          onSelected: done,
        ),
      );
      if (index == null) return false;
      switch (choices[index]) {
        case _Versatility.metamagic:
          final replacedIndex = await context.ask<int>(
            (done) => SelectOptionRoute(
              title: 'Вариант на замену',
              options: [for (final e in metamagic) SelectOption(title: e.name)],
              onSelected: done,
            ),
          );
          if (replacedIndex == null) return false;
          final options = await context.ask<List<Metamagic>>(
            (done) => SelectMetamagicRoute(
              title: 'Новый вариант метамагии',
              description: 'Вместо варианта «${metamagic[replacedIndex].name}».',
              count: 1,
              known: metamagic,
              onSelected: done,
            ),
          );
          if (options == null) return false;
          metamagic = [...metamagic]..[replacedIndex] = options.single;
        case _Versatility.cantrip:
          final replaced = await replaceSpell(
            title: 'Замена заговора',
            description: 'Можно заменить один известный заговор другим заговором из списка чародея.',
            replaceable: cantrips,
            slots: const [SpellSlot.conspiracy],
          );
          if (!replaced) return false;
        case _Versatility.none:
          break;
      }
    }

    if (!context.mounted) return false;
    context.read<LevelUpCubit>().setSpecialization(
          Sorcerer(
            level: level,
            isMain: sorcerer?.isMain ?? false,
            chosenSpells: [...chosenSpells, ...learned],
            originSpells: originSpells,
            features: [...?sorcerer?.features, ...Sorcerer.featuresAt(info, level, originId: originId)],
            originId: originId,
            originName: originName,
            dragonAncestor: dragonAncestor,
            divineAffinity: divineAffinity,
            metamagic: metamagic,
            improvements: improvements,
            sorceryPoints: Sorcerer.sorceryPointsAt(info, level),
          ),
        );
    return true;
  }
}

/// Варианты «Чародейской разносторонности».
enum _Versatility {
  metamagic('Заменить вариант метамагии'),
  cantrip('Заменить заговор'),
  none('Ничего не менять');

  const _Versatility(this.title);

  final String title;
}
