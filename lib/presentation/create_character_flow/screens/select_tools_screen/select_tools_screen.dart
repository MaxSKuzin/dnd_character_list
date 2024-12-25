import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/bloc/create_character_cubit.dart';
import 'package:dnd_character_list/domain/models/tools/tool.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectToolsScreen extends StatefulWidget {
  final void Function() onContinue;
  final List<Tool> tools;

  const SelectToolsScreen({
    super.key,
    required this.onContinue,
    required this.tools,
  });

  @override
  State<SelectToolsScreen> createState() => _SelectToolsScreenState();
}

class _SelectToolsScreenState extends State<SelectToolsScreen> {
  Tool? _selectedTool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.tools.first.category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.tools.length,
                  itemBuilder: (context, index) {
                    final tool = widget.tools[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedTool == tool) {
                            _selectedTool = null;
                          } else {
                            _selectedTool = tool;
                          }
                        });
                      },
                      child: Card(
                        color: _selectedTool == tool ? context.customColors?.cardColor : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                tool.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(8),
                              TextParses(
                                tool.description,
                              ),
                              const Gap(8),
                              Text(
                                'Цена: ${tool.price.toString()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: _selectedTool != null
                    ? () {
                        context.read<CreateCharacterCubit>().setTools([_selectedTool!]);
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
