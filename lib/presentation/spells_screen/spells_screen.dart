import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/spell/spell_slot.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_info_dialog.dart';
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
  ClassKind? selectedClass;

  @override
  Widget build(BuildContext context) {
    final spells = PlayerModel.spells(context);
    final availableSpells = spells.entries
        .expand(
          (e) => e.value.map(
            (el) => MapEntry(e.key, el),
          ),
        )
        .where(
          (e) =>
              (selectedSlot != null ? e.value.slot == selectedSlot : true) &&
              (selectedClass != null ? e.key.classKind == selectedClass : true),
        )
        .sorted(
          (a, b) => a.value.slot.compareTo(b.value.slot),
        );
    return SafeArea(
      child: Column(
        children: [
          if (spells.keys.length > 1)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: spells.keys
                    .map(
                      (e) => GestureDetector(
                        onTap: () => setState(() {
                          if (e.classKind != selectedClass) {
                            selectedClass = e.classKind;
                          } else {
                            selectedClass = null;
                          }
                        }),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Chip(
                            label: Text(
                              e.name,
                              style: TextStyle(
                                color: selectedClass == e.classKind ? context.theme.scaffoldBackgroundColor : null,
                              ),
                            ),
                            color: WidgetStatePropertyAll(
                              selectedClass == e.classKind ? Colors.white : null,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          SizedBox(
            height: 48,
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
          const Gap(8),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const Gap(16),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: availableSpells.length,
              itemBuilder: (context, index) {
                final spell = availableSpells[index];
                return SpellWidget(
                  onTap: () => SpellInfoDialog.show(
                    context,
                    spell: spell.value,
                    spellDescription: (slot) => spell.value.description(
                      PlayerModel.getPlayer(context),
                      spell.key,
                      slot,
                    ),
                  ),
                  spell: spell.value,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
