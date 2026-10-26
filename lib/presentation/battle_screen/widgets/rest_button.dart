import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/presentation/common/widgets/enter_number_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Отдых в шапке экрана боя: на выбор короткий или продолжительный. Кнопка на месте всегда, чтобы экран
/// не сдвигался, и активна, только когда хиты, ячейки заклинаний или ресурсы классов не на максимуме.
class RestButton extends StatelessWidget {
  const RestButton({super.key});

  /// Как счётчик класса называется в описании отдыха: «вдохновение барда», «единицы чародейства».
  ///
  /// ВАЖНО: при переводе следующего класса на данные с ttg.club сюда нужно добавить его счётчик
  /// (ярость варвара и т.д.), иначе в описании отдыха он не упоминается.
  static String? _restoredExtra(ClassExtras extra) => switch (extra) {
        ClassExtras.inspiration => 'вдохновение барда',
        ClassExtras.sorceryPoints => 'единицы чародейства',
        ClassExtras.ci => 'очки ци',
        ClassExtras.secondWind => 'второе дыхание',
        ClassExtras.actionSurge => 'всплеск действий',
        ClassExtras.indomitable => 'упорство',
        ClassExtras.superiorityDice => 'кости превосходства',
        ClassExtras.favoredFoe => 'предпочтительный противник',
        ClassExtras.tireless => 'неутомимость',
        _ => null,
      };

  /// «хиты, ячейки заклинаний и единицы чародейства».
  static String _list(List<String> items) =>
      items.length == 1 ? items.single : '${items.sublist(0, items.length - 1).join(', ')} и ${items.last}';

  /// Что восстановит продолжительный отдых — только то, что есть у персонажа.
  static String _longRestDescription(Player player) {
    final restored = [
      'хиты',
      if (player.spellCells.isNotEmpty) 'ячейки заклинаний',
      ...player.maxExtras.keys.map(_restoredExtra).nonNulls,
    ];
    return [
      'Восстановятся ${_list(restored)}.',
      if (player.maxSorceryPoints > 0) 'Ячейки, созданные из единиц чародейства, исчезнут.',
    ].join(' ');
  }

  /// Короткий отдых: кости хитов и ресурсы классов, которые он восстанавливает.
  static String _shortRestDescription(Player player) {
    final extras = player.shortRestExtras.map(_restoredExtra).nonNulls.toList();
    return [
      'Можно потратить кости хитов (${player.hitDices}) и восстановить хиты.',
      if (extras.isNotEmpty) 'Восстановятся ${_list(extras)}.',
    ].join(' ');
  }

  Future<void> _rest(BuildContext context) async {
    final cubit = context.read<PlayerCubit>();
    final player = cubit.state;
    final kind = await showDialog<_RestKind>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Отдых'),
        children: [
          _RestOption(
            title: 'Короткий отдых',
            description: _shortRestDescription(player),
            onTap: player.canRestOnShortRest ? () => Navigator.pop(context, _RestKind.short) : null,
          ),
          _RestOption(
            title: 'Продолжительный отдых',
            description: _longRestDescription(player),
            onTap: () => Navigator.pop(context, _RestKind.long),
          ),
        ],
      ),
    );
    if (kind == null || !context.mounted) return;
    switch (kind) {
      case _RestKind.short:
        // Кости хитов бросают вживую: вводится сумма с модификаторами Телосложения.
        var health = 0;
        if (player.currentHits < player.maxHits) {
          final value = await EnterNumberDialog.show(
            context,
            title: 'Короткий отдых',
            labelText: 'Хиты от костей хитов (0 — не тратить)',
          );
          if (value == null) return;
          health = value;
        }
        cubit.shortRest(health);
      case _RestKind.long:
        cubit.longRest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, Player>(
      buildWhen: (previous, current) => previous.canRestOnLongRest != current.canRestOnLongRest,
      builder: (context, player) {
        return TextButton.icon(
          onPressed: player.canRestOnLongRest ? () => _rest(context) : null,
          icon: const Icon(Icons.bedtime_outlined),
          label: const Text('Отдых'),
        );
      },
    );
  }
}

enum _RestKind { short, long }

class _RestOption extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _RestOption({required this.title, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: onTap != null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(title),
      subtitle: Text(description),
      onTap: onTap,
    );
  }
}
