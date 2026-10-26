import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/common/widgets/step_scaffold.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
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

  Future<void> _enterNumber(
      {required String title, required String label, required ValueChanged<int> onEntered}) async {
    FocusScope.of(context).unfocus();
    final value = await EnterNumberDialog.show(context, title: title, labelText: label);
    if (value == null || !mounted) return;
    setState(() => onEntered(value));
  }

  void _create() {
    final cubit = context.read<CreateCharacterCubit>();
    cubit.setPersonality(
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
    cubit.createCharacter();
  }

  @override
  Widget build(BuildContext context) {
    final race = context.read<CreateCharacterCubit>().race!;
    final valueStyle = context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);
    return ListenableBuilder(
      listenable:
          Listenable.merge([_nameController, _hairController, _eyesController, _skinController, _storyController]),
      builder: (context, _) {
        final controllers = [_nameController, _hairController, _eyesController, _skinController, _storyController];
        final isFilled = controllers.every((e) => e.text.trim().isNotEmpty) &&
            _age != 0 &&
            _height != 0 &&
            _weight != 0 &&
            _traitsFilled;
        return StepScaffold(
          title: 'Личность',
          description: 'Опишите персонажа и выберите по строке в таблицах предыстории: черта характера, идеал, '
              'привязанность и слабость обязательны.',
          actionLabel: 'Создать персонажа',
          onAction: isFilled ? _create : null,
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              SheetSection(
                icon: Icons.person_outline,
                title: 'Персонаж',
                child: Column(
                  children: [
                    _Field(controller: _nameController, label: 'Имя', autofocus: true),
                    _Field(controller: _storyController, label: 'История', maxLines: 5),
                  ],
                ),
              ),
              const Gap(12),
              SheetSection(
                icon: Icons.face_outlined,
                title: 'Внешность',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TileGrid(
                      columns: 3,
                      children: [
                        InfoTile(
                          label: 'Возраст',
                          value: _age == 0 ? '—' : '$_age',
                          caption: 'лет',
                          valueStyle: valueStyle,
                          onTap: () =>
                              _enterNumber(title: 'Возраст', label: 'Введите возраст', onEntered: (v) => _age = v),
                        ),
                        InfoTile(
                          label: 'Рост',
                          value: _height == 0 ? '—' : '$_height',
                          caption: 'см',
                          valueStyle: valueStyle,
                          onTap: () => _enterNumber(
                            title: 'Рост',
                            label: 'Рост в см. ${race.heightHint}',
                            onEntered: (v) => _height = v,
                          ),
                        ),
                        InfoTile(
                          label: 'Вес',
                          value: _weight == 0 ? '—' : '$_weight',
                          caption: 'кг',
                          valueStyle: valueStyle,
                          onTap: () => _enterNumber(
                            title: 'Вес',
                            label: 'Вес в кг. ${race.weightHint}',
                            onEntered: (v) => _weight = v,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    _Field(controller: _hairController, label: 'Цвет волос'),
                    _Field(controller: _eyesController, label: 'Цвет глаз'),
                    _Field(controller: _skinController, label: 'Цвет кожи'),
                  ],
                ),
              ),
              for (final table in widget.tables) ...[
                const Gap(12),
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
        );
      },
    );
  }
}

/// Поле ввода раздела; нажатие мимо поля убирает клавиатуру.
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;
  final int maxLines;

  const _Field({required this.controller, required this.label, this.autofocus = false, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        minLines: 1,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}
