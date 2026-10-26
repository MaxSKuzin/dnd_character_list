import 'package:dnd_character_list/data/ttg/ttg_class_mapper.dart';
import 'package:dnd_character_list/domain/models/classes/bard.dart';
import 'package:dnd_character_list/domain/models/skill.dart';
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
  });
}
