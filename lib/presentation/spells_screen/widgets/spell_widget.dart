import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SpellWidget extends StatelessWidget {
  final Spell spell;
  final Function() onTap;
  final Color? backgroundColor;

  const SpellWidget({
    super.key,
    this.backgroundColor,
    required this.onTap,
    required this.spell,
  });

  @override
  Widget build(BuildContext context) {
    final details = spell.details;
    final tags = [
      if (spell.isConcentration) 'Концентрация',
      if (spell.isRitual) 'Ритуал',
    ];
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: backgroundColor ?? context.customColors?.cardColor,
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
            onTap: onTap,
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
                  if (tags.isNotEmpty) Text('(${tags.join(', ')})'),
                  const Gap(8),
                  Text('${spell.slot.localizedName}, ${spell.school.toLowerCase()}'),
                  const Gap(8),
                  Text('Время накладывания: ${details?.castTime ?? spell.castTimeType?.localizedName ?? '—'}'),
                  if (details != null) ...[
                    const Gap(8),
                    Text('Длительность: ${details.duration}'),
                    const Gap(8),
                    Text('Дистанция: ${details.distance}'),
                  ],
                  const Gap(8),
                  Text(
                    'Компоненты: ${details?.components ?? spell.components.map((e) => e.localizedName).join(', ')}',
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
