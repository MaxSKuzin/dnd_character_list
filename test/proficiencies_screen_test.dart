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
          onSelected: (tools, _) => result = tools,
        ),
      ),
    );

    FilterChip chip(String name) => tester.widget<FilterChip>(find.widgetWithText(FilterChip, name));

    expect(chip('Лютня').onSelected, isNull);
    expect(chip('Флейта').onSelected, isNotNull);

    for (final name in ['Лютня', 'Флейта', 'Барабан', 'Лира']) {
      await tester.ensureVisible(find.widgetWithText(FilterChip, name));
      await tester.tap(find.widgetWithText(FilterChip, name));
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(OutlinedButton, 'Далее'));

    expect(result, ['Флейта', 'Барабан', 'Лира']);
  });
}
