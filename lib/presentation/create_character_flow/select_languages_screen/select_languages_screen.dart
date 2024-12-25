import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/language.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectLanguagesScreen extends StatefulWidget {
  final List<Language> knownLanguages;
  final int maxLanguages;

  const SelectLanguagesScreen({
    super.key,
    required this.knownLanguages,
    required this.maxLanguages,
  });

  @override
  State<SelectLanguagesScreen> createState() => _SelectLanguagesScreenState();
}

class _SelectLanguagesScreenState extends State<SelectLanguagesScreen> {
  final _selectedLanguages = <Language>[];

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
                'Языки',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Text(
                'Выбрано навыков: ${_selectedLanguages.length}/${widget.maxLanguages}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Gap(16),
              Expanded(
                child: ListView(
                  children: Language.values.whereNot((e) => widget.knownLanguages.contains(e)).map((e) {
                    final isSelected = _selectedLanguages.contains(e);
                    return ListTile(
                      title: Text(e.name),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedLanguages.remove(e);
                          } else {
                            if (_selectedLanguages.length < widget.maxLanguages) {
                              _selectedLanguages.add(e);
                            }
                          }
                        });
                      },
                      selected: isSelected,
                    );
                  }).toList(),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selectedLanguages.length == widget.maxLanguages
                    ? () {
                        context.read<CreateCharacterCubit>().setLanguages(_selectedLanguages);
                        context.router.push(
                          const SetPersonalityRoute(),
                        );
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
