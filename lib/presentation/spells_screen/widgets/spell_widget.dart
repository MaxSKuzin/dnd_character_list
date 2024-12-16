import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
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
                  if (spell.isRitual) const Text('(Ритуал)'),
                  const Gap(8),
                  Text(spell.slot.name),
                  const Gap(8),
                  Text('Время наложения: $_castTime'),
                  const Gap(8),
                  Text('Длительность: $_durationText'),
                  const Gap(8),
                  Text('Дистация: $_distanceText'),
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

  String get _distanceText {
    if (spell.distance != 0) {
      return '${spell.distance} футов';
    }
    return 'На себя';
  }

  String get _castTime {
    return '${spell.timeToCast} ${spell.castTimeType.name}';
  }

  String get _durationText {
    if (spell.duration != null && spell.duration != Duration.zero) {
      return '${spell.duration!.inMinutes} минут';
    } else if (spell.durationInRounds != null) {
      return '${spell.durationInRounds} раундов';
    }
    return 'Мгновенная';
  }
}
