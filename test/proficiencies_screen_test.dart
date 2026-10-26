import 'package:dnd_character_list/domain/models/balance.dart';
import 'package:dnd_character_list/domain/models/equipment_catalog.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/domain/models/tools/tool_category.dart';
import 'package:dnd_character_list/domain/models/tools/tool_proficiency_option.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/proficiencies_screen/proficiencies_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('owned tools cannot be chosen again', (tester) async {
    List<String>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: ProficienciesScreen(
          title: 'Владение инструментами',
          tools: const [
            ToolProficiencyOption(
              title: 'Три музыкальных инструмента на ваш выбор',
              category: ToolCategory.musicalInstrument,
              choose: 3,
            ),
          ],
          knownTools: const ['Набор для грима', 'Лютня'],
          catalog: EquipmentCatalog(
            weapons: const [],
            armors: const [],
            shields: const [],
            gear: const [],
            packs: const [],
            tools: [
              for (final name in ['Барабан', 'Лира', 'Лютня', 'Флейта', 'Шалмей'])
                Tool(
                  category: ToolCategory.musicalInstrument,
                  name: name,
                  description: '',
                  price: const Balance(0),
                ),
            ],
          ),
          onSelected: (tools, _) => result = tools,
        ),
      ),
    );

    await tester.pumpAndSettle();

    FilterChip chip(String name) => tester.widget<FilterChip>(find.widgetWithText(FilterChip, name));

    expect(chip('Лютня').onSelected, isNull);
    expect(chip('Флейта').onSelected, isNotNull);

    for (final name in ['Лютня', 'Флейта', 'Барабан', 'Лира']) {
      await tester.ensureVisible(find.widgetWithText(FilterChip, name));
      await tester.tap(find.widgetWithText(FilterChip, name));
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(FilledButton, 'Далее'));

    expect(result, ['Флейта', 'Барабан', 'Лира']);
  });
}
