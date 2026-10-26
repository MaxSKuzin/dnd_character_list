import 'package:dnd_character_list/domain/models/class_info.dart';
import 'package:dnd_character_list/domain/models/classes/ranger.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_option_screen/select_option_screen.dart';
import 'package:dnd_character_list/presentation/level_up_flow/level_up_steps.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/widgets.dart';

/// Выборы умений следопыта 1 уровня: «Избранный враг» или «Предпочтительный противник», «Исследователь
/// природы» или «Искусный исследователь». Нужны и при создании персонажа, и при мультиклассе.
typedef RangerFirstLevel = ({
  Set<String> tceFeatures,
  List<String> favoredEnemies,
  List<String> favoredTerrains,
  List<Language> languages,
  List<Skill> expertise,
});

/// Шаги следопыта, общие для создания персонажа и повышения уровня.
extension RangerSteps on BuildContext {
  /// Вариант умения: «Книги игрока» или его замена из «Котла Таши». `null` — пользователь вернулся назад.
  Future<bool?> askTceVariant(ClassInfo info, String phbId) async {
    final phb = info.feature(phbId);
    final tce = info.feature(Ranger.replacements[phbId]!);
    if (phb == null || tce == null) return tce != null;
    final index = await ask<int>(
      (done) => SelectOptionRoute(
        title: phb.name,
        description: 'Умение «Книги игрока» или его замена из «Котла Таши». Подробности — по кнопке «i».',
        options: [
          SelectOption(title: phb.name, subtitle: 'Книга игрока', detailsHtml: phb.descriptionHtml),
          SelectOption(
              title: tce.name, subtitle: 'Котёл Таши: заменяет «${phb.name}»', detailsHtml: tce.descriptionHtml),
        ],
        onSelected: done,
      ),
    );
    return index == null ? null : index == 1;
  }

  /// Вид избранного врага или две гуманоидные расы. Назад с выбора расы — снова к выбору вида.
  Future<String?> askFavoredEnemy(List<String> known) async {
    final races = Ranger.humanoidRaces.where((e) => !Ranger.chosenHumanoids(known).contains(e)).toList();
    final options =
        Ranger.enemyTypes.where((e) => e == Ranger.twoHumanoidRaces ? races.length >= 2 : !known.contains(e)).toList();
    while (true) {
      final index = await ask<int>(
        (done) => SelectOptionRoute(
          title: 'Избранный враг',
          description: 'Преимущество на проверки Мудрости (Выживание) для выслеживания и Интеллекта для '
              'вспоминания информации о них. Вы также узнаёте один их язык.',
          options: [
            for (final e in options)
              SelectOption(title: e, subtitle: e == Ranger.twoHumanoidRaces ? 'Например, орки и гноллы' : null),
          ],
          onSelected: done,
        ),
      );
      if (index == null) return null;
      final enemy = options[index];
      if (enemy != Ranger.twoHumanoidRaces) return enemy;

      final first = await _askHumanoid(races, 'Первая раса');
      if (first == null) continue;
      final second = await _askHumanoid(races.where((e) => e != first).toList(), 'Вторая раса');
      if (second == null) continue;
      return Ranger.humanoidsEnemy(first, second);
    }
  }

  Future<String?> _askHumanoid(List<String> races, String title) async {
    final index = await ask<int>(
      (done) => SelectOptionRoute(
        title: title,
        description: 'Избранные враги — две гуманоидные расы.',
        options: [for (final race in races) SelectOption(title: race[0].toUpperCase() + race.substring(1))],
        onSelected: done,
      ),
    );
    return index == null ? null : races[index];
  }

  Future<String?> askTerrain(List<String> known) async {
    final options = Ranger.terrains.where((e) => !known.contains(e)).toList();
    final index = await ask<int>(
      (done) => SelectOptionRoute(
        title: 'Известная местность',
        description: 'В этой местности бонус мастерства удваивается для проверок Интеллекта и Мудрости '
            'навыками, которыми вы владеете, и группа путешествует быстрее и безопаснее.',
        options: [for (final e in options) SelectOption(title: e)],
        onSelected: done,
      ),
    );
    return index == null ? null : options[index];
  }

  /// Выборы 1 уровня. [skills] — навыки, которыми персонаж владеет (для «Хитреца»), [languages] — языки,
  /// которые он знает.
  Future<RangerFirstLevel?> askRangerFirstLevel(
    ClassInfo info, {
    required List<Skill> skills,
    required List<Language> languages,
  }) async {
    final tce = <String>{};
    final enemies = <String>[];
    final terrains = <String>[];
    final learned = <Language>[];
    final expertise = <Skill>[];

    final favoredFoe = await askTceVariant(info, Ranger.favoredEnemy);
    if (favoredFoe == null) return null;
    if (favoredFoe) {
      tce.add(Ranger.favoredFoe);
    } else {
      final enemy = await askFavoredEnemy(enemies);
      if (enemy == null) return null;
      enemies.add(enemy);
      final language =
          await askLanguages(1, languages, 'Избранный враг «$enemy»: один из языков, на которых он говорит.');
      if (language == null) return null;
      learned.addAll(language);
    }

    final deftExplorer = await askTceVariant(info, Ranger.naturalExplorer);
    if (deftExplorer == null) return null;
    if (deftExplorer) {
      tce.add(Ranger.deftExplorer);
      final skill = await ask<List<Skill>>(
        (done) => SelectSkillsRoute(
          title: 'Хитрец',
          description: 'Выберите навык, которым владеете: бонус мастерства для него удваивается.',
          maxSkills: 1,
          availableSkills: skills,
          onSkillsSelected: done,
        ),
      );
      if (skill == null) return null;
      expertise.addAll(skill);
      final extra = await askLanguages(2, [...languages, ...learned], 'Хитрец: два языка на ваш выбор.');
      if (extra == null) return null;
      learned.addAll(extra);
    } else {
      final terrain = await askTerrain(terrains);
      if (terrain == null) return null;
      terrains.add(terrain);
    }
    return (
      tceFeatures: tce,
      favoredEnemies: enemies,
      favoredTerrains: terrains,
      languages: learned,
      expertise: expertise,
    );
  }
}
