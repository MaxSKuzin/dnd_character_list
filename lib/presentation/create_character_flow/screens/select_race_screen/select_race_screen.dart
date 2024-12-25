import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/races/race.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Раса',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Expanded(
                child: GridView(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  children: Race.values
                      .map(
                        (e) => _selectedRace != e
                            ? OutlinedButton(
                                onPressed: () => setState(
                                  () {
                                    _selectedRace = e;
                                  },
                                ),
                                child: Text(
                                  e.name,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : FilledButton(
                                onPressed: () => setState(
                                  () {
                                    _selectedRace = null;
                                  },
                                ),
                                child: Text(
                                  e.name,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                      )
                      .toList(),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selectedRace != null
                    ? () {
                        context.read<CreateCharacterCubit>().setRace(_selectedRace!);
                        context.pushRoute(FillStatsRoute());
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
