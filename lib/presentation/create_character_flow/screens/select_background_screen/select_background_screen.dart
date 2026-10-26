import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/loading_error.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Предыстории из «Книги игрока» с https://5e14.ttg.club/backgrounds.
@RoutePage()
class SelectBackgroundScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const SelectBackgroundScreen({
    super.key,
    required this.onContinue,
  });

  @override
  State<SelectBackgroundScreen> createState() => _SelectBackgroundScreenState();
}

class _SelectBackgroundScreenState extends State<SelectBackgroundScreen> {
  final _repository = getIt<RulesRepository>();
  late Future<List<Background>> _backgrounds = _repository.getBackgrounds();
  Background? _selected;

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      title: 'Предыстория',
      description: 'Чем персонаж занимался до приключений: навыки, инструменты, языки, снаряжение и умение.',
      onAction: _selected != null
          ? () {
              context.read<CreateCharacterCubit>().setBackground(_selected!);
              widget.onContinue();
            }
          : null,
      body: FutureBuilder(
        future: _backgrounds,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LoadingError(
              message: 'Не удалось загрузить предыстории с ttg.club.',
              error: snapshot.error!,
              onRetry: () => setState(() => _backgrounds = _repository.getBackgrounds()),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final backgrounds = [...snapshot.data!]..sort((a, b) => a.name.compareTo(b.name));
          return ChoiceList(
            children: [
              for (final background in backgrounds)
                ChoiceCard(
                  title: background.name,
                  subtitle: [
                    if (background.skills.isNotEmpty)
                      'Навыки: ${background.skills.map((e) => e.localizedName).join(', ')}',
                    if (background.tools.isNotEmpty) 'Инструменты: ${background.tools.map((e) => e.title).join(', ')}',
                    if (background.languagesCount > 0) 'Языки: ${background.languagesCount} на выбор',
                    if (background.featureName != null) 'Умение: ${background.featureName}',
                  ].join('\n'),
                  isSelected: background == _selected,
                  onTap: () => setState(() => _selected = background == _selected ? null : background),
                  onInfo: () => showDialog(
                    context: context,
                    builder: (_) => HtmlDialog(title: background.name, html: background.descriptionHtml),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
