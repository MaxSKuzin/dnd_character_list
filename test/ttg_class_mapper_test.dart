import 'package:dnd_character_list/data/ttg/ttg_class_mapper.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/classes/monk.dart';
import 'package:dnd_character_list/domain/models/classes/sorcerer.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/domain/models/dice.dart';
import 'package:dnd_character_list/domain/models/stat_kind.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ttg_fixtures.dart';

void main() {
  final mapper = TtgClassMapper();

  group('bard', () {
    final json = ttgFixture('class_bard');
    final info = mapper.map(json, subclasses: [ttgFixture('class_bard_lore')]);

    test('reads basic sections', () {
      expect(info.link, '/classes/bard');
      expect(info.name, 'Бард');
      expect(info.nameEn, 'Bard');
      expect(info.savingThrows, [StatKind.dexterity, StatKind.charisma]);
      expect(info.skillsCount, 3);
      // У барда любые навыки.
      expect(info.skillOptions, isEmpty);
      expect(info.tools.single.category, ToolCategory.musicalInstrument);
      expect(info.tools.single.choose, 3);
      expect(info.hitPointsHtml, contains('1к8 за каждый уровень барда'));
      expect(info.proficienciesHtml, contains('<strong>Доспехи:</strong> Лёгкие доспехи'));
      expect(info.quickBuildHtml, startsWith('<p style="text-align: justify;">Вы можете быстро создать барда'));
      expect(info.quickBuildHtml, isNot(contains('Классовые умения')));
    });

    test('reads level table', () {
      final first = info.level(1);
      expect(first.proficiencyBonus, 2);
      expect(first.cantripsKnown, 2);
      expect(first.spellsKnown, 4);
      expect(first.spellSlots, [2, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(info.featuresAt(1).map((e) => e.name), ['Вдохновение барда', 'Использование заклинаний']);
      expect(info.level(10).hasFeature(Bard.magicalSecrets), isTrue);
      expect(info.level(3).hasFeature(Bard.expertiseFeature), isTrue);
      expect(Bard.inspirationDiceAt(info, 5).name, 'к8');
      expect(info.feature('c287')!.isOptional, isTrue);
    });

    test('reads starting equipment with links', () {
      final weapons = info.startingEquipment.first.options;
      expect(weapons.map((e) => e.text), ['Рапира', 'Длинный меч', 'Любое простое оружие']);
      expect(weapons.first.items.single.id, '/weapons/rapier');
      expect(weapons.last.items.single.isChoice, isTrue);
      final instrument = info.startingEquipment[2].options.last.items.single;
      expect(instrument.isChoice, isTrue);
      final last = info.startingEquipment.last.options.single.items;
      expect(last.map((e) => e.id), ['/armors/leather_armor', '/weapons/dagger']);
    });

    test('keeps only official subclasses', () {
      expect(mapper.subclassLinks(json), ['/classes/bard/valor', '/classes/bard/lore', '/classes/bard/swords']);
      final lore = info.subclass(Bard.loreCollege)!;
      expect(lore.name, 'Коллегия Знаний');
      expect(lore.source, 'Книга игрока');
      expect(lore.descriptionHtml, isNotEmpty);
      expect(lore.featuresAt(3).map((e) => e.name), ['Дополнительные навыки', 'Острое словцо']);
      expect(info.subclassLevel, 3);
    });
  });

  group('sorcerer', () {
    final info = mapper.map(ttgFixture('class_sorcerer'), subclasses: [ttgFixture('class_sorcerer_draconic')]);

    test('chooses origin at first level', () {
      expect(info.subclassLevel, 1);
      final draconic = info.subclass('draconic')!;
      expect(draconic.name, 'Наследие Драконьей Крови');
      expect(draconic.featuresAt(1).map((e) => e.name), ['Драконий предок', 'Драконья устойчивость']);
      // Умения класса не попадают в подкласс.
      expect(draconic.features.map((e) => e.name), isNot(contains('Использование заклинаний')));
    });

    test('reads skills, spells and focus choice', () {
      expect(info.savingThrows, [StatKind.constitution, StatKind.charisma]);
      expect(info.skillOptions, contains(Skill.arcana));
      expect(info.skillOptions, hasLength(6));
      expect(info.tools, isEmpty);
      expect(info.level(1).cantripsKnown, 4);
      expect(info.level(1).spellsKnown, 2);
      final focus = info.startingEquipment[1].options.last.items.single;
      expect(focus.text, 'магическая фокусировка');
      expect(focus.isChoice, isTrue);
      final daggers = info.startingEquipment.last.options.single.items.single;
      expect((daggers.id, daggers.quantity), ('/weapons/dagger', 2));
    });

    test('reads sorcery points, metamagic and level-up features from the table', () {
      expect(info.level(2).columns[Sorcerer.sorceryPointsColumn], '2');
      expect(Sorcerer.sorceryPointsAt(info, 1), 0);
      expect(Sorcerer.sorceryPointsAt(info, 5), 5);
      expect(Sorcerer.metamagicCountAt(info, 2), 0);
      expect(Sorcerer.metamagicCountAt(info, 3), 2);
      expect(Sorcerer.metamagicCountAt(info, 9), 2);
      expect(Sorcerer.metamagicCountAt(info, 10), 3);
      expect(Sorcerer.metamagicCountAt(info, 20), 4);
      expect(info.level(4).hasFeature(Sorcerer.abilityScoreImprovement), isTrue);
      expect(info.level(8).hasFeature(Sorcerer.abilityScoreImprovement), isTrue);
      expect(info.feature(Sorcerer.sorcerousVersatility)?.isOptional, isTrue);
    });
  });

  group('monk', () {
    final info = mapper.map(ttgFixture('class_monk'), subclasses: [ttgFixture('class_monk_open_hand')]);

    test('reads proficiencies and equipment', () {
      expect(info.link, '/classes/monk');
      expect(info.savingThrows, [StatKind.strength, StatKind.dexterity]);
      expect(info.skillsCount, 2);
      expect(info.skillOptions, [
        Skill.acrobatics,
        Skill.athletics,
        Skill.history,
        Skill.insight,
        Skill.religion,
        Skill.stealth,
      ]);
      final tool = info.tools.single;
      expect((tool.isChoice, tool.choose), (true, 1));
      expect(tool.categories, [ToolCategory.craftsmenTool, ToolCategory.musicalInstrument]);
      final darts = info.startingEquipment.last.options.single.items.single;
      expect((darts.id, darts.quantity), ('/weapons/dart', 10));
      expect(info.level(1).cantripsKnown, isNull);
      expect(info.quickBuildHtml, contains('Ловкости'));
    });

    test('chooses tradition at third level', () {
      expect(info.subclassLevel, 3);
      expect(info.subclassTitle, 'Монастырские традиции');
      final openHand = info.subclass('open_hand')!;
      expect(openHand.name, 'Путь Открытой Ладони');
      expect(openHand.featuresAt(3).map((e) => e.name), ['Техники Открытой ладони']);
    });

    test('reads martial arts, ki and unarmored movement from the table', () {
      expect(Monk.martialArtsDiceAt(info, 1), Dice.k4);
      expect(Monk.martialArtsDiceAt(info, 5), Dice.k6);
      expect(Monk.martialArtsDiceAt(info, 17), Dice.k10);
      expect(Monk.kiPointsAt(info, 1), 0);
      expect(Monk.kiPointsAt(info, 2), 2);
      expect(Monk.unarmoredMovementAt(info, 1), 0);
      expect(Monk.unarmoredMovementAt(info, 6), 15);
      expect(info.level(4).hasFeature(Monk.abilityScoreImprovement), isTrue);
      expect(Monk.featuresAt(info, 1).map((e) => e.name), ['ЗАЩИТА БЕЗ ДОСПЕХОВ', 'БОЕВЫЕ ИСКУССТВА']);
      expect(Monk.featuresAt(info, 2).map((e) => e.name), ['ЦИ', 'ДВИЖЕНИЕ БЕЗ ДОСПЕХОВ', 'ВЫБРАННОЕ ОРУЖИЕ']);
      expect(Monk.featuresAt(info, 3, traditionId: 'open_hand').map((e) => e.name),
          ['ОТРАЖЕНИЕ СНАРЯДОВ', 'АТАКА НАДЕЛЁННАЯ ЦИ', 'ТЕХНИКИ ОТКРЫТОЙ ЛАДОНИ']);
    });
  });
}
