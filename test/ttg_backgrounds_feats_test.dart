import 'package:dnd_character_list/data/ttg/ttg_backgrounds_mapper.dart';
import 'package:dnd_character_list/data/ttg/ttg_feats_mapper.dart';
import 'package:dnd_character_list/data/ttg/ttg_text.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ttg_fixtures.dart';

void main() {
  group('backgrounds', () {
    final mapper = TtgBackgroundsMapper();

    test('maps skills, tools and personality tables', () {
      final criminal = mapper.map('/backgrounds/criminal', ttgFixture('background_criminal'));
      expect(criminal.link, '/backgrounds/criminal');
      expect(criminal.name, 'Преступник');
      expect(criminal.skills, [Skill.deception, Skill.stealth]);
      expect(criminal.tools.map((e) => (e.category, e.choose)), [
        (ToolCategory.thievesTool, 0),
        (ToolCategory.playSet, 1),
      ]);
      expect(criminal.gold, 15);
      expect(criminal.featureName, 'Криминальные связи');
      expect(criminal.tables.map((e) => e.kind), [
        PersonalityTableKind.other,
        PersonalityTableKind.trait,
        PersonalityTableKind.ideal,
        PersonalityTableKind.bond,
        PersonalityTableKind.flaw,
      ]);
      expect(criminal.tables[1].options.first, isNot(startsWith('1')));
    });

    test('joins equipment split by commas and drops money', () {
      final urchin = mapper.map('/backgrounds/urchin', ttgFixture('background_urchin'));
      expect(urchin.equipment, [
        'Маленький нож',
        'Карта города, в котором вы выросли',
        'Ручная мышь',
        'Безделушка в память о родителях',
        'Комплект повседневной одежды',
        'Поясной кошель',
      ]);
      expect(urchin.gold, 10);
    });
  });

  group('feats', () {
    final mapper = TtgFeatsMapper();

    test('maps requirements and stat increase', () {
      final resilient = mapper.map('/feats/resilient', ttgFixture('feat_resilient'));
      expect(resilient.slug, 'resilient');
      expect(resilient.grantsSavingThrow, isTrue);
      expect(resilient.statIncreaseOptions.toSet(), StatKind.values.toSet());
      expect(resilient.requirementText, isNull);

      final athlete = mapper.map('/feats/athlete', ttgFixture('feat_athlete'));
      expect(athlete.statIncreaseOptions, [StatKind.strength, StatKind.dexterity]);
    });
  });

  test('text helpers', () {
    expect(TtgText.skill('SLEIGHT_OF_HAND'), Skill.sleightOfHand);
    expect(TtgText.skill('ANIMAL_HANDLING'), Skill.animalHandling);
    expect(TtgText.stat('CHARISMA'), StatKind.charisma);
    expect(TtgText.normalizeLink('/items/Thieves’_Tools'), "/items/thieves'_tools");
    expect(TtgText.plainText('<a href="/weapons/rapier">рапира [rapier]</a>'), 'рапира');
    expect(TtgText.parseCost('2.0 зм')?.value, 200);
    expect(TtgText.parseCost('5 мм.')?.value, 5);
    expect(
      TtgText.html('<p>видимое<sup><a href="/rules/Errata_(PHB)" title="добавлено в Эррате">1</a></sup> вами</p>'),
      '<p>видимое вами</p>',
    );
  });
}
