import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectFightingStyleScreen extends StatefulWidget {
  final void Function(FightingStyle style) onStyleSelected;

  const SelectFightingStyleScreen({
    super.key,
    required this.onStyleSelected,
  });

  @override
  State<SelectFightingStyleScreen> createState() => _SelectFightingStyleScreenState();
}

class _SelectFightingStyleScreenState extends State<SelectFightingStyleScreen> {
  FightingStyle? _selectedStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Боевой стиль',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...FightingStyle.values.map(
                  (e) => ListTile(
                    title: ImageFiltered(
                      imageFilter: ColorFilter.mode(
                        _selectedStyle == e ? Colors.transparent : Colors.black45,
                        BlendMode.srcATop,
                      ),
                      child: TextParses(
                        e.description,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedStyle = e;
                      });
                    },
                  ),
                ),
                const Gap(16),
                OutlinedButton(
                  onPressed: _selectedStyle != null ? () => widget.onStyleSelected(_selectedStyle!) : null,
                  child: const Text('Продолжить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
