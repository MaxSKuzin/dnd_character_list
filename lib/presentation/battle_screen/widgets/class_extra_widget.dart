import 'package:dnd_character_list/domain/bloc/player_cubit.dart';
import 'package:dnd_character_list/domain/models/class_extras.dart';
import 'package:dnd_character_list/presentation/battle_screen/widgets/font_of_magic_actions.dart';
import 'package:dnd_character_list/presentation/common/widgets/html_content.dart';
import 'package:dnd_character_list/presentation/common/widgets/sheet_section.dart';
import 'package:dnd_character_list/presentation/extensions/context_extensions.dart';
import 'package:dnd_character_list/presentation/main_flow/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ClassExtraWidget extends StatelessWidget {
  final ClassExtras extra;
  final int count;

  const ClassExtraWidget({
    required this.extra,
    required this.count,
    super.key,
  });

  void _showDescription(BuildContext context) {
    final description =
        PlayerModel.getPlayer(context).classes.firstWhere((e) => e.classExtras.contains(extra)).classExtraDescription;
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        // Действия ресурса (например, «Источник магии») меняют персонажа прямо из диалога.
        value: context.read<PlayerCubit>(),
        child: Dialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: _DescriptionDialog(extra: extra, description: description(extra)),
        ),
      ),
    );
  }

  /// Ресурс класса: «−» тратит, «+» возвращает, нажатие на плитку — описание.
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    return InfoTile(
      label: extra.name,
      value: '$count',
      valueStyle: context.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      decreaseTooltip: 'Потратить',
      increaseTooltip: 'Вернуть',
      onTap: () => _showDescription(context),
      onDecrease: () => cubit.useExtra(extra),
      onIncrease: () => cubit.restoreExtra(extra),
    );
  }
}

class _DescriptionDialog extends StatelessWidget {
  final ClassExtras extra;
  final String description;

  const _DescriptionDialog({
    required this.extra,
    required this.description,
  });

  /// Действия, которые есть только у некоторых ресурсов классов.
  List<Widget> get _actions => switch (extra) {
        ClassExtras.sorceryPoints => const [FontOfMagicActions(), Gap(16)],
        _ => const [],
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            extra.name,
            style: context.theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const Gap(16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ..._actions,
                // Описания умений с ttg.club (вдохновение барда, единицы чародейства) — html.
                if (description.trimLeft().startsWith('<')) HtmlContent(description) else Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
