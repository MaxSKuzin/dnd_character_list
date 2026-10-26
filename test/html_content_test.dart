import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _html = '''<p>Цель должна бросать к10.</p>
<table>
<tbody><tr class="table_header">
<td>к10</td> <td>Поведение</td> </tr> <tr>
<td><nobr>9-10</nobr></td> <td>Действует как обычно.</td> </tr> <tr>
</tr> </tbody></table><br><p><strong><em>На больших уровнях.</em></strong> Смотрите <a href="/spells/9-bless/">благословение [bless]</a> и <a href="/bestiary/333-raven/">ворона</a>.</p>
<ul>
<li>Первый эффект.</li>
<li>Второй эффект.</li>
</ul>''';

void main() {
  testWidgets('renders paragraphs, tables, lists and spell links', (tester) async {
    String? tappedLink;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HtmlContent(
              _html,
              canOpenLink: (href) => href.startsWith('/spells/'),
              onLinkTap: (href) => tappedLink = href,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Цель должна бросать к10.'), findsOneWidget);
    expect(find.byType(Table), findsOneWidget);
    expect(find.text('Поведение'), findsOneWidget);
    expect(find.text('9-10'), findsOneWidget);
    expect(find.text('•'), findsNWidgets(2));
    expect(find.text('Второй эффект.'), findsOneWidget);

    final paragraph = find.textContaining('На больших уровнях.', findRichText: true);
    expect(paragraph, findsOneWidget);
    final spans = <TextSpan>[];
    (tester.widget<RichText>(paragraph).text as TextSpan).visitChildren((span) {
      if (span is TextSpan && span.text != null) spans.add(span);
      return true;
    });
    final bold = spans.firstWhere((e) => e.text == 'На больших уровнях.');
    expect(bold.style?.fontWeight, FontWeight.bold);
    expect(bold.style?.fontStyle, FontStyle.italic);

    final spellLink = spans.firstWhere((e) => e.text == 'благословение [bless]');
    (spellLink.recognizer as dynamic).onTap();
    expect(tappedLink, '/spells/9-bless/');
    expect(spans.firstWhere((e) => e.text == 'ворона').recognizer, isNull);
  });
}
