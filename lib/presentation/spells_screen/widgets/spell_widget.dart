import 'package:dnd_character_list/domain/models/classes/specialization.dart';
import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:dnd_character_list/presentation/spells_screen/widgets/spell_info_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SpellWidget extends StatelessWidget {
  final Spell spell;
  final Specialization specialization;

  const SpellWidget({
    super.key,
    required this.spell,
    required this.specialization,
  });

  @override
  Widget build(BuildContext context) {
    final player = PlayerModel.getPlayer(context);
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => SpellInfoDialog.show(
              context,
              spell: spell,
              player: player,
              spellOwner: specialization,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    spell.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(8),
                  Text(spell.slot.name),
                  const Gap(8),
                  Text('Длительность: ${spell.duration != 0 ? '${spell.duration} минут' : 'Мгновенная'}'),
                  const Gap(8),
                  Text('Дистация: ${spell.distance} футов'),
                  const Gap(8),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Компоненты: ',
                        ),
                        TextSpan(
                          text: spell.components.map((e) => e.name).join(', '),
                        ),
                      ],
                      style: context.theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
