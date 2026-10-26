import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Отображает html-фрагмент с ttg.club: абзацы, жирный и курсив, списки,
/// таблицы, заголовки и ссылки.
class HtmlContent extends StatefulWidget {
  final String html;

  /// Ссылки, для которых [canOpenLink] вернул `true`, выделяются и открываются через [onLinkTap].
  /// Остальные отображаются обычным текстом.
  final bool Function(String href)? canOpenLink;
  final void Function(String href)? onLinkTap;

  const HtmlContent(
    this.html, {
    super.key,
    this.canOpenLink,
    this.onLinkTap,
  });

  @override
  State<HtmlContent> createState() => _HtmlContentState();
}

class _HtmlContentState extends State<HtmlContent> {
  final _recognizers = <TapGestureRecognizer>[];

  static const _blockSpacing = 8.0;
  static const _blockTags = {
    'p',
    'div',
    'ul',
    'ol',
    'li',
    'table',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'blockquote',
  };

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final fragment = html_parser.parseFragment(widget.html);
    final style = DefaultTextStyle.of(context).style;
    return _column(_blocks(fragment.nodes, style));
  }

  Widget _column(List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, child) in children.indexed) ...[
            if (index > 0) const Gap(_blockSpacing),
            child,
          ],
        ],
      );

  List<Widget> _blocks(List<dom.Node> nodes, TextStyle style) {
    final blocks = <Widget>[];
    var inline = <InlineSpan>[];

    void flushInline() {
      final paragraph = _paragraph(inline, style);
      if (paragraph != null) blocks.add(paragraph);
      inline = [];
    }

    for (final node in nodes) {
      if (node is dom.Element && _blockTags.contains(node.localName)) {
        flushInline();
        final block = _block(node, style);
        if (block != null) blocks.add(block);
      } else {
        inline.addAll(_inline(node, style));
      }
    }
    flushInline();
    return blocks;
  }

  Widget? _block(dom.Element element, TextStyle style) {
    switch (element.localName) {
      case 'ul':
      case 'ol':
        final items = element.children.where((e) => e.localName == 'li').toList();
        if (items.isEmpty) return null;
        return _column([
          for (final (index, item) in items.indexed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  child: Text(element.localName == 'ol' ? '${index + 1}.' : '•', style: style),
                ),
                Expanded(child: _column(_blocks(item.nodes, style))),
              ],
            ),
        ]);
      case 'table':
        return _table(element, style);
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        final headerStyle = style.copyWith(fontWeight: FontWeight.bold, fontSize: (style.fontSize ?? 14) + 2);
        return _paragraph(_inline(element, headerStyle), headerStyle);
      case 'blockquote':
        return Container(
          padding: const EdgeInsets.only(left: 8),
          decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.white54, width: 2))),
          child: _column(_blocks(element.nodes, style.copyWith(fontStyle: FontStyle.italic))),
        );
      default:
        final children = _blocks(element.nodes, style);
        return children.isEmpty ? null : _column(children);
    }
  }

  Widget? _table(dom.Element table, TextStyle style) {
    final rows = table.querySelectorAll('tr').where((e) => e.children.isNotEmpty).toList();
    if (rows.isEmpty) return null;
    final columnsCount = rows.map((e) => e.children.length).reduce((a, b) => a > b ? a : b);
    return Table(
      border: TableBorder.all(color: Colors.white24),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: columnsCount > 1 ? const {0: IntrinsicColumnWidth()} : null,
      children: rows.map((row) {
        final isHeader = row.classes.contains('table_header') || row.children.every((e) => e.localName == 'th');
        final cellStyle = isHeader ? style.copyWith(fontWeight: FontWeight.bold) : style;
        final cells = row.children;
        return TableRow(
          decoration: isHeader ? const BoxDecoration(color: Colors.white10) : null,
          children: List.generate(
            columnsCount,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: index < cells.length
                  ? _column(_blocks(cells[index].nodes, cellStyle))
                  : const SizedBox.shrink(),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<InlineSpan> _inline(dom.Node node, TextStyle style) {
    if (node is dom.Text) {
      return [TextSpan(text: node.text.replaceAll(RegExp(r'\s+'), ' '), style: style)];
    }
    if (node is! dom.Element) return [];

    switch (node.localName) {
      case 'br':
        return [TextSpan(text: '\n', style: style)];
      case 'strong':
      case 'b':
        style = style.copyWith(fontWeight: FontWeight.bold);
      case 'em':
      case 'i':
        style = style.copyWith(fontStyle: FontStyle.italic);
      case 'u':
        style = style.copyWith(decoration: TextDecoration.underline);
      case 'sup':
      case 'sub':
        style = style.copyWith(fontSize: (style.fontSize ?? 14) * 0.75);
      case 'a':
        final href = node.attributes['href'];
        if (href != null && widget.onLinkTap != null && (widget.canOpenLink?.call(href) ?? true)) {
          final recognizer = TapGestureRecognizer()..onTap = () => widget.onLinkTap!(href);
          _recognizers.add(recognizer);
          return _children(node, style).map((e) => _withLink(e, recognizer)).toList();
        }
    }
    return _children(node, style);
  }

  List<InlineSpan> _children(dom.Element element, TextStyle style) =>
      element.nodes.expand((e) => _inline(e, style)).toList();

  InlineSpan _withLink(InlineSpan span, TapGestureRecognizer recognizer) {
    if (span is! TextSpan) return span;
    return TextSpan(
      text: span.text,
      style: span.style?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: Theme.of(context).colorScheme.primary,
      ),
      recognizer: recognizer,
    );
  }

  /// Убирает пробелы по краям абзаца и пропускает пустые абзацы.
  Widget? _paragraph(List<InlineSpan> spans, TextStyle style) {
    final texts = spans.whereType<TextSpan>().toList();
    if (texts.every((e) => (e.text ?? '').trim().isEmpty)) return null;

    final result = [...spans];
    final firstIndex = result.indexWhere((e) => e is TextSpan && (e.text ?? '').trim().isNotEmpty);
    final lastIndex = result.lastIndexWhere((e) => e is TextSpan && (e.text ?? '').trim().isNotEmpty);
    result[firstIndex] = _copyText(result[firstIndex] as TextSpan, (result[firstIndex] as TextSpan).text!.trimLeft());
    result[lastIndex] = _copyText(result[lastIndex] as TextSpan, (result[lastIndex] as TextSpan).text!.trimRight());
    return Text.rich(
      TextSpan(children: result.sublist(firstIndex, lastIndex + 1)),
      style: style,
    );
  }

  TextSpan _copyText(TextSpan span, String text) => TextSpan(
        text: text,
        style: span.style,
        recognizer: span.recognizer,
      );
}

/// Диалог с заголовком и описанием с ttg.club.
class HtmlDialog extends StatelessWidget {
  final String title;
  final String html;

  const HtmlDialog({
    super.key,
    required this.title,
    required this.html,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const Gap(8),
            Flexible(
              child: SingleChildScrollView(child: HtmlContent(html)),
            ),
          ],
        ),
      ),
    );
  }
}
