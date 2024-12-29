import 'package:auto_route/auto_route.dart';
import 'package:dnd_character_list/domain/models/bard_collegiums/bard_collegium.dart';
import 'package:dnd_character_list/domain/models/bard_collegiums/swords_collegium.dart';
import 'package:dnd_character_list/domain/models/fighting_style.dart';
import 'package:dnd_character_list/presentation/common/widgets/text_parser/text_parses_base.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SelectCollegiumScreen extends StatefulWidget {
  final void Function(BardCollegium collegium) onCollegiumSelected;

  const SelectCollegiumScreen({
    required this.onCollegiumSelected,
    super.key,
  });

  @override
  State<SelectCollegiumScreen> createState() => _SelectCollegiumScreenState();
}

class _SelectCollegiumScreenState extends State<SelectCollegiumScreen> {
  _CollegeKind? _selectedCollegiumKind;
  BardCollegium? _selectedCollegium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: _CollegeKind.values
                    .map(
                      (e) => Expanded(
                        child: ClipRRect(
                          child: ListTile(
                            title: Text(
                              e.name,
                            ),
                            onTap: () {
                              setState(() {
                                _selectedCollegiumKind = e;
                                _selectedCollegium = null;
                              });
                            },
                            selected: _selectedCollegiumKind == e,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const Gap(24),
              if (_selectedCollegiumKind != null)
                Expanded(
                  child: Column(
                    children: switch (_selectedCollegiumKind!) {
                      _CollegeKind.swords => [FightingStyle.dueling, FightingStyle.twoWeaponFighting]
                          .map(
                            (e) => ListTile(
                              title: ImageFiltered(
                                imageFilter: ColorFilter.mode(
                                  _selectedCollegium is SwordsCollegium &&
                                          (_selectedCollegium as SwordsCollegium).fightingStyle == e
                                      ? Colors.transparent
                                      : Colors.black45,
                                  BlendMode.srcATop,
                                ),
                                child: TextParses(
                                  e.description,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedCollegium = SwordsCollegium(fightingStyle: e);
                                });
                              },
                            ),
                          )
                          .toList(),
                      _CollegeKind.valor => [const SizedBox()],
                      _CollegeKind.whispers => [const SizedBox()],
                    },
                  ),
                )
              else
                const Spacer(),
              const Gap(16),
              OutlinedButton(
                onPressed: _selectedCollegium != null ? () => widget.onCollegiumSelected(_selectedCollegium!) : null,
                child: const Text('Продолжить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CollegeKind {
  swords,
  valor,
  whispers;

  String get name => {
        _CollegeKind.swords: 'Коллегия мечей',
        _CollegeKind.valor: 'Коллегия доблести',
        _CollegeKind.whispers: 'Коллегия шепота',
      }[this]!;
}
