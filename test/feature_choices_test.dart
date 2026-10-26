import 'package:dnd_character_list/data/ttg/ttg_class_mapper.dart';
import 'package:dnd_character_list/domain/models/class_option.dart';
import 'package:dnd_character_list/domain/models/classes/fighter.dart';
import 'package:dnd_character_list/domain/models/classes/monk.dart';
import 'package:dnd_character_list/domain/models/classes/ranger.dart';
import 'package:dnd_character_list/domain/models/classes/sorcerer.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/feat.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/domain/models/peculiarity.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/presentation/extensions/feature_choices.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';
import 'support/ttg_fixtures.dart';

Peculiarity _feature(String name) => Peculiarity(name: name, description: '<p>Текст умения.</p>', isHtml: true);

List<String> _names(Player player) => player.abilitiesWithChoices.map((e) => e.name).toList();

void main() {
  test('hunter feature options are parsed from the site', () {
    final hunter = TtgClassMapper().mapSubclass(ttgFixture('class_ranger_hunter'));

    expect(hunter.featuresAt(3).single.options.map((e) => e.name),
        ['Сокрушитель орд', 'Убийца великанов', 'Убийца колоссов']);
    expect(hunter.featuresAt(7).single.options.map((e) => e.name),
        ['Защита от мультиатаки', 'Побег от орды', 'Стальная воля']);
    expect(hunter.featuresAt(11).single.options, hasLength(2));
    expect(
        hunter.featuresAt(3).single.options.last.descriptionHtml, startsWith('<p><strong>Убийца колоссов.</strong>'));
  });

  test('ranger: favored enemy, terrain, hunter option and iron mind', () {
    final ranger = Ranger(
      level: 7,
      isMain: true,
      features: [
        _feature('ИЗБРАННЫЙ ВРАГ'),
        _feature('ИССЛЕДОВАТЕЛЬ ПРИРОДЫ'),
        _feature('ДОБЫЧА ОХОТНИКА'),
        _feature('ЖЕЛЕЗНЫЙ РАЗУМ'),
      ],
      favoredEnemies: ['Нежить', Ranger.humanoidsEnemy('орки', 'гноллы')],
      favoredTerrains: const ['Леса'],
      optionChoices: const {'ДОБЫЧА ОХОТНИКА': 'Убийца колоссов'},
      ironMindSave: StatKind.wisdom,
    );
    final player = playerFixture(spec: ranger);

    expect(
        _names(player),
        containsAll([
          'ИЗБРАННЫЙ ВРАГ: НЕЖИТЬ, ГУМАНОИДЫ: ОРКИ И ГНОЛЛЫ',
          'ИССЛЕДОВАТЕЛЬ ПРИРОДЫ: ЛЕСА',
          'ДОБЫЧА ОХОТНИКА: УБИЙЦА КОЛОССОВ',
          'ЖЕЛЕЗНЫЙ РАЗУМ: СПАСБРОСКИ МУДРОСТЬ',
        ]));
    final prey = player.abilitiesWithChoices.firstWhere((e) => e.name.startsWith('ДОБЫЧА'));
    expect(prey.description, '<p><strong>Выбрано:</strong> Убийца колоссов.</p><hr><p>Текст умения.</p>');
    expect(player.saveThrows.firstWhere((e) => e.origin == StatKind.wisdom).isChosen, isTrue);
  });

  test('sorcerer, fighter and monk choices, ability score improvements', () {
    final sorcerer = Sorcerer(
      level: 4,
      isMain: true,
      chosenSpells: const [],
      features: [_feature('ДРАКОНИЙ ПРЕДОК'), _feature('МЕТАМАГИЯ'), _feature('УВЕЛИЧЕНИЕ ХАРАКТЕРИСТИК')],
      dragonAncestor: DragonAncestor.red,
      metamagic: const [
        ClassOption(link: '/options/careful_spell', name: 'Аккуратное заклинание', source: null, descriptionHtml: '')
      ],
      improvements: const [
        AbilityScoreImprovement(level: 4, stats: {StatKind.charisma: 2})
      ],
    );
    expect(
      _names(playerFixture(spec: sorcerer)),
      containsAll([
        'ДРАКОНИЙ ПРЕДОК: КРАСНЫЙ (ОГОНЬ)',
        'МЕТАМАГИЯ: АККУРАТНОЕ ЗАКЛИНАНИЕ',
        'УВЕЛИЧЕНИЕ ХАРАКТЕРИСТИК: 4 УР.: ХАРИЗМА +2',
      ]),
    );

    final cavalier = Fighter(
      level: 3,
      isMain: true,
      features: [_feature('ДОПОЛНИТЕЛЬНЫЕ НАВЫКИ')],
      fightingStyles: const [FightingStyle.defence],
      archetypeId: Fighter.cavalier,
      archetypeSkills: const [Skill.history],
    );
    final cavalierPlayer = playerFixture(spec: cavalier);
    expect(_names(cavalierPlayer), contains('ДОПОЛНИТЕЛЬНЫЕ НАВЫКИ: ИСТОРИЯ'));
    expect(cavalierPlayer.chosenSkills, contains(Skill.history));

    final samurai = cavalier
        .copyWith(archetypeId: Fighter.samurai, archetypeSkills: const [], archetypeLanguages: const [Language.elvish]);
    expect(playerFixture(spec: samurai).knownLanguages, contains(Language.elvish));

    // «Посланник короны»: компетентность в Убеждении.
    final dragon =
        cavalier.copyWith(level: 7, archetypeId: Fighter.purpleDragon, archetypeSkills: const [Skill.persuasion]);
    expect(playerFixture(spec: dragon).expertiseSkills, contains(Skill.persuasion));

    const fist = ClassOption(
        link: '/options/fist_of_four_thunders',
        name: 'Кулак четырёх громов',
        source: null,
        descriptionHtml: '<p>Гром.</p>');
    final monk = Monk(
      level: 3,
      isMain: true,
      features: [_feature('АДЕПТ СТИХИЙ')],
      martialArtsDice: Dice.k4,
      traditionId: Monk.fourElements,
      disciplines: const [fist],
    );
    expect(_names(playerFixture(spec: monk)),
        containsAll(['АДЕПТ СТИХИЙ: КУЛАК ЧЕТЫРЁХ ГРОМОВ', 'ПРАКТИКА: КУЛАК ЧЕТЫРЁХ ГРОМОВ']));
    expect([2, 3, 6, 11, 17].map(Monk.disciplinesCountAt), [0, 1, 2, 3, 4]);
    expect((Player.fromJson(playerFixture(spec: monk).toJson()).classes.single as Monk).disciplines, [fist]);
  });
}
