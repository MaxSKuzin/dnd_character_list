import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SetPersonalityScreen extends StatefulWidget {
  const SetPersonalityScreen({super.key});

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
                                labelText: 'Введите рост',
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
                                labelText: 'Введите вес',
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
                      _weight != 0;

                  return ElevatedButton(
                    onPressed: isFilled
                        ? () {
                            context.read<CreateCharacterCubit>().setPersonality(
                                  name: _nameController.text,
                                  hairColor: _hairController.text,
                                  eyesColor: _eyesController.text,
                                  skinColor: _skinController.text,
                                  story: _storyController.text,
                                  age: _age,
                                  height: _height,
                                  weight: _weight,
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
