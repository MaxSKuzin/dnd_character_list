import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Продолжительный отдых в шапке экрана боя. Кнопка на месте всегда, чтобы экран не сдвигался, и активна,
/// только когда хиты, ячейки заклинаний или ресурсы классов не на максимуме.
class LongRestButton extends StatelessWidget {
  const LongRestButton({super.key});

  /// Как счётчик класса называется в описании отдыха: «вдохновение барда», «единицы чародейства».
  ///
  /// ВАЖНО: при переводе следующего класса на данные с ttg.club сюда нужно добавить его счётчик
  /// (ярость варвара, ци монаха и т.д.), иначе в описании отдыха он не упоминается.
  static String? _restoredExtra(ClassExtras extra) => switch (extra) {
        ClassExtras.inspiration => 'вдохновение барда',
        ClassExtras.sorceryPoints => 'единицы чародейства',
        _ => null,
      };

  /// «Восстановить хиты, ячейки заклинаний и единицы чародейства?» — только то, что есть у персонажа.
  static String _description(Player player) {
    final restored = [
      'хиты',
      if (player.spellCells.isNotEmpty) 'ячейки заклинаний',
      ...player.maxExtras.keys.map(_restoredExtra).nonNulls,
    ];
    final list = restored.length == 1
        ? restored.single
        : '${restored.sublist(0, restored.length - 1).join(', ')} и ${restored.last}';
    return [
      'Восстановить $list?',
      if (player.maxSorceryPoints > 0) 'Ячейки, созданные из единиц чародейства, исчезнут.',
    ].join(' ');
  }

  Future<void> _longRest(BuildContext context, Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Продолжительный отдых'),
        content: Text(_description(player)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Отдохнуть')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) context.read<PlayerCubit>().longRest();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, Player>(
      buildWhen: (previous, current) => previous.canRestOnLongRest != current.canRestOnLongRest,
      builder: (context, player) {
        return TextButton.icon(
          onPressed: player.canRestOnLongRest ? () => _longRest(context, context.read<PlayerCubit>().state) : null,
          icon: const Icon(Icons.bedtime_outlined),
          label: const Text('Отдых'),
        );
      },
    );
  }
}
