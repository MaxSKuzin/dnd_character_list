import 'package:flutter/material.dart';

class TextParses extends StatelessWidget {
  final String text;

  const TextParses(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<TextItem> items = _parseText(text);
    return RichText(
      text: TextSpan(
        children: items.map(
          (item) {
            final style = item.selection == TextSelection.i
                ? const TextStyle(fontStyle: FontStyle.italic)
                : item.selection == TextSelection.b
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null;
            return TextSpan(
              text: item.text,
              style: style,
            );
          },
        ).toList(),
      ),
    );
  }

  List<TextItem> _parseText(String text) {
    final List<TextItem> items = [];
    final regExp = RegExp(r'<[b,i]>(.*?)<\/[b,i]>');
    final matches = regExp.allMatches(text);

    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        items.add(TextItem(
          text: text.substring(lastMatchEnd, match.start),
          selection: TextSelection.none,
        ));
      }
      final tag = match.group(0)!;
      final content = match.group(1)!;
      final selection = tag.startsWith('<b>') ? TextSelection.b : TextSelection.i;
      items.add(TextItem(
        text: content,
        selection: selection,
      ));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      items.add(TextItem(
        text: text.substring(lastMatchEnd),
        selection: TextSelection.none,
      ));
    }

    return items;
  }
}

class TextItem {
  final String text;
  final TextSelection selection;

  const TextItem({
    required this.text,
    required this.selection,
  });
}

enum TextSelection {
  none,
  i,
  b,
}
