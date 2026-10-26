import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SelectRaceScreen extends StatefulWidget {
  const SelectRaceScreen({super.key});

  @override
  State<SelectRaceScreen> createState() => _SelectRaceScreenState();
}

class _SelectRaceScreenState extends State<SelectRaceScreen> {
  Race? _selectedRace;

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      title: 'Раса',
      description: 'Раса даёт прибавки к характеристикам, скорость, языки и особенности. Подробности — по «i».',
      onAction: _selectedRace != null
          ? () {
              context.read<CreateCharacterCubit>().setRace(_selectedRace!);
              context.pushRoute(const SelectClassRoute());
            }
          : null,
      body: ChoiceList(
        children: [
          for (final race in Race.values)
            ChoiceCard(
              title: race.name,
              subtitle: [
                race.statBonuses.entries.map((e) => '${e.key.localizedName} +${e.value}').join(', '),
                if (race.additionalStatsCount > 0) '+1 к ${race.additionalStatsCount} на выбор',
                'скорость ${race.speed} фт.',
              ].join(' · '),
              isSelected: race == _selectedRace,
              onTap: () => setState(() => _selectedRace = race == _selectedRace ? null : race),
              onInfo: () => showDialog(
                context: context,
                builder: (_) => HtmlDialog(
                  title: race.name,
                  html: race.peculiarities.map((e) => '<h3>${e.name}</h3><p>${e.description}</p>').join(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
