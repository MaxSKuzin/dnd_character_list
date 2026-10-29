import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/domain/models/classes/class_kind.dart';
import 'package:dnd_character_list/domain/models/player.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

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
      if (player.spentHitDice.isNotEmpty) 'половина костей хитов',
      if (player.spellCells.isNotEmpty) 'ячейки заклинаний',
      ...player.maxExtras.keys.map(_restoredExtra).nonNulls,
    ];
    return [
      'Восстановятся ${_list(restored)}.',
      if (player.tempHits > 0) 'Временные хиты пропадут.',
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
        final result = await showDialog<(Map<ClassKind, int>, int)>(
          context: context,
          builder: (_) => _ShortRestDialog(player: player),
        );
        if (result == null) return;
        cubit.shortRest(result.$2, dice: result.$1);
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

/// Короткий отдых: сколько костей хитов каждого класса потрачено и сколько хитов они вернули. Кости бросают
/// вживую, вводится сумма с модификаторами Телосложения.
class _ShortRestDialog extends StatefulWidget {
  final Player player;

  const _ShortRestDialog({required this.player});

  @override
  State<_ShortRestDialog> createState() => _ShortRestDialogState();
}

class _ShortRestDialogState extends State<_ShortRestDialog> {
  final _dice = <ClassKind, int>{};
  final _health = TextEditingController();

  @override
  void dispose() {
    _health.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final needsHits = player.currentHits < player.maxHits;
    final spent = _dice.values.fold(0, (sum, e) => sum + e);
    return AlertDialog(
      title: const Text('Короткий отдых'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!needsHits)
              const Text('Хиты полные — кости хитов тратить не нужно.')
            else ...[
              const Text('Сколько костей хитов бросили и сколько хитов они вернули.'),
              for (final spec in player.classes) ...[
                const Gap(8),
                InfoTile(
                  label: '${spec.classKind.localizedName}: кости ${spec.hitDice.name}',
                  value: '${_dice[spec.classKind] ?? 0}',
                  caption: 'осталось ${player.hitDiceLeft(spec)}',
                  onDecrease: (_dice[spec.classKind] ?? 0) > 0
                      ? () => setState(() => _dice[spec.classKind] = _dice[spec.classKind]! - 1)
                      : null,
                  onIncrease: (_dice[spec.classKind] ?? 0) < player.hitDiceLeft(spec)
                      ? () => setState(() => _dice[spec.classKind] = (_dice[spec.classKind] ?? 0) + 1)
                      : null,
                ),
              ],
              const Gap(8),
              TextField(
                controller: _health,
                enabled: spent > 0,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Хиты от костей'),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        ListenableBuilder(
          listenable: _health,
          builder: (context, _) {
            final health = int.tryParse(_health.text) ?? 0;
            // Потраченные кости должны что-то вернуть: без суммы хитов отдых не подтвердить.
            final ready = spent == 0 || health > 0;
            return TextButton(
              onPressed: ready ? () => Navigator.pop(context, (Map.of(_dice), spent == 0 ? 0 : health)) : null,
              child: const Text('Отдохнуть'),
            );
          },
        ),
      ],
    );
  }
}
