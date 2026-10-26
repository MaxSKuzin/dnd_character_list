import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/fighter.dart';
import 'package:dnd_character_list/domain/models/classes/monk.dart';
import 'package:dnd_character_list/domain/models/classes/ranger.dart';
import 'package:dnd_character_list/domain/models/classes/sorcerer.dart';
import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';

/// Приписки к умениям, в которых что-то выбирается: «ИЗБРАННЫЙ ВРАГ: НЕЖИТЬ», «ДОБЫЧА ОХОТНИКА: УБИЙЦА КОЛОССОВ».
/// Боевые стили отмечаются в самих классах (`withFightingStyles`).
extension PlayerFeatureChoices on Player {
  /// Особенности персонажа с выбором в названии и в начале описания.
  List<Peculiarity> get abilitiesWithChoices {
    final choices = <String, String>{};
    for (final spec in classes) {
      spec.featureChoices
          .forEach((name, choice) => choices[name] = [if (choices[name] != null) choices[name]!, choice].join('; '));
    }
    return [
      for (final ability in abilities)
        choices[ability.name] == null ? ability : ability.withChoice(choices[ability.name]!)
    ];
  }
}

extension SpecializationFeatureChoices on Specialization {
  /// Умения класса с выбором в названии и в начале описания.
  List<Peculiarity> get abilitiesWithChoices {
    final choices = featureChoices;
    return [
      for (final ability in abilities)
        choices[ability.name] == null ? ability : ability.withChoice(choices[ability.name]!)
    ];
  }

  /// Что выбрано в умениях класса: название умения → выбор.
  Map<String, String> get featureChoices => {
        ...switch (this) {
          Sorcerer sorcerer => {
              if (sorcerer.dragonAncestor case final ancestor?)
                'ДРАКОНИЙ ПРЕДОК': '${ancestor.localizedName} (${ancestor.damageType.localizedName.toLowerCase()})',
              if (sorcerer.divineAffinity case final affinity?)
                'БОЖЕСТВЕННАЯ МАГИЯ': '${affinity.localizedName}, «${affinity.spellName}»',
              if (sorcerer.metamagic.isNotEmpty) 'МЕТАМАГИЯ': sorcerer.metamagic.map((e) => e.name).join(', '),
            },
          Bard bard => {
              if (bard.expertise.isNotEmpty) 'КОМПЕТЕНТНОСТЬ': bard.expertise.map((e) => e.localizedName).join(', '),
              if (bard.collegeSkills.isNotEmpty)
                'ДОПОЛНИТЕЛЬНЫЕ НАВЫКИ': bard.collegeSkills.map((e) => e.localizedName).join(', '),
            },
          Fighter fighter => {
              if (fighter.maneuvers.isNotEmpty) 'БОЕВОЕ ПРЕВОСХОДСТВО': fighter.maneuvers.map((e) => e.name).join(', '),
              if (fighter.archetypeTools.isNotEmpty) 'УЧЕНИК ВОЙНЫ': fighter.archetypeTools.join(', '),
              if (Fighter.bonusProficiencyFeatures[fighter.archetypeId] case final feature?
                  when fighter.archetypeSkills.isNotEmpty || fighter.archetypeLanguages.isNotEmpty)
                feature: [
                  ...fighter.archetypeSkills.map((e) => e.localizedName),
                  ...fighter.archetypeLanguages.map((e) => e.localizedName.toLowerCase()),
                ].join(', '),
            },
          Ranger ranger => {
              if (ranger.favoredEnemies.isNotEmpty) 'ИЗБРАННЫЙ ВРАГ': ranger.favoredEnemies.join(', '),
              if (ranger.favoredTerrains.isNotEmpty) 'ИССЛЕДОВАТЕЛЬ ПРИРОДЫ': ranger.favoredTerrains.join(', '),
              if (ranger.expertise.isNotEmpty)
                'ХИТРЕЦ': [
                  ...ranger.expertise.map((e) => e.localizedName),
                  if (ranger.tceFeatures.contains(Ranger.deftExplorer))
                    ...ranger.languages.map((e) => e.localizedName.toLowerCase()),
                ].join(', '),
              ...ranger.optionChoices,
              if (ranger.ironMindSave case final save?) 'ЖЕЛЕЗНЫЙ РАЗУМ': 'спасброски ${save.localizedName}',
            },
          Monk monk => {
              if (monk.disciplines.isNotEmpty) 'АДЕПТ СТИХИЙ': monk.disciplines.map((e) => e.name).join(', '),
            },
          _ => const <String, String>{},
        },
        if (_improvements.isNotEmpty)
          'УВЕЛИЧЕНИЕ ХАРАКТЕРИСТИК': _improvements.map((e) => e.localizedChoice).join('; '),
      };

  List<AbilityScoreImprovement> get _improvements => switch (this) {
        Sorcerer e => e.improvements,
        Bard e => e.improvements,
        Fighter e => e.improvements,
        Ranger e => e.improvements,
        Monk e => e.improvements,
        _ => const [],
      };
}

extension on AbilityScoreImprovement {
  /// «4 ур.: Харизма +2» или «8 ур.: черта «Устойчивый»».
  String get localizedChoice => '$level ур.: ${switch (feat) {
        final feat? => 'черта «${feat.feat.name}»',
        null => stats.entries.map((e) => '${e.key.localizedName} +${e.value}').join(', '),
      }}';
}

extension on Peculiarity {
  /// Выбор в названии и в начале описания.
  Peculiarity withChoice(String choice) => Peculiarity(
        name: '$name: ${choice.toUpperCase()}',
        description:
            isHtml ? '<p><strong>Выбрано:</strong> $choice.</p><hr>$description' : 'Выбрано: $choice.\n\n$description',
        isHtml: isHtml,
        requiredSlot: requiredSlot,
      );
}
