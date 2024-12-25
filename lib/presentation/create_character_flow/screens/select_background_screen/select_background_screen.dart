import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/background.dart';
import 'package:dnd_character_list/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectBackgroundScreen extends StatefulWidget {
  final void Function() onContinue;
  const SelectBackgroundScreen({
    super.key,
    required this.onContinue,
  });

  @override
  State<SelectBackgroundScreen> createState() => _SelectBackgroundScreenState();
}

class _SelectBackgroundScreenState extends State<SelectBackgroundScreen> {
  Background? _selectedBackground;

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
                  children: Background.values
                      .map(
                        (e) => GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedBackground == e) {
                                _selectedBackground = null;
                              } else {
                                _selectedBackground = e;
                              }
                            });
                          },
                          child: ImageFiltered(
                            imageFilter: ColorFilter.mode(
                              _selectedBackground == e ? Colors.transparent : Colors.black45,
                              BlendMode.srcATop,
                            ),
                            child: DecoratedBox(
                              decoration: const ShapeDecoration(
                                shape: CircleBorder(
                                  side: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: FittedBox(
                                    child: Text(
                                      e.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selectedBackground != null
                    ? () {
                        final equipment = _selectedBackground!.startEquipment;
                        context.read<CreateCharacterCubit>().setBackground(_selectedBackground!);
                        context.read<CreateCharacterCubit>().setBackgroundItems(equipment.additionalItems);
                        if (equipment.availableTools.length > 1) {
                          context.router.push(
                            SelectToolsRoute(
                              tools: equipment.availableTools,
                              onContinue: widget.onContinue,
                            ),
                          );
                        } else {
                          context.read<CreateCharacterCubit>().setTools(equipment.availableTools);
                          widget.onContinue();
                        }
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
