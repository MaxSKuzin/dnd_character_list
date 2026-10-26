import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/data/rules_repository.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/injection.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/loading_error.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Предыстория',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Gap(16),
              Expanded(
                child: FutureBuilder(
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
                    return ListView.separated(
                      itemCount: backgrounds.length,
                      separatorBuilder: (_, __) => const Gap(8),
                      itemBuilder: (context, index) => _BackgroundTile(
                        background: backgrounds[index],
                        isSelected: backgrounds[index] == _selected,
                        onTap: () => setState(() {
                          _selected = backgrounds[index] == _selected ? null : backgrounds[index];
                        }),
                      ),
                    );
                  },
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selected != null
                    ? () {
                        context.read<CreateCharacterCubit>().setBackground(_selected!);
                        widget.onContinue();
                      }
                    : null,
                child: const Text('Далее'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundTile extends StatelessWidget {
  final Background background;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackgroundTile({
    required this.background,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final details = [
      if (background.skills.isNotEmpty) 'Навыки: ${background.skills.map((e) => e.localizedName).join(', ')}',
      if (background.tools.isNotEmpty) 'Инструменты: ${background.tools.map((e) => e.title).join(', ')}',
      if (background.languagesCount > 0) 'Языки: ${background.languagesCount} на выбор',
      if (background.featureName != null) 'Умение: ${background.featureName}',
    ];
    return Card(
      color: isSelected ? context.customColors?.cardColor : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? Colors.white : Colors.white24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      background.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const Gap(4),
                    ...details.map(Text.new),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => HtmlDialog(title: background.name, html: background.descriptionHtml),
                ),
                icon: const Icon(Icons.info),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
