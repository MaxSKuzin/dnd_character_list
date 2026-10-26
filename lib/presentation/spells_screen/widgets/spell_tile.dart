import 'package:dnd_character_list/domain/models/spell/spell.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';

/// Компактная плитка заклинания для сетки: название, школа, время накладывания, дистанция, компоненты и метки.
/// Полное описание — по нажатию, как у [SpellWidget] в списке.
class SpellTile extends StatelessWidget {
  final Spell spell;
  final VoidCallback onTap;

  /// Заклинание от расы, а не от класса.
  final bool isRacial;

  const SpellTile({super.key, required this.spell, required this.onTap, this.isRacial = false});

  /// Высота плитки в сетке: все плитки одинаковые, чтобы ряды не прыгали.
  static const height = 116.0;

  @override
  Widget build(BuildContext context) {
    final details = spell.details;
    final marks = [
      if (spell.isConcentration) 'Конц.',
      if (spell.isRitual) 'Рит.',
      if (isRacial) 'Раса',
    ];
    final secondary = context.theme.textTheme.bodySmall?.copyWith(color: Colors.white70);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: context.customColors?.cardColor,
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
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Название и школа — по одной строке; метки — справа от школы, чтобы не занимать отдельный ряд.
                  Text(
                    spell.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(spell.school, maxLines: 1, overflow: TextOverflow.ellipsis, style: secondary),
                      ),
                      for (final mark in marks) ...[const SizedBox(width: 4), _Mark(mark)],
                    ],
                  ),
                  const SizedBox(height: 6),
                  _Line(icon: Icons.timer_outlined, text: details?.castTime ?? '—'),
                  _Line(icon: Icons.straighten, text: details?.distance ?? '—'),
                  // Только буквы «В, С, М»: материалы целиком — в описании заклинания.
                  _Line(
                    icon: Icons.back_hand_outlined,
                    text: spell.components.map((e) => e.localizedName).join(', '),
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

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Line({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.theme.textTheme.bodySmall),
        ),
      ],
    );
  }
}

/// Метка: «Конц.» — концентрация, «Рит.» — ритуал, «Раса» — заклинание расы.
class _Mark extends StatelessWidget {
  final String text;

  const _Mark(this.text);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Colors.white54), borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(text, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}
