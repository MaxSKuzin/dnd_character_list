import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SpellsScreen extends StatefulWidget {
  const SpellsScreen({super.key});

  @override
  State<SpellsScreen> createState() => _SpellsScreenState();
}

class _SpellsScreenState extends State<SpellsScreen> {
  SpellSlot? selectedSlot;

  @override
  Widget build(BuildContext context) {
    final spells = PlayerModel.spells(context)
        .where(
          (e) => selectedSlot != null ? e.slot == selectedSlot : true,
        )
        .sorted(
          (a, b) => a.slot.compareTo(b.slot),
        );
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: SpellSlot.values
                  .map(
                    (e) => GestureDetector(
                      onTap: () => setState(() {
                        if (e != selectedSlot) {
                          selectedSlot = e;
                        } else {
                          selectedSlot = null;
                        }
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Chip(
                          label: Text(
                            e.name,
                            style: TextStyle(
                              color: selectedSlot == e ? context.theme.scaffoldBackgroundColor : null,
                            ),
                          ),
                          color: WidgetStatePropertyAll(
                            selectedSlot == e ? Colors.white : null,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Gap(16),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: spells.length,
              itemBuilder: (context, index) {
                final spell = spells[index];
                return SpellWidget(spell: spell);
              },
            ),
          ),
        ],
      ),
    );
  }
}
