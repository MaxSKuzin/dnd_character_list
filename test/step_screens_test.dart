import 'package:dnd_character_list/domain/models/skill.dart';
import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_option_screen/select_option_screen.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/select_skills_screen/select_skills_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FilledButton next(WidgetTester tester) => tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Далее'));

  testWidgets('skills: counter in the header, extra skills are disabled when the limit is reached', (tester) async {
    List<Skill>? result;
    await tester.pumpWidget(
      MaterialApp(
        home: SelectSkillsScreen(
          title: 'Навыки',
          maxSkills: 2,
          availableSkills: const [Skill.acrobatics, Skill.athletics, Skill.history],
          onSkillsSelected: (skills) => result = skills,
        ),
      ),
    );
    expect(find.text('0 из 2'), findsOneWidget);
    expect(next(tester).onPressed, isNull);

    await tester.tap(find.text('Акробатика'));
    await tester.tap(find.text('Атлетика'));
    await tester.pump();
    expect(find.text('2 из 2'), findsOneWidget);
    ChoiceCard card(String title) => tester.widget<ChoiceCard>(find.widgetWithText(ChoiceCard, title));
    expect(card('История').onTap, isNull);
    expect(card('Акробатика').onTap, isNotNull, reason: 'выбранный навык можно снять');

    await tester.tap(find.text('Далее'));
    expect(result, [Skill.acrobatics, Skill.athletics]);
  });

  testWidgets('option: one choice, tapping again clears it', (tester) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        home: SelectOptionScreen(
          title: 'Драконий предок',
          options: const [SelectOption(title: 'Красный', subtitle: 'Огонь'), SelectOption(title: 'Синий')],
          onSelected: (index) => result = index,
        ),
      ),
    );
    await tester.tap(find.text('Синий'));
    await tester.pump();
    await tester.tap(find.text('Синий'));
    await tester.pump();
    expect(next(tester).onPressed, isNull);

    await tester.tap(find.text('Красный'));
    await tester.pump();
    await tester.tap(find.text('Далее'));
    await tester.pump();
    expect(result, 0);
  });
}
