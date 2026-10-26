import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SelectFightingStyleScreen extends StatefulWidget {
  final void Function(FightingStyle style) onStyleSelected;

  /// Доступные стили; по умолчанию — все.
  final List<FightingStyle>? styles;

  const SelectFightingStyleScreen({
    super.key,
    required this.onStyleSelected,
    this.styles,
  });

  @override
  State<SelectFightingStyleScreen> createState() => _SelectFightingStyleScreenState();
}

class _SelectFightingStyleScreenState extends State<SelectFightingStyleScreen> {
  FightingStyle? _selectedStyle;

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      title: 'Боевой стиль',
      description: 'Особая манера боя. Стиль выбирается один раз, повторно его взять нельзя.',
      onAction: _selectedStyle != null ? () => widget.onStyleSelected(_selectedStyle!) : null,
      body: ChoiceList(
        children: [
          for (final style in widget.styles ?? FightingStyle.values)
            ChoiceCard(
              title: style.title,
              isSelected: style == _selectedStyle,
              onTap: () => setState(() => _selectedStyle = style == _selectedStyle ? null : style),
              // Название уже в заголовке карточки — в описании оно не повторяется.
              child: TextParses(style.description.replaceFirst(RegExp(r'^<b>[^<]*</b>\.\s*'), '')),
            ),
        ],
      ),
    );
  }
}
