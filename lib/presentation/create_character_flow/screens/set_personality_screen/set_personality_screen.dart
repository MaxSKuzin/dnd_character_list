import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/domain/models/personality.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:dnd_character_list/presentation/create_character_flow/screens/set_personality_screen/personality_table_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SetPersonalityScreen extends StatefulWidget {
  /// Таблицы персонализации предыстории с ttg.club.
  final List<PersonalityTable> tables;

  const SetPersonalityScreen({
    super.key,
    this.tables = const [],
  });

  @override
  State<SetPersonalityScreen> createState() => _SetPersonalityScreenState();
}

class _SetPersonalityScreenState extends State<SetPersonalityScreen> {
  final _nameController = TextEditingController();
  final _hairController = TextEditingController();
  final _skinController = TextEditingController();
  final _eyesController = TextEditingController();
  final _storyController = TextEditingController();
  int _age = 0;
  int _height = 0;
  int _weight = 0;

  /// Выбранная строка по заголовку таблицы.
  final _traits = <String, String>{};

  /// Черта характера, идеал, привязанность и слабость обязательны, остальные таблицы — по желанию.
  bool get _traitsFilled =>
      widget.tables.where((e) => e.kind != PersonalityTableKind.other).every((e) => _traits.containsKey(e.title));

  @override
  void dispose() {
    _nameController.dispose();
    _hairController.dispose();
    _skinController.dispose();
    _eyesController.dispose();
    _storyController.dispose();

    super.dispose();
  }

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
                'Личность',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Gap(8),
              const Text(
                'Опишите персонажа и выберите по строке в таблицах предыстории: черта характера, идеал, '
                'привязанность и слабость обязательны.',
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TapRegion(
                        child: TextFormField(
                          autofocus: true,
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Имя',
                          ),
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      const Gap(16),
                      TapRegion(
                        child: TextFormField(
                          autofocus: true,
                          controller: _hairController,
                          decoration: const InputDecoration(
                            labelText: 'Цвет волос',
                          ),
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      const Gap(16),
                      TapRegion(
                        child: TextFormField(
                          autofocus: true,
                          controller: _eyesController,
                          decoration: const InputDecoration(
                            labelText: 'Цвет глаз',
                          ),
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      const Gap(16),
                      TapRegion(
                        child: TextFormField(
                          autofocus: true,
                          controller: _skinController,
                          decoration: const InputDecoration(
                            labelText: 'Цвет кожи',
                          ),
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      const Gap(16),
                      TapRegion(
                        child: TextFormField(
                          autofocus: true,
                          controller: _storyController,
                          decoration: const InputDecoration(
                            labelText: 'История',
                          ),
                          keyboardType: TextInputType.name,
                        ),
                      ),
                      const Gap(16),
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                        ),
                        children: [
                          GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final newAge = await EnterNumberDialog.show(
                                context,
                                title: 'Возраст',
                                labelText: 'Введите возраст',
                              );
                              if (newAge == null || !mounted) {
                                return;
                              }
                              setState(() {
                                _age = newAge;
                              });
                            },
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$_age',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Возраст',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final newHeight = await EnterNumberDialog.show(
                                context,
                                title: 'Рост',
                                labelText: 'Рост в см. ${context.read<CreateCharacterCubit>().race!.heightHint}',
                              );
                              if (newHeight == null || !mounted) {
                                return;
                              }
                              setState(() {
                                _height = newHeight;
                              });
                            },
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$_height',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Рост',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              final newWeight = await EnterNumberDialog.show(
                                context,
                                title: 'Вес',
                                labelText: 'Вес в кг. ${context.read<CreateCharacterCubit>().race!.weightHint}',
                              );
                              if (newWeight == null || !mounted) {
                                return;
                              }
                              setState(() {
                                _weight = newWeight;
                              });
                            },
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$_weight',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Вес',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (final table in widget.tables) ...[
                        const Gap(16),
                        PersonalityTableSelector(
                          table: table,
                          selected: _traits[table.title],
                          onChanged: (value) => setState(() {
                            if (value == null) {
                              _traits.remove(table.title);
                            } else {
                              _traits[table.title] = value;
                            }
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Gap(24),
              ListenableBuilder(
                listenable: Listenable.merge([
                  _nameController,
                  _hairController,
                  _eyesController,
                  _skinController,
                  _storyController,
                ]),
                builder: (context, values) {
                  final isFilled = _nameController.text.isNotEmpty &&
                      _hairController.text.isNotEmpty &&
                      _eyesController.text.isNotEmpty &&
                      _skinController.text.isNotEmpty &&
                      _storyController.text.isNotEmpty &&
                      _age != 0 &&
                      _height != 0 &&
                      _weight != 0 &&
                      _traitsFilled;

                  return ElevatedButton(
                    onPressed: isFilled
                        ? () {
                            context.read<CreateCharacterCubit>().setPersonality(
                                  Personality(
                                    name: _nameController.text,
                                    hairColor: _hairController.text,
                                    eyesColor: _eyesController.text,
                                    skinColor: _skinController.text,
                                    story: _storyController.text,
                                    age: _age,
                                    height: _height,
                                    weight: _weight,
                                    traits: Map.of(_traits),
                                  ),
                                );
                            context.read<CreateCharacterCubit>().createCharacter();
                          }
                        : null,
                    child: const Text('Далее'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
